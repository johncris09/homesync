import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

void main() {
  testWidgets('adult adds a pawn ticket, renews it, redeems it, and the payments show in Budget', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Nothing owed'), findsOneWidget);

    await tapText(tester, 'Debts & loans');
    expect(find.text('No debts'), findsOneWidget);

    await tester.tap(find.text('Add debt'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Pawn ticket');
    expect(find.text('Amount received'), findsOneWidget, reason: 'labels follow the kind');
    await tapText(tester, 'Save');
    expect(find.text('Enter a name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('debt-name')), 'Gold ring');
    await tester.enterText(find.byKey(const Key('debt-principal')), '5000');
    await tapText(tester, 'Save');
    expect(find.text('₱5,000 owed'), findsOneWidget);
    expect(find.text('You owe'), findsOneWidget);

    // Renew: interest only, the balance stays.
    await tapText(tester, 'Gold ring');
    await tapText(tester, 'Record payment');
    await tester.enterText(find.byKey(const Key('debt-payment-amount')), '200');
    await tapText(tester, 'Interest only');
    await tapText(tester, 'Save');
    expect(find.text('₱5,000 left of ₱5,000'), findsOneWidget);
    expect(find.text('Interest'), findsOneWidget);

    // Redeem: paying the rest closes it.
    await tapText(tester, 'Record payment');
    await tester.enterText(find.byKey(const Key('debt-payment-amount')), '5000');
    await tapText(tester, 'Save');
    expect(find.text('₱0 left of ₱5,000'), findsOneWidget);
    expect(find.text('Reopen'), findsOneWidget, reason: 'the person who closed it can reopen it');
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();
    expect(find.text('No debts'), findsOneWidget);
    expect(find.text('Paid off'), findsOneWidget);
    expect(find.textContaining('Redeemed'), findsOneWidget);

    // Both payments are expenses in Budget.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tapText(tester, 'Budget');
    expect(find.text('−₱200.00'), findsOneWidget);
    expect(find.text('−₱5,000.00'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('money lent: paid back in part, more lent, shown as owed to you', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Debts & loans');

    await tester.tap(find.text('Add debt'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Money lent');
    await tester.enterText(find.byKey(const Key('debt-name')), 'Tito Ben');
    await tester.enterText(find.byKey(const Key('debt-principal')), '3000');
    await tapText(tester, 'Save');
    expect(find.text('₱3,000 owed to you'), findsOneWidget);
    expect(find.text('Owed to you'), findsOneWidget);

    await tapText(tester, 'Tito Ben');
    await tapText(tester, 'Got paid back');
    expect(find.text('Interest only'), findsNothing);
    await tester.enterText(find.byKey(const Key('debt-payment-amount')), '1000');
    await tapText(tester, 'Save');
    await tapText(tester, 'Lent more');
    await tester.enterText(find.byKey(const Key('debt-payment-amount')), '500');
    await tapText(tester, 'Save');
    expect(find.text('₱2,500 left of ₱3,000'), findsOneWidget);

    // Remove the extra by mistake: it is the recorder's own entry.
    await tester.tap(find.byTooltip('Remove this entry').first);
    await tester.pumpAndSettle();
    expect(find.text('₱2,000 left of ₱3,000'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('₱2,000 owed to you'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('non-adults do not get debts', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Debts & loans'), findsNothing);
    await app.finish(tester, s);
  });
}
