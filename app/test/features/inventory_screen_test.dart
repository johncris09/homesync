import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/features/inventory/inventory_repository.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

void main() {
  testWidgets('adult adds an item in a room, lends it, gets it back; warranty shows', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Nothing listed yet'), findsOneWidget, reason: 'home tile');

    await tapText(tester, 'Inventory');
    expect(find.text('No items yet'), findsOneWidget, reason: 'header');
    await tester.tap(find.byKey(const Key('add-item')));
    await tester.pumpAndSettle();

    await tapText(tester, 'Save');
    expect(find.text('Enter a name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('item-name')), 'Aircon');
    await tester.tap(find.byKey(const Key('room-Kwarto')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('item-brand')), 'Carrier');
    await tester.enterText(find.byKey(const Key('item-serial')), 'SN-123');
    await tester.enterText(find.byKey(const Key('item-price')), '28999');
    await tester.ensureVisible(find.byKey(const Key('item-save')));
    await tester.tap(find.byKey(const Key('item-save')));
    await tester.pumpAndSettle();

    expect(find.text('1 item'), findsOneWidget, reason: 'header');
    expect(find.textContaining('worth ₱28,999'), findsOneWidget);
    expect(find.text('Kwarto'), findsOneWidget, reason: 'room heading');
    expect(find.text('Carrier'), findsOneWidget);

    await tapText(tester, 'Aircon');
    expect(find.text('Appliance · Kwarto'), findsOneWidget);
    expect(find.text('S/N SN-123'), findsOneWidget);
    await tester.tap(find.byKey(const Key('item-lend')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('lend-who')), 'Tita Baby');
    await tester.tap(find.byKey(const Key('lend-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-lent')), findsOneWidget);
    expect(find.textContaining('Lent to Tita Baby'), findsWidgets);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();
    expect(find.text('Needs a look'), findsOneWidget);
    expect(find.byKey(const Key('item-Aircon-attention')), findsOneWidget);

    // Search by who has it.
    await tester.enterText(find.byKey(const Key('inventory-search')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('inventory-search')), 'baby');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-Aircon')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('inventory-search')), '');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('item-Aircon')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('item-returned')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-lent')), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Needs a look'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('1 item'), findsOneWidget, reason: 'home tile');
    await app.finish(tester, s);
  });

  testWidgets('helpers see where things are but not prices, and cannot change them', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() => open(store)))!;
    await tester.runAsync(
      () => InventoryRepository(
        s.db,
        s.writer,
      ).add(const ItemDraft(name: 'Drill', category: 'tools', room: 'Bodega', priceMinor: 350000)),
    );
    await app.pumpApp(tester, s);
    await tapText(tester, 'Inventory');

    expect(find.text('1 item'), findsOneWidget);
    expect(find.textContaining('worth'), findsNothing);
    expect(find.byKey(const Key('add-item')), findsNothing);
    await tapText(tester, 'Drill');
    expect(find.text('Tools · Bodega'), findsOneWidget);
    expect(find.textContaining('₱'), findsNothing);
    expect(find.byKey(const Key('item-lend')), findsNothing);
    expect(find.byKey(const Key('item-take-photo')), findsNothing);
    await app.finish(tester, s);
  });
}
