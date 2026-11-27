import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/calendar/calendar_repository.dart';
import 'package:homesync/features/vehicles/vehicles_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  group('repository', () {
    late AppDatabase db;
    late VehiclesRepository repo;
    var now = DateTime(2026, 11, 27, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 11, 27, 9);
      repo = VehiclesRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    Future<Vehicle> vehicle(String id) => (db.select(db.vehicles)..where((v) => v.id.equals(id))).getSingle();
    Future<List<LedgerEntry>> ledger() => (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get();

    test('fuel is logged with odometer and litres and posts a transport expense', () async {
      final id = await repo.addVehicle(kind: 'car', name: 'Innova', plate: 'ABC 1234', odometerKm: 44000);
      expect(await repo.odometer(id), 44000);

      final logId = await repo.logCost(await vehicle(id), 'fuel', 200000, odometerKm: 44210, litres: 31.5);
      expect(await repo.odometer(id), 44210);
      final log = (await repo.watchHistory(id).first).firstWhere((l) => l.id == logId);
      expect(log.litres, 31.5);
      expect(log.memberId, memberA);
      final tx = (await ledger()).single;
      expect(tx.id, vehicleLogLedgerId(householdId, logId));
      expect(tx.amountMinor, -200000);
      expect(tx.category, 'transport');
      expect(tx.sourceType, 'vehicle');
      expect(tx.sourceId, id);
      expect(tx.note, 'Innova');
    });

    test('a lower reading does not turn the odometer back', () async {
      final id = await repo.addVehicle(kind: 'motorcycle', name: 'Mio', odometerKm: 18900);
      await repo.logOdometer(await vehicle(id), 18000);
      expect(await repo.odometer(id), 18900);
      expect(await ledger(), isEmpty, reason: 'a reading costs nothing');
    });

    test('registration paid near its due date moves one year on; paid early it stays', () async {
      final id = await repo.addVehicle(kind: 'car', name: 'Innova', registrationDueOn: DateTime(2026, 12, 20));
      await repo.logCost(await vehicle(id), 'registration', 180000);
      expect((await vehicle(id)).registrationDueOn, '2027-12-20');
      await repo.logCost(await vehicle(id), 'registration', 5000);
      expect((await vehicle(id)).registrationDueOn, '2027-12-20', reason: 'a year away: not a renewal');
    });

    test('insurance with no date gets one a year from today; years overdue keeps the day', () async {
      final a = await repo.addVehicle(kind: 'car', name: 'A');
      await repo.logCost(await vehicle(a), 'insurance', 1500000);
      expect((await vehicle(a)).insuranceDueOn, '2027-11-27');

      final b = await repo.addVehicle(kind: 'car', name: 'B', insuranceDueOn: DateTime(2024, 3, 2));
      await repo.logCost(await vehicle(b), 'insurance', 1500000);
      expect((await vehicle(b)).insuranceDueOn, '2027-03-02');
    });

    test('a PMS sets the next date and reading from the interval', () async {
      final id = await repo.addVehicle(
        kind: 'car',
        name: 'Innova',
        pmsDueOn: DateTime(2026, 12, 6),
        pmsDueKm: 45000,
        pmsEveryMonths: 6,
        pmsEveryKm: 5000,
        odometerKm: 44210,
      );
      await repo.logCost(await vehicle(id), 'pms', 450000, odometerKm: 44800);
      final v = await vehicle(id);
      expect(v.pmsDueOn, '2027-05-27');
      expect(v.pmsDueKm, 49800);

      final noKm = await repo.addVehicle(kind: 'car', name: 'B', pmsEveryKm: 5000, odometerKm: 1000);
      await repo.logCost(await vehicle(noKm), 'pms', 100000);
      expect((await vehicle(noKm)).pmsDueKm, 6000, reason: 'uses the current odometer when none is given');
    });

    test('only the recorder removes an entry, and its expense goes with it', () async {
      final id = await repo.addVehicle(kind: 'car', name: 'Innova');
      await repo.logCost(await vehicle(id), 'repair', 420000, note: 'aircon');
      final log = (await repo.watchHistory(id).first).single;
      expect(log.note, 'aircon');
      final other = VehiclesRepository(
        db,
        writer(db, identity(memberId: memberB, deviceId: deviceB)),
        now: () => now,
      );
      expect(other.canRemove(log), isFalse);
      expect(repo.canRemove(log), isTrue);
      await repo.removeLog(log);
      expect(await repo.watchHistory(id).first, isEmpty);
      expect(await ledger(), isEmpty);
    });

    test('edit saves only what changed', () async {
      final id = await repo.addVehicle(kind: 'car', name: 'Innova', plate: 'ABC 1234');
      await repo.editVehicle(await vehicle(id), name: 'Innova', plate: 'ABC 1234', color: 'silver');
      final v = await vehicle(id);
      expect(v.color, 'silver');
      expect(v.plate, 'ABC 1234');
    });
  });

  test('summary sorts due items: overdue, soon (date or km), later; and sums this month', () async {
    final db = memoryDb();
    final now = DateTime(2026, 11, 27, 9);
    final repo = VehiclesRepository(
      db,
      writer(db, identity(memberId: memberA, deviceId: deviceA)),
      now: () => now,
    );
    final innova = await repo.addVehicle(
      kind: 'car',
      name: 'Innova',
      pmsDueOn: DateTime(2027, 3, 1),
      pmsDueKm: 45000,
      insuranceDueOn: DateTime(2027, 3, 2),
      odometerKm: 44700,
    );
    final mio = await repo.addVehicle(kind: 'motorcycle', name: 'Mio', registrationDueOn: DateTime(2026, 11, 20));
    await repo.addVehicle(kind: 'car', name: 'Old', registrationDueOn: DateTime(2026, 12, 5));
    final v = (await repo.watchVehicles().first).firstWhere((x) => x.id == mio);
    await repo.logCost(v, 'fuel', 22000);

    final sum = VehiclesSummary(await repo.watchVehicles().first, await repo.watchLogs().first, now);
    expect(sum.due.map((d) => '${d.vehicle.name}/${d.kind}/${d.status.name}').toList(), [
      'Mio/registration/overdue',
      'Old/registration/soon',
      'Innova/pms/soon', // 300 km away, though its date is months off
      'Innova/insurance/later',
    ]);
    expect(sum.overdue, 1);
    expect(sum.next?.kind, 'registration');
    expect(sum.odometers[innova], 44700);
    expect(sum.due[2].kmLeft, 300);
    expect(sum.monthSpent, 22000);
    await db.close();
  });

  test('the calendar shows registration, insurance and PMS dates', () async {
    final db = memoryDb();
    final repo = VehiclesRepository(db, writer(db, identity(memberId: memberA, deviceId: deviceA)));
    await repo.addVehicle(
      kind: 'car',
      name: 'Innova',
      registrationDueOn: DateTime(2026, 12, 3),
      insuranceDueOn: DateTime(2027, 3, 2),
      pmsDueOn: DateTime(2026, 12, 6),
      pmsDueKm: 45000,
    );
    final agenda = Agenda(
      const [],
      DateTime(2026, 12, 1),
      DateTime(2026, 12, 31),
      vehicles: await repo.watchVehicles().first,
    );
    final reg = agenda.on(DateTime(2026, 12, 3)).single;
    expect(reg.kind, CalendarKind.vehicle);
    expect(reg.title, 'Innova');
    expect(reg.dueKind, 'registration');
    expect(agenda.on(DateTime(2026, 12, 6)).single.dueKind, 'pms');
    expect(agenda.on(DateTime(2027, 3, 2)), isEmpty, reason: 'outside the range');
    await db.close();
  });

  test('two adults log fuel offline: both count', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final now = DateTime(2026, 11, 27, 9);
    final a = VehiclesRepository(dbA, wA, now: () => now);
    final b = VehiclesRepository(dbB, wB, now: () => now);
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

    final id = await a.addVehicle(kind: 'car', name: 'Innova', odometerKm: 44000);
    await syncA.sync();
    await syncB.sync();
    await a.logCost((await a.watchVehicles().first).single, 'fuel', 200000, odometerKm: 44200);
    await b.logCost((await b.watchVehicles().first).single, 'fuel', 150000, odometerKm: 44350);
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final (repo, db) in [(a, dbA), (b, dbB)]) {
      expect(await repo.watchHistory(id).first, hasLength(3));
      expect(await repo.odometer(id), 44350);
      expect(await (db.select(db.transactions)).get(), hasLength(2));
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 10 database adds the vehicle tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v10 = AppDatabase(NativeDatabase(file));
    await v10.customStatement('SELECT 1');
    await v10.customStatement('DROP TABLE vehicles');
    await v10.customStatement('DROP TABLE vehicle_logs');
    for (final t in ['vault_keys', 'vault_items', 'vault_files', 'vault_blobs']) {
      await v10.customStatement('DROP TABLE "$t"'); // added in v12
    }
    await v10.customStatement('DROP TABLE health_profiles'); // added in v13
    await v10.customStatement('DROP TABLE medicines');
    await v10.customStatement('DROP TABLE med_doses');
    await v10.customStatement('DROP TABLE checkups');
    await v10.customStatement('PRAGMA user_version = 10');
    await v10.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = VehiclesRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    final id = await repo.addVehicle(kind: 'car', name: 'Innova', odometerKm: 100);
    expect(await repo.odometer(id), 100);
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
