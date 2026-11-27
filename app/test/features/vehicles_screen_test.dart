import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

void main() {
  testWidgets('adult adds a car, PMS comes due by km, fuel is logged and shows in Budget', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('No vehicles yet'), findsOneWidget, reason: 'home tile');

    await tapText(tester, 'Vehicles');
    expect(find.text('No vehicles yet'), findsOneWidget, reason: 'header');
    await tapText(tester, 'Add vehicle');
    await tapText(tester, 'Save');
    expect(find.text('Enter a name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('vehicle-name')), 'Innova');
    await tester.enterText(find.byKey(const Key('vehicle-plate')), 'ABC 1234');
    await tester.enterText(find.byKey(const Key('vehicle-odometer-field')), '44000');
    await tester.enterText(find.byKey(const Key('vehicle-pms-km')), '44300');
    await tester.enterText(find.byKey(const Key('vehicle-every-km')), '5000');
    await tapText(tester, 'Save');

    expect(find.text('PMS in 300 km'), findsWidgets, reason: 'header and coming up');
    expect(find.text('ABC 1234 · 44,000 km'), findsOneWidget);

    // Fuel past the PMS reading: PMS is now overdue.
    await tester.tap(find.byKey(const Key('log-fuel')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cost-amount')), '2000');
    await tester.enterText(find.byKey(const Key('cost-odometer')), '44400');
    await tester.enterText(find.byKey(const Key('cost-litres')), '31.5');
    await tapText(tester, 'Save');
    expect(find.text('PMS 100 km past due'), findsWidgets);
    expect(find.text('Spent this month: ₱2,000'), findsOneWidget);

    // The PMS itself moves the next one 5,000 km on.
    await tapText(tester, 'Innova');
    expect(find.text('44,400 km'), findsOneWidget);
    await tapText(tester, 'Add cost');
    await tester.enterText(find.byKey(const Key('cost-amount')), '4500');
    await tapText(tester, 'Save');
    expect(find.text('PMS in 5,000 km'), findsNWidgets(3), reason: 'header, coming up and the sheet');
    expect(find.textContaining('31.5 L'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Innova · PMS in 5,000 km'), findsOneWidget, reason: 'home tile');
    await tapText(tester, 'Budget');
    expect(find.text('−₱2,000.00'), findsOneWidget);
    expect(find.text('−₱4,500.00'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('non-adults do not get vehicles', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Vehicles'), findsNothing);
    await app.finish(tester, s);
  });
}
