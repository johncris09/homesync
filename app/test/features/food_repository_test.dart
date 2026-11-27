import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/food/food_repository.dart';
import 'package:homesync/features/pantry/pantry_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

IngredientInput line(String name, [double? quantity, String? unit, String? id]) =>
    (id: id, name: name, quantity: quantity, unit: unit);

PantryItem stock(String name, double quantity, [String? unit]) => PantryItem(
  id: name,
  name: name,
  unit: unit,
  quantity: quantity,
  householdId: householdId,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  serverVersion: 0,
);

void main() {
  test('the week starts on the locale\'s first day', () {
    final wed = DateTime(2026, 12, 9, 15);
    expect(weekStart(wed, 0), DateTime(2026, 12, 6), reason: 'Sunday');
    expect(weekStart(wed, 1), DateTime(2026, 12, 7), reason: 'Monday');
    expect(weekStart(DateTime(2026, 12, 6), 0), DateTime(2026, 12, 6));
    expect(weekStart(DateTime(2026, 12, 6), 1), DateTime(2026, 11, 30));
  });

  test('shortfall compares amounts in the same unit, otherwise only "none left"', () {
    final pantry = [stock('Pork ribs', 0.5, 'kg'), stock('Salt', 1), stock('Rice', 0, 'kg'), stock('Eggs', 4)];
    expect(shortfall(Need('pork ribs', 1.5, 'kg'), pantry), '1 kg');
    expect(shortfall(Need('Pork ribs', 0.5, 'KG'), pantry), isNull);
    expect(shortfall(Need('Salt', null, null), pantry), isNull);
    expect(shortfall(Need('Rice', 2, 'kg'), pantry), '2 kg');
    expect(shortfall(Need('Eggs', 12, 'pcs'), pantry), isNull, reason: 'other unit: only lacking when none left');
    expect(shortfall(Need('Kangkong', null, 'bunch'), pantry), 'bunch');
    expect(shortfall(Need('Patis', null, null), pantry), '');
  });

  group('repository', () {
    late AppDatabase db;
    late FoodRepository repo;
    late PantryRepository pantry;
    final today = DateTime(2026, 12, 9, 8);

    setUp(() {
      db = memoryDb();
      final w = writer(db, identity(memberId: memberA, deviceId: deviceA));
      repo = FoodRepository(db, w, now: () => today);
      pantry = PantryRepository(db, w, now: () => today);
    });
    tearDown(() => db.close());

    test('recipes keep their lines in order and edits send only what changed', () async {
      final id = await repo.addRecipe(
        name: ' Sinigang ',
        servings: 6,
        steps: 'Boil the pork.',
        ingredients: [
          line('Pork ribs', 1, 'kg'),
          line(' '),
          line('Sampalok mix', 1, 'pack'),
          line('Kangkong', 1, 'bunch'),
        ],
      );
      var r = (await repo.watchRecipes().first).single;
      expect(r.name, 'Sinigang');
      var lines = (await repo.watchIngredients().first)[id]!;
      expect(lines.map((l) => l.name).toList(), [
        'Pork ribs',
        'Sampalok mix',
        'Kangkong',
      ], reason: 'blank line skipped');
      expect(lines.map((l) => l.position).toList(), [0, 1, 2]);

      final before = await db.select(db.fieldClocks).get();
      await repo.editRecipe(
        r,
        name: 'Sinigang',
        servings: 6,
        steps: 'Boil the pork.',
        ingredients: [
          line('Pork ribs', 1.5, 'kg', lines[0].id),
          line('Kangkong', 1, 'bunch', lines[2].id),
          line('Gabi', 3, 'pcs'),
        ],
      );
      lines = (await repo.watchIngredients().first)[id]!;
      expect(lines.map((l) => (l.name, l.quantity, l.position)).toList(), [
        ('Pork ribs', 1.5, 0),
        ('Kangkong', 1.0, 1),
        ('Gabi', 3.0, 2),
      ]);
      final after = await db.select(db.fieldClocks).get();
      final changed = after
          .where(
            (c) => !before.any(
              (b) => b.entity == c.entity && b.entityId == c.entityId && b.field == c.field && b.hlc == c.hlc,
            ),
          )
          .where((c) => c.entity == 'recipes');
      expect(changed, isEmpty, reason: 'recipe fields unchanged');

      r = (await repo.watchRecipes().first).single;
      final meal = await repo.addMeal(today, 'dinner', recipe: r);
      await repo.removeRecipe(id);
      expect(await repo.watchRecipes().first, isEmpty);
      expect(await repo.watchIngredients().first, isEmpty);
      final m = (await repo.watchMeals(today, today).first).single;
      expect(m.id, meal);
      expect(m.dish, 'Sinigang', reason: 'the plan keeps the name');
    });

    test('meals by day and slot; the grocery list gets what the pantry lacks', () async {
      final sinigang = await repo.addRecipe(
        name: 'Sinigang',
        ingredients: [line('Pork ribs', 0.75, 'kg'), line('Kangkong', 1, 'bunch'), line('Salt')],
      );
      final adobo = await repo.addRecipe(
        name: 'Adobo',
        ingredients: [line('Chicken', 1, 'kg'), line('Soy sauce', 0.5, 'cup'), line('Salt')],
      );
      final recipes = {for (final r in await repo.watchRecipes().first) r.id: r};
      final tomorrow = DateTime(2026, 12, 10);
      await repo.addMeal(today, 'dinner', recipe: recipes[sinigang]);
      await repo.addMeal(tomorrow, 'lunch', recipe: recipes[sinigang]);
      await repo.addMeal(tomorrow, 'dinner', recipe: recipes[adobo]);
      await repo.addMeal(tomorrow, 'merienda', dish: ' Turon ');
      await repo.addMeal(DateTime(2026, 12, 8), 'dinner', recipe: recipes[adobo]);

      final week = await repo.watchMeals(today, DateTime(2026, 12, 12)).first;
      expect(week.map((m) => (m.plannedOn, m.slot, m.dish)).toList(), [
        ('2026-12-09', 'dinner', 'Sinigang'),
        ('2026-12-10', 'lunch', 'Sinigang'),
        ('2026-12-10', 'dinner', 'Adobo'),
        ('2026-12-10', 'merienda', 'Turon'),
      ]);

      await pantry.addPantry(name: 'pork ribs', unit: 'kg', quantity: 0.5);
      await pantry.addPantry(name: 'Salt', quantity: 1);
      await pantry.addPantry(name: 'Soy sauce', unit: 'cup', quantity: 2);
      await pantry.addGrocery('Chicken', quantityText: '2 kg');

      final result = await repo.addPlanToGrocery(today, DateTime(2026, 12, 15));
      expect(result, (added: 2, inPantry: 2, listed: 1));
      final list = {for (final g in await pantry.watchToBuy().first) g.name: g.quantityText};
      expect(list, {'Chicken': '2 kg', 'Pork ribs': '1 kg', 'Kangkong': '2 bunch'});

      expect(await repo.addPlanToGrocery(today, DateTime(2026, 12, 15)), (added: 0, inPantry: 2, listed: 3));
    });

    test('cook from pantry: fewest missing first, nothing in stock left out', () async {
      final ids = [
        await repo.addRecipe(
          name: 'Adobo',
          ingredients: [line('Chicken', 1, 'kg'), line('Soy sauce'), line('Vinegar')],
        ),
        await repo.addRecipe(name: 'Tortang talong', ingredients: [line('Eggplant', 3, 'pcs'), line('Eggs', 2, 'pcs')]),
        await repo.addRecipe(name: 'Kare-kare', ingredients: [line('Oxtail', 1, 'kg')]),
        await repo.addRecipe(name: 'Plain rice'),
      ];
      expect(ids, hasLength(4));
      final pantryNow = [
        stock('Eggs', 6, 'pcs'),
        stock('Eggplant', 3, 'pcs'),
        stock('Soy sauce', 1),
        stock('Vinegar', 1),
      ];
      final matches = cookFromPantry(await repo.watchRecipes().first, await repo.watchIngredients().first, pantryNow);
      expect(matches.map((m) => (m.recipe.name, m.have, m.total)).toList(), [
        ('Tortang talong', 2, 2),
        ('Adobo', 2, 3),
      ]);
      expect(matches.last.missing, ['Chicken']);
    });
  });

  test('offline on two phones: both meals arrive, ingredient edits merge', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final a = FoodRepository(dbA, wA);
    final b = FoodRepository(dbB, wB);
    final syncA = SyncEngine(
      db: dbA,
      api: server.apiFor(memberId: memberA, deviceId: deviceA),
      clock: wA.clock,
    );
    final syncB = SyncEngine(
      db: dbB,
      api: server.apiFor(memberId: memberB, deviceId: deviceB),
      clock: wB.clock,
    );

    final id = await a.addRecipe(
      name: 'Sinigang',
      ingredients: [line('Pork ribs', 1, 'kg'), line('Kangkong', 1, 'bunch')],
    );
    await syncA.sync();
    await syncB.sync();

    final day = DateTime(2026, 12, 9);
    final ra = (await a.watchRecipes().first).single;
    final rb = (await b.watchRecipes().first).single;
    final la = (await a.watchIngredients().first)[id]!;
    final lb = (await b.watchIngredients().first)[id]!;
    await a.editRecipe(
      ra,
      name: 'Sinigang',
      ingredients: [line('Pork ribs', 1.5, 'kg', la[0].id), line('Kangkong', 1, 'bunch', la[1].id)],
    );
    await b.editRecipe(
      rb,
      name: 'Sinigang',
      ingredients: [line('Pork ribs', 1, 'kg', lb[0].id), line('Kangkong', 2, 'bunch', lb[1].id)],
    );
    await a.addMeal(day, 'dinner', recipe: ra);
    await b.addMeal(day, 'dinner', dish: 'Pritong isda');
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final repo in [a, b]) {
      final lines = (await repo.watchIngredients().first)[id]!;
      expect(lines.map((l) => l.quantity).toList(), [1.5, 2.0]);
      expect((await repo.watchMeals(day, day).first).map((m) => m.dish).toSet(), {'Sinigang', 'Pritong isda'});
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 16 database adds the food planner tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v16 = AppDatabase(NativeDatabase(file));
    await v16.customStatement('SELECT 1');
    for (final t in ['recipes', 'recipe_ingredients', 'meals']) {
      await v16.customStatement('DROP TABLE $t');
    }
    await v16.customStatement('PRAGMA user_version = 16');
    await v16.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = FoodRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.addRecipe(name: 'Adobo', ingredients: [line('Chicken', 1, 'kg')]);
    await repo.addMeal(DateTime(2026, 12, 9), 'lunch', dish: 'Pancit');
    expect(await repo.watchRecipes().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
