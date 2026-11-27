import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/app_services.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/features/pantry/pantry_repository.dart';

import '../app_test.dart' as app;
import '../support/test_db.dart';

Future<AppServices> open(MemorySecureStore store, {Future<void> Function(PantryRepository r)? seed}) async {
  final s = await app.services(store);
  await s.writer.insert('members', {'name': 'Mama', 'role': 'owner'}, id: app.me.memberId);
  if (seed != null) await seed(PantryRepository(s.db, s.writer));
  return s;
}

Future<void> openPantry(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Pantry & grocery')); // below the fold with every module shown
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pantry & grocery'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows the module; quick-add, tick and clear on the grocery list', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('0 to buy · 0 running low'), findsOneWidget);

    await openPantry(tester);
    expect(find.text('Nothing to buy'), findsOneWidget);
    expect(find.text('The list is empty.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('grocery-add')), 'Eggs');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('grocery-add')), 'Rice');
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    expect(find.text('2 to buy'), findsOneWidget);
    expect(find.textContaining('asked by'), findsNothing, reason: 'who added an item is not shown');

    await tester.tap(find.byType(Checkbox).first); // Eggs (sorted by name)
    await tester.pumpAndSettle();
    expect(find.text('1 to buy'), findsOneWidget);
    expect(find.text('Bought'), findsOneWidget);

    await tester.tap(find.text('Clear bought'));
    await tester.pumpAndSettle();
    expect(find.text('Bought'), findsNothing);
    expect(find.text('Eggs'), findsNothing);
    expect(find.text('Rice'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('bought items show the day; cleared items are in past groceries and can be bought again', (
    tester,
  ) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(
      () => open(store, seed: (r) => r.addGrocery('Eggs', quantityText: '1 tray', store: 'SM')),
    ))!;
    await app.pumpApp(tester, s);
    await openPantry(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ActionChip, 'Today'), findsOneWidget);

    // The chip opens a date picker for the day bought.
    await tester.tap(find.widgetWithText(ActionChip, 'Today'));
    await tester.pumpAndSettle();
    expect(find.text('Change the date bought'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear bought'));
    await tester.pumpAndSettle();
    expect(find.text('Eggs'), findsNothing);

    await tester.tap(find.byKey(const Key('grocery-history')));
    await tester.pumpAndSettle();
    expect(find.text('Past groceries'), findsNothing, reason: 'the history screen replaced the list');
    expect(find.text('1 item'), findsNWidgets(2)); // header figure and the day's count
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
    expect(find.text('1 tray · SM'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to the list again'));
    await tester.pumpAndSettle();
    expect(find.text('Added to the grocery list.'), findsOneWidget);
    await tester.tap(find.byTooltip('Add to the list again'));
    await tester.pumpAndSettle();
    expect(find.text('Already on the grocery list.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1 to buy'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('a shopping day set in the add field goes on new items, groups the list and can be removed', (
    tester,
  ) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store, seed: (r) => r.addGrocery('Soap'))))!;
    await app.pumpApp(tester, s);
    await openPantry(tester);
    expect(find.text('No date'), findsNothing, reason: 'no headings while nothing has a date');

    // Pick today in the add field's date chip, then add an item.
    await tester.tap(find.descendant(of: find.byKey(const Key('grocery-add-date')), matching: find.text('Set date')));
    await tester.pumpAndSettle();
    expect(find.text('When will you buy it?'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('grocery-add')), 'Eggs');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Next shopping: Today'), findsOneWidget);
    expect(find.text('No date'), findsOneWidget); // Soap's group heading
    final eggs = (await tester.runAsync(() => s.db.select(s.db.groceryItems).get()))!.firstWhere((g) => g.name == 'Eggs');
    expect(eggs.plannedOn, isNotNull);

    // Remove Eggs' date with the chip's x.
    await tester.tap(find.descendant(of: find.byKey(Key('plan-${eggs.id}')), matching: find.byIcon(Icons.close)));
    await tester.pumpAndSettle();
    expect(find.text('Next shopping: Today'), findsNothing);
    expect(find.text('No date'), findsNothing);
    await app.finish(tester, s);
  });

  testWidgets('history is empty until something is bought', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    await openPantry(tester);
    await tester.tap(find.byKey(const Key('grocery-history')));
    await tester.pumpAndSettle();
    expect(find.text('Nothing bought'), findsOneWidget);
    expect(find.textContaining('Nothing bought yet.'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('pantry: add an item, use and restock it, then put it on the list', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    await openPantry(tester);
    await tester.tap(find.text('Pantry'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing in the pantry yet.'), findsOneWidget);

    await tester.tap(find.text('Add pantry item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('pantry-name')), 'Coffee');
    await tester.enterText(find.byKey(const Key('pantry-quantity')), 'x');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a number, 0 or more.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('pantry-quantity')), '2');
    await tester.enterText(find.byKey(const Key('pantry-min')), '1');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byTooltip('Use one Coffee'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Running low'), findsOneWidget);
    expect(find.text('1 item running low in the pantry.'), findsOneWidget);
    await tester.tap(find.byTooltip('Add one Coffee'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Running low'), findsNothing);

    await tester.tap(find.text('Coffee'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to grocery list'));
    await tester.pumpAndSettle();
    expect(find.text('Added to the grocery list.'), findsOneWidget);
    expect(find.text('1 to buy'), findsOneWidget);

    final row = await tester.runAsync(
      () => s.db.customSelect("SELECT quantity FROM pantry_items WHERE name = 'Coffee'").getSingle(),
    );
    expect(row!.data['quantity'], 2);
    await app.finish(tester, s);
  });

  testWidgets('viewers see the list and pantry but cannot change them', (tester) async {
    final store = MemorySecureStore();
    const viewer = Profile(
      memberId: '01900000-0000-7000-8000-0000000000dd',
      name: 'Lola',
      role: 'viewer',
      deviceId: 'd0000000-0000-7000-8000-00000000000d',
    );
    store.values['session'] = jsonEncode(
      const Session(
        householdId: householdId,
        householdName: 'Manabo',
        isShared: false,
        main: viewer,
        active: viewer,
      ).toJson(),
    );
    final s = (await tester.runAsync(
      () => open(
        store,
        seed: (r) async {
          await r.addGrocery('Eggs');
          await r.addPantry(name: 'Rice', quantity: 3, unit: 'kg');
        },
      ),
    ))!;
    await app.pumpApp(tester, s);
    await openPantry(tester);
    expect(find.text('Eggs'), findsOneWidget);
    expect(find.byKey(const Key('grocery-add')), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);

    await tester.tap(find.text('Pantry'));
    await tester.pumpAndSettle();
    expect(find.text('3 kg'), findsOneWidget);
    expect(find.text('Add pantry item'), findsNothing);
    expect(find.byTooltip('Use one Rice'), findsNothing);
    await app.finish(tester, s);
  });
}
