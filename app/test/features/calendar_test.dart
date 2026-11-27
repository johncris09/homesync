import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/features/bills/bills_repository.dart';
import 'package:homesync/app/theme.dart';
import 'package:homesync/features/calendar/calendar_repository.dart';
import 'package:homesync/features/calendar/event_colors.dart';
import 'package:homesync/shared/dates.dart';
import 'package:intl/intl.dart';

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

CalendarEvent event(
  String startsOn, {
  String repeat = 'none',
  String title = 'x',
  String? at,
  String? until,
  String? endsOn,
}) => CalendarEvent(
  id: title,
  householdId: householdId,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  title: title,
  startsOn: startsOn,
  endsOn: endsOn,
  startTime: at,
  endTime: until,
  repeat: repeat,
);

/// Tomorrow is in the same week row and month (weeks start on Sunday in tests),
/// so a band from [d] joins to it.
bool joinsTomorrow(DateTime d) =>
    d.weekday != DateTime.saturday && DateTime(d.year, d.month, d.day + 1).month == d.month;

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

  group('multi-day', () {
    test('a once event is on every day of its range and comes up once', () {
      final agenda = Agenda(
        [event('2026-12-01', endsOn: '2026-12-03', title: 'Retreat')],
        DateTime(2026, 11, 26),
        DateTime(2026, 12, 31),
      );
      for (final d in [1, 2, 3]) {
        final i = agenda.on(DateTime(2026, 12, d)).single;
        expect(i.title, 'Retreat');
        expect((i.spanStart, i.spanEnd), (DateTime(2026, 12, 1), DateTime(2026, 12, 3)));
        expect(i.allDay, isTrue);
        expect(i.continues, d > 1);
      }
      expect(agenda.on(DateTime(2026, 12, 4)), isEmpty);
      expect(agenda.daysAfter(DateTime(2026, 11, 26)).map((d) => d.$1.day), [1], reason: 'listed once, on day 1');
      expect(agenda.daysAfter(DateTime(2026, 12, 1)), isEmpty, reason: 'already started');
    });

    test('a timed range starts on the first day and ends on the last', () {
      final agenda = Agenda(
        [event('2026-12-04', endsOn: '2026-12-06', at: '18:00', until: '15:00')],
        DateTime(2026, 12, 1),
        DateTime(2026, 12, 31),
      );
      final days = [
        for (final d in [4, 5, 6]) agenda.on(DateTime(2026, 12, d)).single,
      ];
      expect([for (final i in days) (i.startTime, i.endTime)], [('18:00', null), (null, null), (null, '15:00')]);
      expect(days.every((i) => i.multiDay), isTrue);
    });

    test('a repeat copies the span, including one that began before the range', () {
      final weekend = event('2026-11-06', endsOn: '2026-11-08', repeat: 'weekly');
      final agenda = Agenda([weekend], DateTime(2026, 11, 22), DateTime(2026, 11, 30));
      // Fri Nov 20 – Sun Nov 22 started before the range; Fri 27 – Sun 29.
      expect(
        [
          for (var d = 22; d <= 30; d++)
            if (agenda.on(DateTime(2026, 11, d)).isNotEmpty) d,
        ],
        [22, 27, 28, 29],
      );
      expect(agenda.on(DateTime(2026, 11, 22)).single.spanStart, DateTime(2026, 11, 20));
      expect(spanDays(weekend), 2);
    });
  });

  group('band lanes', () {
    final from = DateTime(2026, 11, 1);
    final to = DateTime(2026, 11, 30);
    String? at(BandLayout l, int day, int lane) => l.on(DateTime(2026, 11, day))[lane]?.title;

    test('overlapping ranges stack, and each keeps its lane on every day', () {
      final agenda = Agenda(
        [
          event('2026-11-01', endsOn: '2026-11-03', title: 'Retreat'),
          event('2026-11-02', endsOn: '2026-11-05', title: 'Fiesta'),
          event('2026-11-02', title: 'Dentist'),
        ],
        from,
        to,
      );
      final layout = BandLayout(agenda, from, to);
      expect(layout.lanes, 2);
      expect([at(layout, 1, 0), at(layout, 1, 1)], ['Retreat', null]);
      expect([at(layout, 3, 0), at(layout, 3, 1)], ['Retreat', 'Fiesta']);
      expect([at(layout, 4, 0), at(layout, 4, 1)], [null, 'Fiesta'], reason: 'Fiesta stays in its lane');
      expect(
        layout.on(DateTime(2026, 11, 2)).whereType<CalendarItem>().map((i) => i.title),
        isNot(contains('Dentist')),
      );
      expect(BandLayout.same(layout.on(DateTime(2026, 11, 3))[1], layout.on(DateTime(2026, 11, 4))[1]), isTrue);
    });

    test('a freed lane is reused; one range keeps a single full lane', () {
      final layout = BandLayout(
        Agenda(
          [
            event('2026-11-01', endsOn: '2026-11-03', title: 'A'),
            event('2026-11-02', endsOn: '2026-11-04', title: 'B'),
            event('2026-11-05', endsOn: '2026-11-06', title: 'C'),
          ],
          from,
          to,
        ),
        from,
        to,
      );
      expect(layout.lanes, 2);
      expect(at(layout, 5, 0), 'C');
      expect(BandLayout(Agenda([event('2026-11-01', endsOn: '2026-11-03')], from, to), from, to).lanes, 1);
    });

    test('at most three lanes; the rest are counted', () {
      final layout = BandLayout(
        Agenda(
          [
            for (final t in ['A', 'B', 'C', 'D']) event('2026-11-10', endsOn: '2026-11-12', title: t),
          ],
          from,
          to,
        ),
        from,
        to,
      );
      expect(layout.lanes, 3);
      expect(layout.hiddenOn(DateTime(2026, 11, 11)), 1);
      expect(layout.hiddenOn(DateTime(2026, 11, 13)), 0);
    });
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

    test('a colour is saved by name; the default colour is stored as null', () async {
      await repo.addEvent(title: 'Fair', startsOn: DateTime(2026, 12, 4), color: 'dagat');
      var e = (await repo.watchEvents().first).single;
      expect(e.color, 'dagat');

      await db.delete(db.outbox).go();
      await repo.editEvent(e, title: 'Fair', startsOn: DateTime(2026, 12, 4), repeat: 'none', color: 'ube');
      e = (await repo.watchEvents().first).single;
      expect(e.color, isNull);
      expect((await db.select(db.outbox).get()).single.fields, contains('"color":null'));
    });

    test('a range saves ends_on; one day or a span too long for the repeat is fixed', () async {
      final id = await repo.addEvent(title: 'Retreat', startsOn: DateTime(2026, 12, 4), endsOn: DateTime(2026, 12, 6));
      var e = (await repo.watchEvents().first).single;
      expect(e.endsOn, '2026-12-06');

      await repo.editEvent(
        e,
        title: 'Retreat',
        startsOn: DateTime(2026, 12, 4),
        endsOn: DateTime(2026, 12, 20),
        repeat: 'weekly',
      );
      e = (await repo.watchEvents().first).single;
      expect(e.endsOn, '2026-12-10', reason: 'a weekly event lasts at most 7 days');

      await repo.editEvent(
        e,
        title: 'Retreat',
        startsOn: DateTime(2026, 12, 4),
        endsOn: DateTime(2026, 12, 4),
        repeat: 'weekly',
      );
      e = (await repo.watchEvents().first).single;
      expect(e.id, id);
      expect(e.endsOn, isNull, reason: 'same day = one-day event');
    });
  });

  test('upgrading a version 4 database adds events', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v5 = AppDatabase(NativeDatabase(file));
    await v5.customStatement('SELECT 1');
    await v5.customStatement('DROP TABLE events');
    await v5.customStatement('ALTER TABLE grocery_items DROP COLUMN cleared_at'); // added in v7
    await v5.customStatement('ALTER TABLE grocery_items DROP COLUMN planned_on'); // added in v8
    for (final t in ['vault_keys', 'vault_items', 'vault_files', 'vault_blobs']) {
      await v5.customStatement('DROP TABLE "$t"'); // added in v12
    }
    await v5.customStatement('DROP TABLE vehicles'); // added in v11
    await v5.customStatement('DROP TABLE vehicle_logs');
    await v5.customStatement('DROP TABLE health_profiles'); // added in v13
    await v5.customStatement('DROP TABLE medicines');
    await v5.customStatement('DROP TABLE med_doses');
    await v5.customStatement('DROP TABLE checkups');
    await v5.customStatement('DROP TABLE rental_units'); // added in v14
    await v5.customStatement('DROP TABLE leases');
    await v5.customStatement('DROP TABLE rent_payments');
    await v5.customStatement('DROP TABLE inventory_items'); // added in v15
    for (final t in ['emergency_contacts', 'emergency_plans', 'go_bag_items', 'emergency_checks', 'safety_checkins']) {
      await v5.customStatement('DROP TABLE $t'); // added in v16
    }
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
    await v6.customStatement('ALTER TABLE events DROP COLUMN "color"');
    await v6.customStatement('ALTER TABLE grocery_items DROP COLUMN cleared_at'); // added in v7
    await v6.customStatement('ALTER TABLE grocery_items DROP COLUMN planned_on'); // added in v8
    for (final t in ['vault_keys', 'vault_items', 'vault_files', 'vault_blobs']) {
      await v6.customStatement('DROP TABLE "$t"'); // added in v12
    }
    await v6.customStatement('DROP TABLE vehicles'); // added in v11
    await v6.customStatement('DROP TABLE vehicle_logs');
    await v6.customStatement('DROP TABLE health_profiles'); // added in v13
    await v6.customStatement('DROP TABLE medicines');
    await v6.customStatement('DROP TABLE med_doses');
    await v6.customStatement('DROP TABLE checkups');
    await v6.customStatement('DROP TABLE rental_units'); // added in v14
    await v6.customStatement('DROP TABLE leases');
    await v6.customStatement('DROP TABLE rent_payments');
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

  test('upgrading a version 9 database adds color to events', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v9 = AppDatabase(NativeDatabase(file));
    await v9.customStatement('SELECT 1');
    await v9.customStatement('ALTER TABLE events DROP COLUMN "color"');
    for (final t in ['vault_keys', 'vault_items', 'vault_files', 'vault_blobs']) {
      await v9.customStatement('DROP TABLE "$t"'); // added in v12
    }
    await v9.customStatement('DROP TABLE vehicles'); // added in v11
    await v9.customStatement('DROP TABLE vehicle_logs');
    await v9.customStatement('DROP TABLE health_profiles'); // added in v13
    await v9.customStatement('DROP TABLE medicines');
    await v9.customStatement('DROP TABLE med_doses');
    await v9.customStatement('DROP TABLE checkups');
    await v9.customStatement('DROP TABLE rental_units'); // added in v14
    await v9.customStatement('DROP TABLE leases');
    await v9.customStatement('DROP TABLE rent_payments');
    await v9.customStatement('PRAGMA user_version = 9');
    await v9.close();

    final reopened = AppDatabase(NativeDatabase(file));
    await reopened
        .into(reopened.events)
        .insert(
          EventsCompanion.insert(
            id: 'x',
            householdId: householdId,
            title: 'Fair',
            startsOn: '2026-12-04',
            color: const Value('dagat'),
          ),
        );
    expect((await reopened.select(reopened.events).getSingle()).color, 'dagat');
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

  testWidgets('adding a several-day event bands the month and comes up once with its range', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Calendar');

    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    await tester.tap(find.text('Add event'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('event-title')), 'Retreat');
    await tester.tap(find.byKey(const Key('event-several-days')));
    await tester.pumpAndSettle();
    expect(find.text('2 days'), findsOneWidget);
    await tapText(tester, 'Weekly');
    await tapText(tester, 'Save');

    final e = (await tester.runAsync(() => s.db.select(s.db.events).getSingle()))!;
    expect(e.endsOn, isoDate(DateTime(d.year, d.month, d.day + 1)));
    expect(find.text('1 today'), findsOneWidget);
    expect(find.byKey(Key('band-${isoDate(d)}-0')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(Key('band-${isoDate(d)}-0'))).width,
      tester.getSize(find.byKey(Key('day-${isoDate(d)}'))).width,
      reason: 'the band fills the cell so joined days meet',
    );
    if (joinsTomorrow(d)) {
      final join = find.descendant(of: find.byKey(Key('band-${isoDate(d)}-0')), matching: find.byType(ColoredBox));
      expect(tester.getSize(join.first).height, greaterThan(20), reason: 'the join to the next day is visible');
    }
    // Next week's copy comes up once, with its range.
    final next = DateTime(d.year, d.month, d.day + 7);
    final f = DateFormat.MMMd('en');
    expect(
      find.textContaining('${f.format(next)} – ${f.format(DateTime(next.year, next.month, next.day + 1))}'),
      findsOneWidget,
    );

    await app.finish(tester, s);
  });

  testWidgets('picking a colour paints the event and its days', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Calendar');

    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    await tester.tap(find.text('Add event'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('event-title')), 'School fair');
    expect(
      find.descendant(of: find.byKey(const Key('event-colour-ube')), matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('event-several-days')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('event-colour-dagat')));
    await tester.tap(find.byKey(const Key('event-colour-dagat')));
    await tester.pumpAndSettle();
    await tapText(tester, 'Save');

    expect((await tester.runAsync(() => s.db.select(s.db.events).getSingle()))!.color, 'dagat');
    final avatar = tester.widget<CircleAvatar>(
      find.descendant(of: find.widgetWithText(ListTile, 'School fair'), matching: find.byType(CircleAvatar)),
    );
    expect(avatar.backgroundColor, HomeColors.dagat);
    final pieces = find.descendant(of: find.byKey(Key('band-${isoDate(d)}-0')), matching: find.byType(Container));
    expect((tester.widget<Container>(pieces.first).decoration! as BoxDecoration).color, bandTint(HomeColors.dagat));
    if (joinsTomorrow(d)) {
      final join = find.descendant(of: find.byKey(Key('band-${isoDate(d)}-0')), matching: find.byType(ColoredBox));
      expect(tester.widget<ColoredBox>(join.first).color, bandTint(HomeColors.dagat));
    }
    await app.finish(tester, s);
  });

  testWidgets('overlapping ranges show stacked bands in their colours, and + for a fourth', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final t = DateTime.now();
    final d = DateTime(t.year, t.month, t.day);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      final repo = CalendarRepository(s.db, s.writer);
      for (final (title, color) in [('Retreat', 'rosas'), ('Fiesta', 'dagat'), ('Camp', 'dahon'), ('Visit', 'tubig')]) {
        await repo.addEvent(title: title, startsOn: d, endsOn: DateTime(d.year, d.month, d.day + 1), color: color);
      }
      return s;
    }))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Calendar');
    Color laneColor(int lane) =>
        (tester
                    .widget<Container>(
                      find
                          .descendant(of: find.byKey(Key('band-${isoDate(d)}-$lane')), matching: find.byType(Container))
                          .first,
                    )
                    .decoration!
                as BoxDecoration)
            .color!;
    // Same start and end: lanes by title (Camp, Fiesta, Retreat); Visit has none.
    expect(laneColor(0), bandTint(HomeColors.dahon, stacked: true));
    expect(laneColor(1), bandTint(HomeColors.dagat, stacked: true));
    expect(laneColor(2), bandTint(eventColor('rosas')!, stacked: true));
    expect(find.byKey(Key('band-${isoDate(d)}-3')), findsNothing);
    expect(find.byKey(Key('more-${isoDate(d)}')), findsOneWidget);
    expect(tester.getSize(find.byKey(Key('band-${isoDate(d)}-0'))).height, lessThan(10));
    await app.finish(tester, s);
  });

  testWidgets('a quiet week keeps a full band while a busy week stacks', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final t = DateTime.now();
    final d = DateTime(t.year, t.month, t.day);
    // Two weeks away, inside this month, so it is in another week row.
    final x = d.day <= 14 ? DateTime(d.year, d.month, d.day + 14) : DateTime(d.year, d.month, d.day - 14);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      final repo = CalendarRepository(s.db, s.writer);
      for (final title in ['A', 'B']) {
        await repo.addEvent(title: title, startsOn: d, endsOn: DateTime(d.year, d.month, d.day + 1));
      }
      await repo.addEvent(title: 'C', startsOn: x, endsOn: DateTime(x.year, x.month, x.day + 1));
      return s;
    }))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Calendar');
    expect(tester.getSize(find.byKey(Key('band-${isoDate(d)}-1'))).height, lessThan(13));
    expect(tester.getSize(find.byKey(Key('band-${isoDate(x)}-0'))).height, 26);
    await app.finish(tester, s);
  });

  testWidgets('a range too long for the repeat is not saved', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      final t = DateTime.now();
      await CalendarRepository(s.db, s.writer).addEvent(
        title: 'Fiesta week',
        startsOn: DateTime(t.year, t.month, t.day),
        endsOn: DateTime(t.year, t.month, t.day + 9),
      );
      return s;
    }))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Calendar');
    await tapText(tester, 'Fiesta week');
    expect(find.text('10 days'), findsOneWidget);
    await tapText(tester, 'Weekly');
    expect(find.text('Too long for this repeat: up to 7 days'), findsOneWidget);
    await tapText(tester, 'Save');
    expect(find.text('Edit event'), findsOneWidget, reason: 'still open');
    expect((await tester.runAsync(() => s.db.select(s.db.events).getSingle()))!.repeat, 'none');
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
