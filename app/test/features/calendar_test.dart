import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/features/bills/bills_repository.dart';
import 'package:homesync/features/calendar/calendar_repository.dart';
import 'package:homesync/shared/dates.dart';

import '../app_test.dart' as app;
import '../support/test_db.dart';
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

const memberA = '01900000-0000-7000-8000-0000000000aa';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';

const viewer = Profile(
  memberId: '01900000-0000-7000-8000-0000000000ff',
  name: 'Lolo',
  role: 'viewer',
  deviceId: 'f0000000-0000-7000-8000-00000000000f',
);

CalendarEvent event(String startsOn, {String repeat = 'none', String title = 'x', String? at}) => CalendarEvent(
  id: title,
  householdId: householdId,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  title: title,
  startsOn: startsOn,
  startTime: at,
  repeat: repeat,
);

void main() {
  group('occurrences', () {
    test('once: only on its date', () {
      final e = event('2026-12-04');
      expect(occurrences(e, DateTime(2026, 12, 1), DateTime(2026, 12, 31)), [DateTime(2026, 12, 4)]);
      expect(occurrences(e, DateTime(2026, 12, 5), DateTime(2026, 12, 31)), isEmpty);
    });

    test('weekly: every 7 days from the first date', () {
      final e = event('2026-11-05', repeat: 'weekly');
      expect(occurrences(e, DateTime(2026, 11, 20), DateTime(2026, 12, 10)), [
        DateTime(2026, 11, 26),
        DateTime(2026, 12, 3),
        DateTime(2026, 12, 10),
      ]);
      expect(occurrences(e, DateTime(2026, 10, 1), DateTime(2026, 11, 12)), [
        DateTime(2026, 11, 5),
        DateTime(2026, 11, 12),
      ], reason: 'nothing before the first date');
    });

    test('monthly keeps the day, clamped to short months', () {
      final e = event('2027-01-31', repeat: 'monthly');
      expect(occurrences(e, DateTime(2027, 2, 1), DateTime(2027, 4, 30)), [
        DateTime(2027, 2, 28),
        DateTime(2027, 3, 31),
        DateTime(2027, 4, 30),
      ]);
    });

    test('yearly: a Feb 29 birthday is on Feb 28 in other years', () {
      final e = event('2028-02-29', repeat: 'yearly');
      expect(occurrences(e, DateTime(2029, 1, 1), DateTime(2029, 12, 31)), [DateTime(2029, 2, 28)]);
      expect(occurrences(e, DateTime(2032, 1, 1), DateTime(2032, 12, 31)), [DateTime(2032, 2, 29)]);
      expect(occurrences(event('1960-05-10', repeat: 'yearly'), DateTime(2026, 11, 26), DateTime(2027, 6, 1)), [
        DateTime(2027, 5, 10),
      ]);
    });
  });

  test('agenda: all-day first, then by time; unpaid bills and subscriptions on their dates', () {
    final today = DateTime(2026, 11, 26);
    Bill bill(String name, String due, {bool paid = false}) => Bill(
      id: name,
      householdId: householdId,
      createdAt: today,
      updatedAt: today,
      name: name,
      amountMinor: 100,
      currency: 'PHP',
      dueOn: due,
      isPaid: paid,
    );
    final agenda = Agenda(
      [
        event('2026-11-26', title: 'Dentist', at: '15:00'),
        event('2026-11-26', title: 'Market', at: '07:30'),
        event('2026-11-26', title: 'Payday'),
        event('1960-11-28', title: 'Lola', repeat: 'yearly'),
      ],
      today,
      DateTime(2026, 12, 26),
      bills: [bill('Meralco', '2026-11-26'), bill('Water', '2026-11-27', paid: true)],
      subscriptions: [
        Subscription(
          id: 's',
          householdId: householdId,
          createdAt: today,
          updatedAt: today,
          name: 'Netflix',
          priceMinor: 54900,
          currency: 'PHP',
          cycle: 'monthly',
          nextDueOn: '2026-12-01',
        ),
      ],
    );
    expect(agenda.on(today).map((i) => i.title), ['Meralco', 'Payday', 'Market', 'Dentist']);
    expect(agenda.on(DateTime(2026, 11, 27)), isEmpty, reason: 'paid bills are left out');
    expect(agenda.daysAfter(today).map((d) => (d.$1.day, d.$2.single.title)), [(28, 'Lola'), (1, 'Netflix')]);
  });

  group('repository', () {
    late AppDatabase db;
    late CalendarRepository repo;

    setUp(() {
      db = memoryDb();
      repo = CalendarRepository(db, writer(db, identity(memberId: memberA, deviceId: deviceA)));
    });
    tearDown(() => db.close());

    test('adding records who added it; editing saves only what changed', () async {
      await repo.addEvent(
        title: ' Dentist ',
        startsOn: DateTime(2026, 12, 4),
        startTime: '15:00',
        endTime: '16:00',
        location: '  ',
      );
      final e = (await repo.watchEvents().first).single;
      expect(e.title, 'Dentist');
      expect(e.createdBy, memberA);
      expect(e.location, isNull);
      expect(e.repeat, 'none');

      await db.delete(db.outbox).go();
      await repo.editEvent(e, title: 'Dentist', startsOn: DateTime(2026, 12, 4), repeat: 'none');
      final op = (await db.select(db.outbox).get()).single;
      expect(op.fields, contains('"start_time":null'));
      expect(op.fields, contains('"end_time":null'), reason: 'all day drops the end time');
      expect(op.fields, isNot(contains('title')));

      await db.delete(db.outbox).go();
      final after = (await repo.watchEvents().first).single;
      await repo.editEvent(after, title: 'Dentist', startsOn: DateTime(2026, 12, 4), repeat: 'none');
      expect(await db.select(db.outbox).get(), isEmpty, reason: 'nothing changed');
    });
  });

  test('upgrading a version 4 database adds events', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v5 = AppDatabase(NativeDatabase(file));
    await v5.customStatement('SELECT 1');
    await v5.customStatement('DROP TABLE events');
    await v5.customStatement('PRAGMA user_version = 4');
    await v5.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = CalendarRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.addEvent(title: 'Dentist', startsOn: DateTime(2026, 12, 4));
    expect(await repo.watchEvents().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });

  test('upgrading a version 6 database adds ends_on to events', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v6 = AppDatabase(NativeDatabase(file));
    await v6.customStatement('SELECT 1');
    await v6.customStatement('ALTER TABLE events DROP COLUMN "ends_on"');
    await v6.customStatement('PRAGMA user_version = 6');
    await v6.close();

    final reopened = AppDatabase(NativeDatabase(file));
    await reopened
        .into(reopened.events)
        .insert(
          EventsCompanion.insert(
            id: 'x',
            householdId: householdId,
            title: 'Retreat',
            startsOn: '2026-12-04',
            endsOn: const Value('2026-12-06'),
          ),
        );
    expect((await reopened.select(reopened.events).getSingle()).endsOn, '2026-12-06');
    await reopened.close();
    await dir.delete(recursive: true);
  });

  testWidgets('adult adds an event today and sees bills on the calendar', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final today = DateTime.now();
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await BillsRepository(
        s.db,
        s.writer,
      ).addBill(name: 'Meralco', amountMinor: 300000, dueOn: DateTime(today.year, today.month, today.day + 1));
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.textContaining('Next: Meralco'), findsOneWidget);

    await tapText(tester, 'Calendar');
    expect(find.text('Free today'), findsOneWidget);
    expect(find.text('Next: Meralco, Tomorrow'), findsOneWidget);

    await tester.tap(find.text('Add event'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Save');
    expect(find.text('Enter a title.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('event-title')), 'Family dinner');
    await tester.enterText(find.byKey(const Key('event-location')), "Lola's house");
    await tapText(tester, 'Save');
    expect(find.text('1 today'), findsOneWidget);
    expect(find.text("All day · Lola's house"), findsOneWidget);

    // Tomorrow has the bill.
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    if (tomorrow.month != today.month) await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('day-${isoDate(tomorrow)}')));
    await tester.pumpAndSettle();
    expect(find.text('Bill due · ₱3,000.00'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('a helper adds and edits their own event, and only views the others', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await s.writer.insert('members', {'name': 'Ate Joy', 'role': 'helper'}, id: helper.memberId);
      final mama = CalendarRepository(
        s.db,
        writer(s.db, identity(memberId: app.me.memberId, deviceId: app.me.deviceId)),
      );
      await mama.addEvent(title: 'PTA meeting', startsOn: DateTime.now(), startTime: '08:00');
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.text('Bills & subscriptions'), findsNothing);
    expect(find.text('1 thing today'), findsOneWidget);

    await tapText(tester, 'Calendar');
    await tapText(tester, 'PTA meeting');
    expect(find.text('Added by Mama'), findsOneWidget);
    expect(find.text('Save'), findsNothing, reason: "not theirs to change");
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add event'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('event-title')), 'Day off');
    await tapText(tester, 'Save');
    expect(find.text('2 today'), findsOneWidget);
    await tapText(tester, 'Day off');
    expect(find.text('Edit event'), findsOneWidget);
    await tapText(tester, 'Remove event');
    expect(find.text('1 today'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('viewers read the calendar but cannot add', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, viewer);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Calendar');
    expect(find.text('Free today'), findsOneWidget);
    expect(find.text('Add event'), findsNothing);
    await app.finish(tester, s);
  });
}
