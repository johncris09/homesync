import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/maintenance/maintenance_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  group('repository', () {
    late AppDatabase db;
    late MaintenanceRepository repo;
    var now = DateTime(2026, 12, 6, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 12, 6, 9);
      repo = MaintenanceRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    Future<MaintenanceTask> task(String id) async => (await repo.watchTasks().first).firstWhere((t) => t.id == id);
    Future<List<LedgerEntry>> ledger() => (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get();

    test('marking upkeep done logs it, posts the cost once and moves the date on', () async {
      final id = await repo.addTask(
        name: ' Aircon cleaning ',
        area: 'aircon',
        everyMonths: 3,
        nextDueOn: DateTime(2026, 12, 2),
      );
      var t = await task(id);
      expect(t.name, 'Aircon cleaning');
      expect(dueOf(t, repo.today), Due.overdue);

      await repo.markDone(t, doneOn: DateTime(2026, 12, 5), costMinor: 150000, note: 'Both units');
      t = await task(id);
      expect(t.lastDoneOn, '2026-12-05');
      expect(t.nextDueOn, '2027-03-05');
      expect(dueOf(t, repo.today), Due.later);

      final log = (await repo.watchLogs().first).single;
      expect(log.id, upkeepLogId(householdId, id, '2026-12-02'));
      expect((log.kind, log.dueOn, log.costMinor, log.memberId), (upkeepKind, '2026-12-02', 150000, memberA));
      final entry = (await ledger()).single;
      expect(entry.id, maintenanceCostId(householdId, log.id));
      expect((entry.amountMinor, entry.category, entry.sourceType), (-150000, 'household', maintenanceSource));
      expect(entry.occurredAt.toLocal().day, 5);

      // Undo: back to the date it was due, cost removed. Done again: new ids.
      expect(await repo.canUndo(t), isTrue);
      final other = MaintenanceRepository(db, writer(db, identity(memberId: memberB, deviceId: deviceB)));
      expect(await other.canUndo(t), isFalse, reason: 'only who marked it done');
      await repo.undoDone(t);
      t = await task(id);
      expect((t.nextDueOn, t.lastDoneOn), ('2026-12-02', null));
      expect(await repo.watchLogs().first, isEmpty);
      expect(await ledger(), isEmpty);

      await repo.markDone(t, costMinor: 0);
      t = await task(id);
      expect(t.nextDueOn, '2027-03-06');
      expect((await repo.watchLogs().first).single.id, isNot(upkeepLogId(householdId, id, '2026-12-02')));
      expect(await ledger(), isEmpty, reason: 'no cost, no expense');
    });

    test('a one-off task is done once; repairs post their cost and can be removed', () async {
      final id = await repo.addTask(name: 'Fix the gate', area: 'other', nextDueOn: DateTime(2026, 12, 20));
      await repo.markDone(await task(id));
      final t = await task(id);
      expect((t.nextDueOn, t.lastDoneOn), (null, '2026-12-06'));

      final r = await repo.addRepair(
        title: 'Leaking roof',
        area: 'roof',
        costMinor: 800000,
        doneOn: DateTime(2026, 8, 2),
      );
      expect((await ledger()).single.sourceId, r);
      final log = (await repo.watchLogs().first).firstWhere((l) => l.id == r);
      await repo.setLogNote(log, 'Replaced 3 sheets');
      await repo.removeLog((await repo.watchLogs().first).firstWhere((l) => l.id == r));
      expect(await ledger(), isEmpty);
      expect((await repo.watchLogs().first).map((l) => l.kind), [upkeepKind]);
    });

    test('summary: overdue, coming up by date, one-offs, spent this year', () async {
      await repo.addTask(name: 'Pest control', area: 'pest', everyMonths: 6, nextDueOn: DateTime(2026, 10, 3));
      await repo.addTask(name: 'Tank cleaning', area: 'water', everyMonths: 6, nextDueOn: DateTime(2027, 2, 10));
      await repo.addTask(name: 'Aircon cleaning', area: 'aircon', everyMonths: 3, nextDueOn: DateTime(2026, 12, 11));
      await repo.addTask(name: 'Paint the fence', area: 'other');
      await repo.addRepair(title: 'Breaker', area: 'electrical', costMinor: 120000, doneOn: DateTime(2026, 3, 1));
      await repo.addRepair(title: 'Old faucet', area: 'plumbing', costMinor: 50000, doneOn: DateTime(2025, 12, 30));

      final s = MaintenanceSummary(await repo.watchTasks().first, await repo.watchLogs().first, repo.today);
      expect(s.overdue.single.name, 'Pest control');
      expect(s.upcoming.map((t) => t.name).toList(), ['Aircon cleaning', 'Tank cleaning']);
      expect(s.next!.name, 'Aircon cleaning');
      expect(s.soonCount, 1);
      expect(s.undated.single.name, 'Paint the fence');
      expect(s.spentThisYear, 120000);
    });

    test('contractors', () async {
      final id = await repo.addContractor(name: 'Mang Ben', trade: 'aircon', phone: ' 0917 555 0123 ');
      var c = (await repo.watchContractors().first).single;
      expect(c.phone, '0917 555 0123');
      await repo.editContractor(c, name: 'Mang Ben', trade: 'aircon', phone: '0917 555 0124');
      c = (await repo.watchContractors().first).single;
      expect(c.phone, '0917 555 0124');
      await repo.removeContractor(id);
      expect(await repo.watchContractors().first, isEmpty);
    });
  });

  test('offline on two phones: the same upkeep done twice is one entry and one expense', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final a = MaintenanceRepository(dbA, wA);
    final b = MaintenanceRepository(dbB, wB);
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

    await a.addTask(name: 'Tank cleaning', area: 'water', everyMonths: 6, nextDueOn: DateTime(2026, 12, 1));
    await syncA.sync();
    await syncB.sync();

    await a.markDone((await a.watchTasks().first).single, doneOn: DateTime(2026, 12, 4), costMinor: 200000);
    await b.markDone((await b.watchTasks().first).single, doneOn: DateTime(2026, 12, 4), costMinor: 200000);
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final (repo, db) in [(a, dbA), (b, dbB)]) {
      expect(await repo.watchLogs().first, hasLength(1));
      expect(await (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get(), hasLength(1));
      expect((await repo.watchTasks().first).single.nextDueOn, '2027-06-04');
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 17 database adds the maintenance tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v17 = AppDatabase(NativeDatabase(file));
    await v17.customStatement('SELECT 1');
    for (final t in ['contractors', 'maintenance_tasks', 'maintenance_logs']) {
      await v17.customStatement('DROP TABLE $t');
    }
    await v17.customStatement('PRAGMA user_version = 17');
    await v17.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = MaintenanceRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.addContractor(name: 'Mang Ben', trade: 'aircon');
    await repo.addRepair(title: 'Breaker', area: 'electrical');
    expect(await repo.watchLogs().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
