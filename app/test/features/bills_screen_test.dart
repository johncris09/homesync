import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

void main() {
  testWidgets('adult adds a monthly bill, pays it, and it shows in Budget', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Nothing left to pay this month'), findsOneWidget);

    await tapText(tester, 'Bills & subscriptions');
    expect(find.text('All paid'), findsOneWidget);

    // Add Meralco, due today, ₱3,000 (a guess).
    await tester.tap(find.text('Add bill'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Save');
    expect(find.text('Enter a name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('bill-name')), 'Meralco');
    await tester.enterText(find.byKey(const Key('bill-amount')), '3000');
    await tapText(tester, 'Save');
    expect(find.text('₱3,000 to pay'), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);

    // Pay the real amount.
    await tapText(tester, 'Meralco');
    await tester.enterText(find.byKey(const Key('pay-amount')), '3,240.50');
    await tapText(tester, 'Mark paid');
    expect(find.text('Paid recently'), findsOneWidget);
    expect(find.textContaining('Next: Meralco'), findsOneWidget, reason: "next month's bill was added");

    // Undo is offered to the payer.
    await tapText(tester, '₱3,240.50');
    expect(find.text('Undo paid'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();

    // The payment is in the Budget ledger.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tapText(tester, 'Budget');
    expect(find.text('Meralco'), findsOneWidget);
    expect(find.text('−₱3,240.50'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('subscriptions: add, see the monthly total, pay', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Bills & subscriptions');
    await tapText(tester, 'Subscriptions');
    expect(find.text('Add subscription'), findsOneWidget);

    await tester.tap(find.text('Add subscription'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sub-name')), 'Netflix');
    await tester.enterText(find.byKey(const Key('sub-price')), '549');
    await tapText(tester, 'Save');
    expect(find.text('₱549 a month in subscriptions'), findsOneWidget);
    expect(find.text('₱549 to pay'), findsOneWidget, reason: 'due today counts this month');

    await tapText(tester, 'Netflix');
    await tapText(tester, 'Mark paid');
    expect(find.text('All paid'), findsOneWidget);
    expect(find.textContaining('Monthly · Due'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('non-adults do not get bills', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Bills & subscriptions'), findsNothing);
    await app.finish(tester, s);
  });
}
