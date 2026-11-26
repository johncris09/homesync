import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/app_services.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/features/budget/budget_repository.dart';
import 'package:homesync/core/sync/outbox.dart';

import '../app_test.dart' as app;
import '../support/test_db.dart';

const helper = Profile(
  memberId: '01900000-0000-7000-8000-0000000000ee',
  name: 'Ate Joy',
  role: 'helper',
  deviceId: 'e0000000-0000-7000-8000-00000000000e',
);

Future<AppServices> open(MemorySecureStore store) async {
  final s = await app.services(store);
  await s.writer.insert('members', {'name': 'Mama', 'role': 'owner'}, id: app.me.memberId);
  return s;
}

void signedInAs(MemorySecureStore store, Profile p) {
  store.values['session'] = jsonEncode(
    Session(householdId: householdId, householdName: 'Manabo', isShared: false, main: p, active: p).toJson(),
  );
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.pumpAndSettle(); // lists fill in from streams and can shift
  await tester.ensureVisible(find.text(text).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('adult: set a budget, record spending, see what is left', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('₱0 spent this month'), findsOneWidget);

    await tapText(tester, 'Budget');
    expect(find.text('₱0 spent'), findsOneWidget);
    expect(find.text('Nothing recorded this month.'), findsOneWidget);

    // Budget for food.
    await tapText(tester, 'Set a monthly budget');
    await tapText(tester, 'Food & groceries');
    await tester.enterText(find.byKey(const Key('budget-limit')), 'abc');
    await tapText(tester, 'Save');
    expect(find.text('Enter an amount, e.g. 250 or 1,240.50.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('budget-limit')), '8,000');
    await tapText(tester, 'Save');
    expect(find.text('₱8,000 left'), findsOneWidget);

    // Spend ₱1,240.50 on food.
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Save');
    expect(find.text('Pick a category.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('entry-amount')), '1,240.50');
    await tapText(tester, 'Food & groceries');
    await tapText(tester, 'Save');

    expect(find.text('₱6,759.50 left'), findsOneWidget);
    expect(find.text('₱1,240.50 of ₱8,000'), findsOneWidget);
    expect(find.text('−₱1,240.50'), findsOneWidget);

    // Money in shows separately and doesn't change what's left.
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tapText(tester, 'In');
    await tester.enterText(find.byKey(const Key('entry-amount')), '25000');
    await tapText(tester, 'Save');
    expect(find.text('Money in this month: ₱25,000.00'), findsOneWidget);
    expect(find.text('₱6,759.50 left'), findsOneWidget);

    // Remove the expense.
    final row = find.ancestor(of: find.text('−₱1,240.50'), matching: find.byType(ListTile));
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    await tapText(tester, 'Remove');
    expect(find.text('₱8,000 left'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('helper records spending and sees only their own entries', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      // Someone else's entry, e.g. pulled onto the shared tablet.
      final mama = BudgetRepository(s.db, writerFor(s, app.me.memberId, app.me.deviceId));
      await mama.addEntry(amountMinor: 999900, category: 'utilities', occurredAt: DateTime.now());
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.text('Record an expense'), findsOneWidget);

    await tapText(tester, 'Budget');
    expect(find.text('₱0'), findsOneWidget);
    expect(find.text('Set a monthly budget'), findsNothing);
    expect(find.textContaining('9,999'), findsNothing);

    await tester.tap(find.text('Record expense'));
    await tester.pumpAndSettle();
    expect(find.text('In'), findsNothing, reason: 'only adults record money in');
    await tester.enterText(find.byKey(const Key('entry-amount')), '85');
    await tapText(tester, 'Transport');
    await tapText(tester, 'Save');
    expect(find.text('₱85'), findsOneWidget);
    expect(find.text('−₱85.00'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('viewers do not get the budget', (tester) async {
    final store = MemorySecureStore();
    signedInAs(
      store,
      const Profile(
        memberId: '01900000-0000-7000-8000-0000000000dd',
        name: 'Lola',
        role: 'viewer',
        deviceId: 'd0000000-0000-7000-8000-00000000000d',
      ),
    );
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Budget'), findsNothing);
    expect(find.text('Pantry & grocery'), findsOneWidget);
    await app.finish(tester, s);
  });
}

LocalWriter writerFor(AppServices s, String memberId, String deviceId) =>
    writer(s.db, identity(memberId: memberId, deviceId: deviceId));
