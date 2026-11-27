import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/rent/rent_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  group('repository', () {
    late AppDatabase db;
    late RentRepository repo;
    var now = DateTime(2026, 12, 6, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 12, 6, 9);
      repo = RentRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    Future<Lease> lease(String id) => (db.select(db.leases)..where((l) => l.id.equals(id))).getSingle();
    Future<List<LedgerEntry>> ledger() => (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get();
    Future<RentSummary> summary() async => RentSummary(
      await repo.watchUnits().first,
      await repo.watchLeases().first,
      await repo.watchPayments().first,
      now,
    );

    Future<String> tenant(String unit, String name, int rent, int dueDay, DateTime starts, {int? deposit}) async {
      final u = await repo.addUnit(unit);
      return repo.addLease(
        unitId: u,
        tenantName: name,
        rentMinor: rent,
        dueDay: dueDay,
        startsOn: starts,
        depositMinor: deposit,
      );
    }

    test('a payment posts income to the ledger and covers the oldest month first', () async {
      final id = await tenant('Room 2', 'Jun', 350000, 1, DateTime(2026, 11, 1), deposit: 700000);
      final pay = await repo.recordPayment(await lease(id), 'Room 2', 500000, method: 'gcash');

      final tx = (await ledger()).single;
      expect(tx.id, rentPaymentLedgerId(householdId, pay));
      expect(tx.amountMinor, 500000);
      expect(tx.category, 'income');
      expect(tx.sourceType, 'rent');
      expect(tx.sourceId, id);
      expect(tx.note, 'Room 2 · Jun');

      final s = LeaseStatus.of(await lease(id), await repo.watchPayments().first, now);
      expect(s.dueSoFar, 700000, reason: 'November and December');
      expect(s.owed, 200000);
      expect(s.oldestDue, DateTime(2026, 12, 1), reason: 'November is covered');
      expect(s.oldestLeft, 200000);
      expect(s.partlyPaid, isTrue);
      expect(s.daysLate, 5);
      expect(s.due, RentDue.overdue);
    });

    test('paying ahead leaves credit and nothing owed', () async {
      final id = await tenant('Stall', 'Aling Nena', 600000, 10, DateTime(2026, 12, 1));
      await repo.recordPayment(await lease(id), 'Stall', 1200000);
      final s = LeaseStatus.of(await lease(id), await repo.watchPayments().first, now);
      expect(s.owed, 0);
      expect(s.credit, 600000);
      expect(s.due, RentDue.paid);
      expect(s.oldestDue, isNull);
    });

    test('due day 31 falls on the last day of a short month; due soon within 7 days', () async {
      final id = await tenant('Room 1', 'Carlo', 300000, 31, DateTime(2027, 2, 1));
      now = DateTime(2027, 2, 10);
      final s = LeaseStatus.of(await lease(id), const [], now);
      expect(s.oldestDue, DateTime(2027, 2, 28));
      expect(s.due, RentDue.later);
      now = DateTime(2027, 2, 23);
      expect(LeaseStatus.of(await lease(id), const [], now).due, RentDue.soon);
    });

    test('waiving clears what is owed without a ledger entry', () async {
      final id = await tenant('Room 3', 'Mia', 300000, 1, DateTime(2026, 12, 1));
      await repo.waive(await lease(id), 300000, note: 'roof repair');
      expect(LeaseStatus.of(await lease(id), await repo.watchPayments().first, now).owed, 0);
      expect(await ledger(), isEmpty);
    });

    test('a new rent applies from this month; earlier months keep the old one', () async {
      final id = await tenant('Room 2', 'Jun', 350000, 1, DateTime(2026, 10, 1));
      final l = await lease(id);
      await repo.editLease(l, tenantName: 'Jun', rentMinor: 400000, dueDay: 1, startsOn: DateTime(2026, 10, 1));
      final edited = await lease(id);
      expect(edited.rentMinor, 400000);
      expect(edited.prevRentMinor, 350000);
      expect(edited.rentSince, '2026-12-01');
      expect(LeaseStatus.of(edited, const [], now).dueSoFar, 350000 * 2 + 400000);
    });

    test('summary: to collect oldest first, paid, vacant, and moved-out tenants who still owe', () async {
      final jun = await tenant('Room 2', 'Jun', 350000, 1, DateTime(2026, 12, 1));
      final nena = await tenant('Stall', 'Aling Nena', 600000, 10, DateTime(2026, 12, 1));
      final carlo = await tenant('Room 1', 'Carlo', 350000, 1, DateTime(2026, 12, 1));
      await repo.addUnit('Room 4');
      final old = await tenant('Room 5', 'Ben', 300000, 1, DateTime(2026, 9, 1));
      await repo.recordPayment(await lease(carlo), 'Room 1', 350000);
      await repo.recordPayment(await lease(nena), 'Stall', 200000);
      await repo.recordPayment(await lease(old), 'Room 5', 600000);
      await repo.moveOut(await lease(old), DateTime(2026, 11, 30), depositReturnedMinor: 0);

      final s = await summary();
      expect(s.toCollect.map((r) => r.status!.lease.tenantName).toList(), ['Ben', 'Jun', 'Aling Nena']);
      expect(s.totalOwed, 300000 + 350000 + 400000);
      expect(s.paid.single.status!.lease.id, carlo);
      expect(s.vacant.map((u) => u.name).toList(), ['Room 4', 'Room 5']);
      expect(s.activeCount, 3);
      expect(s.overdueCount, 2, reason: 'Ben (November) and Jun (December 1)');
      expect(s.current.containsKey((await lease(jun)).unitId), isTrue);
      expect((await lease(old)).depositReturnedOn, '2026-12-06');
    });

    test('only the recorder removes a payment, and its income goes with it', () async {
      final id = await tenant('Room 2', 'Jun', 350000, 1, DateTime(2026, 12, 1));
      await repo.recordPayment(await lease(id), 'Room 2', 350000);
      final p = (await repo.watchHistory(id).first).single;
      expect(repo.canRemove(p), isTrue);
      final other = RentRepository(db, writer(db, identity(memberId: memberB, deviceId: deviceB)));
      expect(other.canRemove(p), isFalse);
      await repo.removePayment(p);
      expect(await repo.watchHistory(id).first, isEmpty);
      expect(await ledger(), isEmpty);
    });
  });

  test('two adults record payments offline: both count', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final now = DateTime(2026, 12, 6, 9);
    final a = RentRepository(dbA, wA, now: () => now);
    final b = RentRepository(dbB, wB, now: () => now);
    final syncA = SyncEngine(
      db: dbA,
      api: server.apiFor(memberId: memberA, deviceId: deviceA),
      clock: wA.clock,
    );
    final syncB = SyncEngine(
      db: dbB,
      api: server.apiFor(memberId: memberB, deviceId: deviceB),
      clock: wB.clock,
    );

    final unit = await a.addUnit('Room 2');
    final id = await a.addLease(
      unitId: unit,
      tenantName: 'Jun',
      rentMinor: 350000,
      dueDay: 1,
      startsOn: DateTime(2026, 11, 1),
    );
    await syncA.sync();
    await syncB.sync();
    await a.recordPayment((await a.watchLeases().first).single, 'Room 2', 350000);
    await b.recordPayment((await b.watchLeases().first).single, 'Room 2', 200000);
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final (repo, db) in [(a, dbA), (b, dbB)]) {
      final s = LeaseStatus.of((await repo.watchLeases().first).single, await repo.watchPayments().first, now);
      expect(s.received, 550000);
      expect(s.owed, 150000);
      expect(await repo.watchHistory(id).first, hasLength(2));
      expect(await (db.select(db.transactions)).get(), hasLength(2));
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 13 database adds the rent tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v13 = AppDatabase(NativeDatabase(file));
    await v13.customStatement('SELECT 1');
    for (final t in ['rental_units', 'leases', 'rent_payments']) {
      await v13.customStatement('DROP TABLE $t');
    }
    await v13.customStatement('PRAGMA user_version = 13');
    await v13.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = RentRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    final unit = await repo.addUnit('Room 1');
    await repo.addLease(
      unitId: unit,
      tenantName: 'Carlo',
      rentMinor: 300000,
      dueDay: 5,
      startsOn: DateTime(2026, 12, 1),
    );
    expect(await repo.watchLeases().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
