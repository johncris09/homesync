import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/chores/chores_repository.dart';

import '../app_test.dart' as app;
import '../support/fake_server.dart';
import '../support/test_db.dart';
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  group('board and repository', () {
    late AppDatabase db;
    late ChoresRepository repo;
    var now = DateTime(2026, 11, 26, 9); // a Thursday

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 11, 26, 9);
      repo = ChoresRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    Future<ChoreBoard> board({String? me = memberA}) async =>
        ChoreBoard(await repo.watchChores().first, await repo.watchCompletions().first, now, me: me);

    test('today has daily chores, today\'s weekly ones and once-chores due or overdue', () async {
      await repo.addChore(name: 'Dishes');
      await repo.addChore(name: 'Laundry', repeat: 'weekly', weekday: DateTime.thursday);
      await repo.addChore(name: 'Trash', repeat: 'weekly', weekday: DateTime.saturday);
      await repo.addChore(name: 'Fix gate', repeat: 'once', dueOn: DateTime(2026, 11, 20));
      await repo.addChore(name: 'Pay tuition', repeat: 'once', dueOn: DateTime(2026, 11, 30));

      final b = await board();
      expect(b.today.map((t) => t.chore.name), ['Dishes', 'Fix gate', 'Laundry']);
      expect(b.today.firstWhere((t) => t.chore.name == 'Fix gate').overdueSince, DateTime(2026, 11, 20));
      expect(b.upcoming.map((u) => (u.chore.name, u.on.day)), [('Trash', 28), ('Pay tuition', 30)]);
      expect(b.left, 3);
    });

    test('marking done, mine first, and undo only by the doer', () async {
      final dishes = await repo.addChore(name: 'Dishes', assignedTo: memberB);
      await repo.addChore(name: 'Sweep', assignedTo: memberA);
      var b = await board();
      expect(b.today.first.chore.name, 'Sweep', reason: 'mine first');
      expect(b.mineLeft, 1);

      final other = ChoresRepository(
        db,
        writer(db, identity(memberId: memberB, deviceId: deviceB)),
        now: () => now,
      );
      await other.markDone(b.today.firstWhere((t) => t.chore.id == dishes).chore);
      b = await board();
      final done = b.today.firstWhere((t) => t.chore.id == dishes);
      expect(done.isDone, isTrue);
      expect(done.done.single.memberId, memberB);
      expect(b.today.last.chore.id, dishes, reason: 'done ones go last');
      expect(b.left, 1);
      expect(repo.canUndo(done.done.single), isFalse);
      expect(() => repo.undo(done.done.single), throwsStateError);

      await other.undo(done.done.single);
      expect((await board()).left, 2);
    });

    test('a daily chore done yesterday is open again today', () async {
      final id = await repo.addChore(name: 'Dishes');
      final chore = (await repo.watchChores().first).single;
      now = DateTime(2026, 11, 25, 20);
      await repo.markDone(chore);
      now = DateTime(2026, 11, 26, 7);
      final b = await board();
      expect(b.today.single.chore.id, id);
      expect(b.today.single.isDone, isFalse);
    });

    test('a once-chore done on an earlier day disappears', () async {
      await repo.addChore(name: 'Fix gate', repeat: 'once', dueOn: DateTime(2026, 11, 20));
      final chore = (await repo.watchChores().first).single;
      now = DateTime(2026, 11, 22);
      await repo.markDone(chore);
      now = DateTime(2026, 11, 26);
      final b = await board();
      expect(b.today, isEmpty);
      expect(b.upcoming, isEmpty);
    });

    test('switching repeat clears the other fields', () async {
      await repo.addChore(name: 'Trash', repeat: 'weekly', weekday: 6);
      final c = (await repo.watchChores().first).single;
      await repo.editChore(c, name: 'Trash', repeat: 'daily');
      final after = (await repo.watchChores().first).single;
      expect(after.repeat, 'daily');
      expect(after.weekday, isNull);
    });
  });

  test('two people do the same chore offline: both completions are kept', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final now = DateTime(2026, 11, 26, 9);
    final a = ChoresRepository(dbA, wA, now: () => now);
    final b = ChoresRepository(dbB, wB, now: () => now);
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

    await a.addChore(name: 'Dishes');
    await syncA.sync();
    await syncB.sync();
    await a.markDone((await a.watchChores().first).single);
    await b.markDone((await b.watchChores().first).single);
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final repo in [a, b]) {
      final board = ChoreBoard(await repo.watchChores().first, await repo.watchCompletions().first, now);
      expect(board.today.single.done.map((x) => x.memberId).toSet(), {memberA, memberB});
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 3 database adds the chore tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v4 = AppDatabase(NativeDatabase(file));
    await v4.customStatement('SELECT 1');
    await v4.customStatement('DROP TABLE chores');
    await v4.customStatement('DROP TABLE chore_completions');
    // Also undo version 9 (multi-day events).
    await v4.customStatement('ALTER TABLE events DROP COLUMN "ends_on"');
    await v4.customStatement('ALTER TABLE events DROP COLUMN "color"');
    await v4.customStatement('PRAGMA user_version = 3');
    await v4.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = ChoresRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.addChore(name: 'Dishes');
    await repo.markDone((await repo.watchChores().first).single);
    expect(await repo.watchCompletions().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });

  testWidgets('adult adds a chore for the helper', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await s.writer.insert('members', {'name': 'Ate Joy', 'role': 'helper'}, id: helper.memberId);
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.text('Nothing today'), findsOneWidget);

    await tapText(tester, 'Chores');
    await tester.tap(find.text('Add chore'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('chore-name')), 'Wash the dishes');
    await tapText(tester, 'Ate Joy');
    await tapText(tester, 'Save');
    expect(find.text('1 left today'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('helper sees the chore, can tick their own, and undo it', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await s.writer.insert('members', {'name': 'Ate Joy', 'role': 'helper'}, id: helper.memberId);
      final mama = ChoresRepository(s.db, writer(s.db, identity(memberId: app.me.memberId, deviceId: app.me.deviceId)));
      await mama.addChore(name: 'Wash the dishes', assignedTo: helper.memberId);
      await mama.addChore(name: 'Pay the rent', assignedTo: app.me.memberId);
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.text('1 is yours today'), findsOneWidget);

    await tapText(tester, 'Chores');
    expect(find.text('Add chore'), findsNothing, reason: 'only adults manage chores');
    final dishes = find.ancestor(of: find.text('Wash the dishes'), matching: find.byType(ListTile));
    final rent = find.ancestor(of: find.text('Pay the rent'), matching: find.byType(ListTile));
    expect(tester.widget<IconButton>(find.descendant(of: rent, matching: find.byType(IconButton))).onPressed, isNull);

    await tester.tap(find.descendant(of: dishes, matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(find.text('Done by Ate Joy'), findsOneWidget);
    expect(find.text('1 left today'), findsOneWidget);

    await tester.tap(find.descendant(of: dishes, matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(find.text('2 left today'), findsOneWidget);
    await app.finish(tester, s);
  });
}
