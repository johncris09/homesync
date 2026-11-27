import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/emergency/emergency_providers.dart' show canTickBag;
import 'package:homesync/features/emergency/emergency_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

Member member(String id, String name, String role) => Member(
  id: id,
  name: name,
  role: role,
  householdId: householdId,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  serverVersion: 0,
);

void main() {
  group('repository', () {
    late AppDatabase db;
    late EmergencyRepository repo;
    var now = DateTime(2026, 12, 6, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 12, 6, 9);
      repo = EmergencyRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    test('contacts keep their order and send only what changed', () async {
      await repo.addContact(name: 'Barangay hall', kind: 'barangay', phone: ' 0917 555 0199 ');
      await repo.addContact(name: 'Dr. Reyes', kind: 'doctor', phone: '0918 555 0100', note: 'pedia');
      var list = await repo.watchContacts().first;
      expect(list.map((c) => c.name).toList(), ['Barangay hall', 'Dr. Reyes']);
      expect(list.first.phone, '0917 555 0199');
      expect(list.map((c) => c.position).toList(), [0, 1]);

      await repo.editContact(list.last, name: 'Dr. Reyes', kind: 'doctor', phone: '0918 555 0101', note: 'pedia');
      list = await repo.watchContacts().first;
      expect(list.last.phone, '0918 555 0101');
      await repo.removeContact(list.first.id);
      expect(await repo.watchContacts().first, hasLength(1));
    });

    test('the plan is one row with a derived id', () async {
      expect(await repo.watchPlan().first, isNull);
      await repo.savePlan(meetingPoint: 'Covered court', evacuationCenter: ' Elementary school ');
      var p = (await repo.watchPlan().first)!;
      expect(p.id, emergencyPlanId(householdId));
      expect(p.evacuationCenter, 'Elementary school');
      await repo.savePlan(meetingPoint: 'Covered court', meetingPointFar: 'Tita Baby\'s house', evacuationCenter: '');
      p = (await repo.watchPlan().first)!;
      expect(p.meetingPointFar, 'Tita Baby\'s house');
      expect(p.evacuationCenter, isNull);
      expect(await db.select(db.emergencyPlans).get(), hasLength(1));
    });

    test('go-bags: starter list once, packed, expiring, household bag first', () async {
      final starter = ['Water', 'Flashlight', 'Medicines'];
      expect(await repo.addStarter(memberB, starter), 3);
      expect(await repo.addStarter(memberB, ['water', 'Whistle']), 1, reason: 'skips what the bag has');
      await repo.addBagItem(null, 'Canned goods', expiresOn: DateTime(2026, 12, 20));
      await repo.addBagItem(null, 'Batteries', expiresOn: DateTime(2028, 1, 1));

      var items = await repo.watchBagItems().first;
      await repo.setPacked(items.firstWhere((i) => i.name == 'Water'), true);
      items = await repo.watchBagItems().first;

      final bags = goBags([member(memberB, 'Ben', 'teen'), member(memberA, 'Ana', 'owner')], items);
      expect(bags.map((b) => b.memberId).toList(), [null, memberA, memberB]);
      final ben = bags.last;
      expect(ben.items.map((i) => i.name).toList(), ['Water', 'Flashlight', 'Medicines', 'Whistle']);
      expect(ben.packed, 1);
      expect(ben.ready, isFalse);
      expect(bags[1].items, isEmpty);
      expect(bags.first.expiring(now).single.name, 'Canned goods');
    });

    test('who may tick a go-bag', () {
      final teen = (id: memberB, role: 'teen');
      expect(canTickBag(teen, memberB), isTrue);
      expect(canTickBag(teen, null), isTrue, reason: 'the household bag');
      expect(canTickBag(teen, memberA), isFalse);
      expect(canTickBag((id: memberA, role: 'adult'), memberB), isTrue);
      expect(canTickBag((id: memberA, role: 'viewer'), memberA), isFalse);
    });

    test('hazard checks: tick, untick, clear the season', () async {
      await repo.setCheck('typhoon', 'water', true);
      await repo.setCheck('typhoon', 'charge', true);
      await repo.setCheck('flood', 'power', false);
      var checks = await repo.watchChecks().first;
      expect(checks, hasLength(2), reason: 'unticking something never ticked writes nothing');
      final water = checks.firstWhere((c) => c.item == 'water');
      expect(water.id, emergencyCheckId(householdId, 'typhoon', 'water'));
      expect(water.doneBy, memberA);

      await repo.setCheck('typhoon', 'water', false);
      checks = await repo.watchChecks().first;
      expect(checks.firstWhere((c) => c.item == 'water').done, isFalse);
      expect(checks.firstWhere((c) => c.item == 'water').doneBy, isNull);
      await repo.clearChecks('typhoon');
      expect((await repo.watchChecks().first).where((c) => c.done), isEmpty);
    });

    test('check-ins: the latest counts for 24 hours, help listed', () async {
      final members = [member(memberA, 'Ana', 'owner'), member(memberB, 'Ben', 'teen')];
      await repo.checkIn(helpStatus, note: 'stuck at school');
      now = now.add(const Duration(hours: 1));
      await repo.checkIn(safeStatus);
      var board = CheckinBoard(members, await repo.watchCheckins().first, now);
      expect(board.current(memberA)!.status, safeStatus);
      expect(board.safeCount, 1);
      expect(board.needHelp, isEmpty);
      expect(board.active, isTrue);

      final b = EmergencyRepository(
        db,
        writer(db, identity(memberId: memberB, deviceId: deviceB)),
        now: () => now,
      );
      await b.checkIn(helpStatus, note: 'flooded road');
      board = CheckinBoard(members, await repo.watchCheckins().first, now);
      expect(board.needHelp.single.name, 'Ben');

      board = CheckinBoard(members, await repo.watchCheckins().first, now.add(const Duration(hours: 25)));
      expect(board.active, isFalse);
      expect(board.latest[memberA]!.status, safeStatus, reason: 'still shown as the last check-in');
    });
  });

  test('offline on two phones: both check-ins and both ticks arrive', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final a = EmergencyRepository(dbA, wA);
    final b = EmergencyRepository(dbB, wB);
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

    await a.checkIn(safeStatus);
    await b.checkIn(helpStatus);
    await a.setCheck('earthquake', 'drill', true);
    await b.setCheck('earthquake', 'drill', true);
    await b.setCheck('earthquake', 'bedside', true);
    await a.savePlan(meetingPoint: 'Covered court');
    await b.savePlan(evacuationCenter: 'Elementary school');
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final (repo, db) in [(a, dbA), (b, dbB)]) {
      expect(await repo.watchCheckins().first, hasLength(2));
      final checks = await repo.watchChecks().first;
      expect(checks, hasLength(2), reason: 'the same tick on two phones is one row');
      expect(checks.every((c) => c.done), isTrue);
      expect(await db.select(db.emergencyPlans).get(), hasLength(1));
    }
    final plan = (await b.watchPlan().first)!;
    expect(plan.evacuationCenter, 'Elementary school');
    expect(plan.meetingPoint, 'Covered court', reason: "the other phone's blank does not clear it");
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 15 database adds the emergency tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v15 = AppDatabase(NativeDatabase(file));
    await v15.customStatement('SELECT 1');
    for (final t in ['emergency_contacts', 'emergency_plans', 'go_bag_items', 'emergency_checks', 'safety_checkins']) {
      await v15.customStatement('DROP TABLE $t');
    }
    await v15.customStatement('PRAGMA user_version = 15');
    await v15.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = EmergencyRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.checkIn(safeStatus);
    await repo.addBagItem(null, 'Water');
    expect(await repo.watchCheckins().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
