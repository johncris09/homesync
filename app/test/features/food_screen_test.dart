import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/features/food/food_repository.dart';
import 'package:homesync/features/pantry/pantry_repository.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show open, signedInAs, tapText;

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('adds a recipe, plans tonight from it, and sends what is missing to the grocery list', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await PantryRepository(s.db, s.writer).addPantry(name: 'Salt', quantity: 1);
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.text('Nothing planned for tonight'), findsOneWidget, reason: 'home tile');

    await tapText(tester, 'Food Planner');
    expect(find.text('Dinner not planned'), findsOneWidget, reason: 'header');
    expect(find.text('No days planned this week'), findsOneWidget);

    // A recipe with two ingredients.
    await tapText(tester, 'Recipes');
    expect(find.text("No recipes yet. Add the family's favourites."), findsOneWidget);
    await tapKey(tester, 'add-recipe');
    await tester.tap(find.byKey(const Key('recipe-save')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('recipe-name')), 'Sinigang');
    await tester.enterText(find.byKey(const Key('recipe-servings')), '6');
    await tester.enterText(find.byKey(const Key('ing-name-0')), 'Pork ribs');
    await tester.enterText(find.byKey(const Key('ing-qty-0')), '1 1/2');
    await tester.enterText(find.byKey(const Key('ing-unit-0')), 'kg');
    await tapKey(tester, 'ing-add');
    await tester.enterText(find.byKey(const Key('ing-name-1')), 'Salt');
    await tapKey(tester, 'recipe-save');
    expect(find.text('6 servings · 2 ingredients'), findsOneWidget);
    expect(find.text('1 of 2 in the pantry · Needs Pork ribs'), findsOneWidget, reason: 'cook from pantry');

    await tapKey(tester, 'recipe-Sinigang');
    expect(find.text('1.5 kg'), findsOneWidget);
    expect(find.text('To buy: 1.5 kg'), findsOneWidget);
    expect(find.text('In the pantry'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Tonight's dinner from the recipe, merienda typed.
    await tapText(tester, 'Week');
    final today = isoDate(DateTime.now());
    await tapKey(tester, 'add-$today-dinner');
    await tapKey(tester, 'pick-Sinigang');
    expect(find.text('Tonight: Sinigang'), findsOneWidget, reason: 'header');
    expect(find.text('1 of 7 days planned this week'), findsOneWidget);
    await tapKey(tester, 'add-$today-merienda');
    await tester.enterText(find.byKey(const Key('meal-dish')), 'Turon');
    await tapKey(tester, 'meal-add-dish');
    expect(find.byKey(const Key('meal-Turon')), findsOneWidget);

    await tapKey(tester, 'plan-to-grocery');
    expect(find.text('1 item added to the grocery list · 1 in the pantry'), findsOneWidget);
    final list = await tester.runAsync(() => PantryRepository(s.db, s.writer).watchToBuy().first);
    expect(list!.single.name, 'Pork ribs');
    expect(list.single.quantityText, '1.5 kg');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Tonight: Sinigang'), findsOneWidget, reason: 'home tile');
    await app.finish(tester, s);
  });

  testWidgets('viewers see the plan and recipes but cannot change them', (tester) async {
    final store = MemorySecureStore();
    const viewer = Profile(
      memberId: '01900000-0000-7000-8000-0000000000dd',
      name: 'Lola',
      role: 'viewer',
      deviceId: 'd0000000-0000-7000-8000-00000000000d',
    );
    signedInAs(store, viewer);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      final food = FoodRepository(s.db, s.writer);
      await food.addRecipe(
        name: 'Adobo',
        servings: 4,
        ingredients: [(id: null, name: 'Chicken', quantity: 1, unit: 'kg')],
      );
      await food.addMeal(DateTime.now(), 'dinner', dish: 'Adobo');
      return s;
    }))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Food Planner');

    expect(find.text('Tonight: Adobo'), findsOneWidget);
    expect(find.byKey(Key('add-${isoDate(DateTime.now())}-dinner')), findsNothing);
    expect(find.byKey(const Key('plan-to-grocery')), findsNothing);
    final chip = tester.widget<InputChip>(find.byKey(const Key('meal-Adobo')));
    expect(chip.onDeleted, isNull);

    await tapText(tester, 'Recipes');
    expect(find.byKey(const Key('add-recipe')), findsNothing);
    await tapKey(tester, 'recipe-Adobo');
    expect(find.byKey(const Key('recipe-edit')), findsNothing);
    expect(find.text('1 kg'), findsOneWidget);
    await app.finish(tester, s);
  });
}
