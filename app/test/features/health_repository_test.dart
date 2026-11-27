import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/core/vault/vault_crypto.dart';
import 'package:homesync/core/vault/vault_session.dart';
import 'package:homesync/features/calendar/calendar_repository.dart';
import 'package:homesync/features/health/health_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const lola = '01900000-0000-7000-8000-0000000000cc';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

HealthRepository repoFor(AppDatabase db, String member, String device, {DateTime Function()? now, VaultSession? s}) =>
    HealthRepository(
      db,
      writer(db, identity(memberId: member, deviceId: device)),
      session: s ?? VaultSession(store: MemorySecureStore()),
      crypto: VaultCrypto(iterations: 1000),
      now: now,
    );

void main() {
  test('dose times are parsed, padded and sorted', () {
    expect(parseTimes('20:00, 8:00,bad,25:00,08:00'), ['08:00', '20:00']);
    expect(parseTimes(null), isEmpty);
  });

  group('repository', () {
    late AppDatabase db;
    late HealthRepository repo;
    var now = DateTime(2026, 11, 28, 7, 30);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 11, 28, 7, 30);
      repo = repoFor(db, memberA, deviceA, now: () => now);
    });
    tearDown(() => db.close());

    Future<Medicine> med(String id) => (db.select(db.medicines)..where((m) => m.id.equals(id))).getSingle();
    Future<HealthSummary> summary() async => HealthSummary(
      medicines: await repo.watchMedicines().first,
      doses: await repo.watchRecentDoses().first,
      checkups: await repo.watchCheckups().first,
      today: repo.today,
    );

    test('today lists each scheduled dose; giving one records who and takes it from stock', () async {
      final id = await repo.addMedicine(
        name: 'Losartan',
        strength: '50mg',
        memberId: lola,
        times: '20:00,8:00',
        stock: 10,
        minStock: 9,
      );
      await repo.addMedicine(name: 'Paracetamol', stock: 20); // as needed: not on today's list
      var sum = await summary();
      expect(sum.slots.map((s) => '${s.medicine.name} ${s.slot}'), ['Losartan 08:00', 'Losartan 20:00']);
      expect(sum.left, 2);
      expect(sum.low, isEmpty);

      await repo.giveDose(await med(id), slot: '08:00');
      await repo.giveDose(await med(id), slot: '08:00'); // a second tap changes nothing
      sum = await summary();
      expect(sum.left, 1);
      expect(sum.next?.slot, '20:00');
      final dose = sum.slots.first.dose!;
      expect(dose.id, scheduledDoseId(householdId, id, '2026-11-28', '08:00'));
      expect(dose.givenBy, memberA);
      expect(dose.memberId, lola);
      expect((await med(id)).stock, 9);
      expect(sum.low.single.name, 'Losartan', reason: 'at the minimum');

      expect(repoFor(db, memberB, deviceB).canUndo(dose), isFalse);
      await repo.undoDose(dose);
      expect((await summary()).left, 2);
      expect((await med(id)).stock, 10);
      await repo.giveDose(await med(id), slot: '08:00');
      expect((await summary()).left, 1, reason: 'given again after undo');
    });

    test('a finished course drops off today; expiring soon is flagged', () async {
      await repo.addMedicine(
        name: 'Amoxicillin',
        times: '09:00',
        endsOn: DateTime(2026, 11, 27),
        expiresOn: DateTime(2026, 12, 10),
      );
      final sum = await summary();
      expect(sum.slots, isEmpty);
      expect(sum.expiring.single.name, 'Amoxicillin');
    });

    test('restock posts a health expense; stock-take sends the difference', () async {
      final id = await repo.addMedicine(name: 'Cetirizine', stock: 3);
      await repo.restock(await med(id), 10, costMinor: 15000);
      expect((await med(id)).stock, 13);
      final tx = (await db.select(db.transactions).get()).single;
      expect(tx.amountMinor, -15000);
      expect(tx.category, 'health');
      expect(tx.sourceType, 'medicine');
      expect(tx.note, 'Cetirizine');

      await repo.stockTake(await med(id), 11);
      expect((await med(id)).stock, 11);
      final ops = await db.select(db.outbox).get();
      expect(ops.where((o) => o.op == 'update' && o.entity == 'medicines'), isEmpty, reason: 'counters only increment');
    });

    test('running low goes on the grocery list once', () async {
      final id = await repo.addMedicine(name: 'Losartan', strength: '50mg', stock: 2, minStock: 5);
      expect(await repo.addToGroceryList(await med(id)), isTrue);
      expect(await repo.addToGroceryList(await med(id)), isFalse);
      expect((await db.select(db.groceryItems).get()).single.name, 'Losartan 50mg');
    });

    test('a checkup done with a cost posts it; the doer can undo both', () async {
      final id = await repo.addCheckup(
        kind: 'checkup',
        title: 'Cardiology',
        memberId: lola,
        dueOn: DateTime(2026, 12, 3),
      );
      await repo.addCheckup(kind: 'vaccine', title: 'Flu vaccine', dueOn: DateTime(2026, 12, 1));
      expect((await summary()).upcoming.map((c) => c.title), ['Flu vaccine', 'Cardiology']);

      var c = (await repo.watchCheckups().first).firstWhere((x) => x.id == id);
      await repo.markDone(c, costMinor: 80000);
      expect((await summary()).upcoming.single.title, 'Flu vaccine');
      final tx = (await db.select(db.transactions).get()).single;
      expect(tx.id, checkupLedgerId(householdId, id));
      expect(tx.sourceType, 'checkup');

      c = (await repo.watchCheckups().first).firstWhere((x) => x.id == id);
      expect(repo.canUndoDone(c), isTrue);
      await repo.undoDone(c);
      expect(await (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get(), isEmpty);
      expect((await summary()).upcoming, hasLength(2));
    });

    test('a profile is sealed with the vault key and opens only with it', () async {
      final session = VaultSession(store: MemorySecureStore());
      final locked = repoFor(db, memberA, deviceA, s: session);
      expect(() => locked.saveProfile(lola, const HealthFields(bloodType: 'O+')), throwsStateError);

      final key = VaultCrypto(iterations: 1000).newKey();
      await session.open(key);
      await locked.saveProfile(lola, const HealthFields(bloodType: 'O+', allergies: 'Penicillin'));
      final row = (await locked.watchProfiles().first).single;
      expect(row.id, healthProfileId(householdId, lola));
      expect(row.sealed, isNot(contains('Penicillin')));
      expect((await locked.openProfile(row))?.allergies, 'Penicillin');

      await locked.saveProfile(lola, const HealthFields(bloodType: 'O+', allergies: 'Penicillin', hmo: 'Maxicare'));
      expect(await locked.watchProfiles().first, hasLength(1), reason: 'one row per member');

      session.lock();
      expect(await locked.openProfile(row), isNull);
    });
  });

  test('open checkups with a date show on the calendar', () async {
    final db = memoryDb();
    final repo = repoFor(db, memberA, deviceA);
    await repo.addCheckup(kind: 'vaccine', title: 'Flu vaccine', dueOn: DateTime(2026, 12, 3), dueTime: '09:30');
    final done = await repo.addCheckup(kind: 'checkup', title: 'Dentist', dueOn: DateTime(2026, 12, 4));
    await repo.addCheckup(kind: 'checkup', title: 'Someday');
    await repo.markDone((await repo.watchCheckups().first).firstWhere((c) => c.id == done));
    final agenda = Agenda(
      const [],
      DateTime(2026, 12, 1),
      DateTime(2026, 12, 31),
      checkups: await repo.watchCheckups().first,
    );
    final item = agenda.on(DateTime(2026, 12, 3)).single;
    expect(item.kind, CalendarKind.checkup);
    expect(item.dueKind, 'vaccine');
    expect(item.startTime, '09:30');
    expect(agenda.on(DateTime(2026, 12, 4)), isEmpty, reason: 'done');
    await db.close();
  });

  test('two people tick the same dose offline: recorded once', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final now = DateTime(2026, 11, 28, 8, 5);
    final a = repoFor(dbA, memberA, deviceA, now: () => now);
    final b = repoFor(dbB, memberB, deviceB, now: () => now);
    final syncA = SyncEngine(
      db: dbA,
      api: server.apiFor(memberId: memberA, deviceId: deviceA),
      clock: a.writer.clock,
    );
    final syncB = SyncEngine(
      db: dbB,
      api: server.apiFor(memberId: memberB, deviceId: deviceB),
      clock: b.writer.clock,
    );

    await a.addMedicine(name: 'Losartan', times: '08:00', stock: 30);
    await syncA.sync();
    await syncB.sync();
    await a.giveDose((await a.watchMedicines().first).single, slot: '08:00');
    await b.giveDose((await b.watchMedicines().first).single, slot: '08:00');
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final (repo, db) in [(a, dbA), (b, dbB)]) {
      expect(await (db.select(db.medDoses)).get(), hasLength(1));
      expect((await repo.watchRecentDoses().first).single.givenBy, memberA, reason: 'the first record stays');
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 12 database adds the health tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v12 = AppDatabase(NativeDatabase(file));
    await v12.customStatement('SELECT 1');
    for (final t in ['health_profiles', 'medicines', 'med_doses', 'checkups']) {
      await v12.customStatement('DROP TABLE $t');
    }
    await v12.customStatement('DROP TABLE rental_units'); // added in v14
    await v12.customStatement('DROP TABLE leases');
    await v12.customStatement('DROP TABLE rent_payments');
    await v12.customStatement('DROP TABLE inventory_items'); // added in v15
    await v12.customStatement('PRAGMA user_version = 12');
    await v12.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = repoFor(reopened, memberA, deviceA);
    await repo.addMedicine(name: 'Losartan', stock: 5);
    expect(await repo.watchMedicines().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
