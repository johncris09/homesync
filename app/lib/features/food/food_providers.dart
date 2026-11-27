import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../pantry/pantry_providers.dart' show pantryItemsProvider;
import 'food_repository.dart';

final foodRepoProvider = Provider<FoodRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return FoodRepository(s.db, s.writer);
});

/// Everyone but viewers plans meals and edits recipes.
final canPlanMealsProvider = Provider<bool>((ref) {
  final role = ref.watch(authProvider).session?.active.role;
  return role != null && role != 'viewer';
});

final recipesProvider = StreamProvider<List<Recipe>>((ref) => ref.watch(foodRepoProvider).watchRecipes());

final ingredientsProvider = StreamProvider<Map<String, List<RecipeIngredient>>>(
  (ref) => ref.watch(foodRepoProvider).watchIngredients(),
);

/// Meals of the week starting on the given day.
final weekMealsProvider = StreamProvider.family<List<Meal>, DateTime>(
  (ref, start) => ref.watch(foodRepoProvider).watchMeals(start, DateTime(start.year, start.month, start.day + 6)),
);

final pantryMatchesProvider = Provider<List<PantryMatch>>(
  (ref) => cookFromPantry(
    ref.watch(recipesProvider).value ?? const [],
    ref.watch(ingredientsProvider).value ?? const {},
    ref.watch(pantryItemsProvider).value ?? const [],
  ),
);

final recipesByIdProvider = Provider<Map<String, Recipe>>(
  (ref) => {for (final r in ref.watch(recipesProvider).value ?? const <Recipe>[]) r.id: r},
);

/// Today's meals (for the header and the home tile).
final todayMealsProvider = StreamProvider<List<Meal>>((ref) {
  final repo = ref.watch(foodRepoProvider);
  final t = repo.now;
  final day = DateTime(t.year, t.month, t.day);
  return repo.watchMeals(day, day);
});

/// What is planned for dinner today, names joined; null when nothing.
final tonightProvider = Provider<String?>((ref) {
  final recipes = ref.watch(recipesByIdProvider);
  final names = [
    for (final m in ref.watch(todayMealsProvider).value ?? const <Meal>[])
      if (m.slot == 'dinner') mealName(m, recipes),
  ].where((n) => n.isNotEmpty);
  return names.isEmpty ? null : names.join(', ');
});
