import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/features/health/health_repository.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText, writerFor;

void main() {
  testWidgets('adult adds a medicine, gives a dose, restocks with a cost, and it shows in Budget', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('No doses or checkups due'), findsOneWidget, reason: 'home tile');

    await tapText(tester, 'Health');
    expect(find.text('No medicines yet'), findsOneWidget);
    expect(find.text('Set up the vault to keep health profiles'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-medicine')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('medicine-name')), 'Losartan');
    await tester.enterText(find.byKey(const Key('medicine-strength')), '50mg');
    await tester.enterText(find.byKey(const Key('medicine-times')), '20:00, 8');
    await tapText(tester, 'Save');
    expect(find.text('Use times like 8:00 or 20:30'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('medicine-times')), '20:00, 8:00');
    await tapText(tester, 'Mama');
    await tester.enterText(find.byKey(const Key('medicine-stock-field')), '10');
    await tester.enterText(find.byKey(const Key('medicine-min')), '9');
    await tapText(tester, 'Save');

    expect(find.text('2 doses left'), findsOneWidget);
    expect(find.text('Mama · Losartan 50mg'), findsNWidgets(2));

    final id = (await tester.runAsync(() => s.db.select(s.db.medicines).getSingle()))!.id;
    await tester.tap(find.byKey(Key('dose-$id-08:00')));
    await tester.pumpAndSettle();
    expect(find.text('1 dose left'), findsOneWidget);
    expect(find.textContaining('given by Mama'), findsOneWidget);
    expect(find.text('Running low'), findsOneWidget);

    await tester.tap(find.byKey(Key('to-list-$id')));
    await tester.pumpAndSettle();
    expect(find.text('Added to the grocery list.'), findsOneWidget);

    // Restock with a cost.
    await tapText(tester, 'Losartan 50mg');
    expect(find.text('9 tablets left'), findsOneWidget);
    await tester.tap(find.byKey(const Key('restock')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('stock-qty')), '30');
    await tester.enterText(find.byKey(const Key('stock-cost')), '450');
    await tester.tap(find.byKey(const Key('stock-save')));
    await tester.pumpAndSettle();
    expect(find.text('39 tablets left'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();
    expect(find.text('Running low'), findsNothing);

    await tester.fling(find.byType(ListView).first, const Offset(0, 2000), 3000); // back to the header
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('1 dose left today'), findsOneWidget, reason: 'home tile');
    await tapText(tester, 'Budget');
    expect(find.text('−₱450.00'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('a helper ticks doses but does not manage medicines or see profiles', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      final mama = HealthRepository(
        s.db,
        writerFor(s, app.me.memberId, app.me.deviceId),
        session: s.vault,
        crypto: s.vaultCrypto,
      );
      await mama.addMedicine(name: 'Losartan', times: '08:00', stock: 10);
      return s;
    }))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Health');
    expect(find.byKey(const Key('add-medicine')), findsNothing);
    expect(find.text('Family'), findsNothing);
    await tapText(tester, 'Losartan');
    expect(find.text('Restock'), findsNothing);
    expect(find.text('Give a dose'), findsOneWidget);
    await tapText(tester, 'Give a dose');
    expect(find.text('9 tablets left'), findsOneWidget);
    await app.finish(tester, s);
  });
}
