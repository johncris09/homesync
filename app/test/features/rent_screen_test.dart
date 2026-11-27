import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

void main() {
  testWidgets('adult adds a unit and tenant, records part of the rent, waives the rest; income shows in Budget', (
    tester,
  ) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('No rentals yet'), findsOneWidget, reason: 'home tile');

    await tapText(tester, 'Rent');
    expect(find.text('No rentals yet'), findsOneWidget, reason: 'header');
    await tapText(tester, 'Add unit');
    await tester.enterText(find.byKey(const Key('unit-name')), 'Room 2');
    await tapText(tester, 'Save');

    // Straight on to the tenant.
    expect(find.text('Add tenant'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('tenant-name')), 'Jun');
    await tester.enterText(find.byKey(const Key('tenant-phone')), '0917 555 0101');
    await tester.enterText(find.byKey(const Key('tenant-rent')), '3500');
    await tester.enterText(find.byKey(const Key('tenant-due-day')), '40');
    await tester.enterText(find.byKey(const Key('tenant-deposit')), '7000');
    await tapText(tester, 'Save');
    expect(find.text('Enter a day from 1 to 31'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('tenant-due-day')), '1');
    await tapText(tester, 'Save');

    expect(find.text('₱3,500 to collect'), findsOneWidget);
    expect(find.text('Room 2 · Jun'), findsOneWidget);

    // Part of it, by GCash; the amount starts at what is owed.
    await tester.tap(find.byKey(const Key('record-payment')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '3500'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('payment-amount')), '2000');
    await tapText(tester, 'GCash');
    await tapText(tester, 'Save');
    expect(find.text('₱1,500 to collect'), findsOneWidget);
    expect(find.textContaining('₱1,500 left of ₱3,500'), findsOneWidget);

    // Waive the rest from the tenant's sheet.
    await tapText(tester, 'Room 2 · Jun');
    expect(find.text('Deposit ₱7,000'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    await tapText(tester, 'Waive rent');
    expect(find.widgetWithText(TextField, '1500'), findsOneWidget);
    await tapText(tester, 'Save');
    expect(find.byKey(const Key('lease-status')), findsOneWidget);
    expect(find.text('Waived'), findsOneWidget);
    expect(find.textContaining('GCash'), findsWidgets);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();
    expect(find.text('All paid'), findsOneWidget, reason: 'header');
    expect(find.text('Paid this month'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('All paid this month'), findsOneWidget, reason: 'home tile');
    await tapText(tester, 'Budget');
    expect(find.text('+₱2,000.00'), findsOneWidget, reason: 'only money received, not the waived part');
    await app.finish(tester, s);
  });

  testWidgets('non-adults do not get rent', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Rent'), findsNothing);
    await app.finish(tester, s);
  });
}
