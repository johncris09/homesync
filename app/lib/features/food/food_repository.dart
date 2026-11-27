import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../pantry/pantry_repository.dart' show PantryRepository, formatQuantity;

/// [Meals.slot], in the order of the day.
const mealSlots = ['breakfast', 'lunch', 'merienda', 'dinner'];

/// An ingredient line as typed in the recipe form; [id] is set for a line
/// that is already saved.
typedef IngredientInput = ({String? id, String name, double? quantity, String? unit});

/// The first day of the week holding [day] (local date, no time).
/// [firstDayIndex]: 0 = Sunday … 6 = Saturday, as MaterialLocalizations gives.
DateTime weekStart(DateTime day, int firstDayIndex) {
  return DateTime(day.year, day.month, day.day - (day.weekday % 7 - firstDayIndex + 7) % 7);
}

String _key(String? s) => (s ?? '').trim().toLowerCase();

/// "0.5 kg", "3", or null when no amount is known.
String? amountText(double? quantity, String? unit) {
  if (quantity == null) return unit == null || unit.trim().isEmpty ? null : unit.trim();
  return '${formatQuantity(quantity)} ${unit ?? ''}'.trim();
}

/// One thing the planned meals need: ingredient lines of the same name and
/// unit added up. [quantity] is null when any line had no amount.
class Need {
  Need(this.name, this.quantity, this.unit);
  final String name;
  final double? quantity;
  final String? unit;
}

/// What the pantry lacks for [need]: null when it has enough, otherwise the
/// amount to buy as text ('' when the amount is unknown).
///
/// Same unit (or both without one) → compares amounts. Otherwise the pantry
/// only "lacks" it when it has none at all.
String? shortfall(Need need, List<PantryItem> pantry) {
  final items = pantry.where((p) => _key(p.name) == _key(need.name)).toList();
  final sameUnit = items.where((p) => _key(p.unit) == _key(need.unit)).toList();
  if (need.quantity != null && sameUnit.isNotEmpty) {
    final have = sameUnit.fold<double>(0, (s, p) => s + p.quantity);
    final short = need.quantity! - have;
    return short <= 1e-9 ? null : amountText(short, need.unit) ?? '';
  }
  if (items.any((p) => p.quantity > 0)) return null;
  return amountText(need.quantity, need.unit) ?? '';
}

/// Adds up the ingredient lines of every planned recipe ([meals] may repeat
/// a recipe: it counts once per meal).
List<Need> needsFor(Iterable<Meal> meals, Map<String, List<RecipeIngredient>> ingredients) {
  final out = <String, Need>{};
  for (final m in meals) {
    for (final i in ingredients[m.recipeId] ?? const <RecipeIngredient>[]) {
      final k = '${_key(i.name)}|${_key(i.unit)}';
      final prev = out[k];
      if (prev == null) {
        out[k] = Need(i.name.trim(), i.quantity, i.unit);
      } else {
        final q = prev.quantity == null || i.quantity == null ? null : prev.quantity! + i.quantity!;
        out[k] = Need(prev.name, q, prev.unit);
      }
    }
  }
  return out.values.toList();
}

/// A recipe and how much of it the pantry covers.
class PantryMatch {
  PantryMatch(this.recipe, this.have, this.missing);
  final Recipe recipe;
  final int have;
  final List<String> missing;
  int get total => have + missing.length;
}

/// Recipes the pantry can (nearly) cook: those with at least one ingredient
/// in stock, fewest missing first.
List<PantryMatch> cookFromPantry(
  List<Recipe> recipes,
  Map<String, List<RecipeIngredient>> ingredients,
  List<PantryItem> pantry,
) {
  final out = <PantryMatch>[];
  for (final r in recipes) {
    final lines = ingredients[r.id] ?? const <RecipeIngredient>[];
    if (lines.isEmpty) continue;
    final missing = [
      for (final i in lines)
        if (shortfall(Need(i.name, i.quantity, i.unit), pantry) != null) i.name,
    ];
    final have = lines.length - missing.length;
    if (have > 0) out.add(PantryMatch(r, have, missing));
  }
  out.sort((a, b) {
    final m = a.missing.length.compareTo(b.missing.length);
    if (m != 0) return m;
    final h = b.have.compareTo(a.have);
    return h != 0 ? h : a.recipe.name.toLowerCase().compareTo(b.recipe.name.toLowerCase());
  });
  return out;
}

/// What "add to grocery list" did.
typedef GroceryResult = ({int added, int inPantry, int listed});

/// Food Planner: recipes and the meal plan, all on the device.
class FoodRepository {
  FoodRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get now => _now();

  // -------------------------------------------------------------- recipes

  Stream<List<Recipe>> watchRecipes() =>
      (db.select(db.recipes)
            ..where((r) => r.deletedAt.isNull())
            ..orderBy([(r) => OrderingTerm.asc(r.name.lower())]))
          .watch();

  /// Ingredient lines of every recipe, by recipe id, in order.
  Stream<Map<String, List<RecipeIngredient>>> watchIngredients() =>
      (db.select(db.recipeIngredients)
            ..where((i) => i.deletedAt.isNull())
            ..orderBy([(i) => OrderingTerm.asc(i.position), (i) => OrderingTerm.asc(i.createdAt)]))
          .watch()
          .map(_byRecipe);

  static Map<String, List<RecipeIngredient>> _byRecipe(List<RecipeIngredient> rows) {
    final out = <String, List<RecipeIngredient>>{};
    for (final i in rows) {
      (out[i.recipeId] ??= []).add(i);
    }
    return out;
  }

  Future<String> addRecipe({
    required String name,
    int? servings,
    String? steps,
    String? note,
    List<IngredientInput> ingredients = const [],
  }) async {
    final id = await writer.insert('recipes', {
      'name': name.trim(),
      'servings': servings,
      'steps': _blankToNull(steps),
      'note': _blankToNull(note),
    });
    await _saveIngredients(id, const [], ingredients);
    return id;
  }

  Future<void> editRecipe(
    Recipe r, {
    required String name,
    int? servings,
    String? steps,
    String? note,
    required List<IngredientInput> ingredients,
  }) async {
    await _update('recipes', r.id, {
      'name': (r.name, name.trim()),
      'servings': (r.servings, servings),
      'steps': (r.steps, _blankToNull(steps)),
      'note': (r.note, _blankToNull(note)),
    });
    final saved = await (db.select(
      db.recipeIngredients,
    )..where((i) => i.recipeId.equals(r.id) & i.deletedAt.isNull())).get();
    await _saveIngredients(r.id, saved, ingredients);
  }

  /// Writes the lines that changed: new ones inserted, missing ones deleted,
  /// the rest updated field by field (positions follow the list order).
  Future<void> _saveIngredients(String recipeId, List<RecipeIngredient> saved, List<IngredientInput> lines) async {
    final kept = <String>{};
    var position = 0;
    for (final l in lines) {
      final name = l.name.trim();
      if (name.isEmpty) continue;
      final unit = _blankToNull(l.unit);
      final old = l.id == null ? null : saved.where((s) => s.id == l.id).firstOrNull;
      if (old == null) {
        await writer.insert('recipe_ingredients', {
          'recipe_id': recipeId,
          'name': name,
          'quantity': l.quantity,
          'unit': unit,
          'position': position,
        });
      } else {
        kept.add(old.id);
        await _update('recipe_ingredients', old.id, {
          'name': (old.name, name),
          'quantity': (old.quantity, l.quantity),
          'unit': (old.unit, unit),
          'position': (old.position, position),
        });
      }
      position++;
    }
    for (final s in saved) {
      if (!kept.contains(s.id)) await writer.delete('recipe_ingredients', s.id);
    }
  }

  /// Deletes the recipe and its lines. Planned meals keep its name.
  Future<void> removeRecipe(String id) async {
    final lines = await (db.select(
      db.recipeIngredients,
    )..where((i) => i.recipeId.equals(id) & i.deletedAt.isNull())).get();
    for (final l in lines) {
      await writer.delete('recipe_ingredients', l.id);
    }
    await writer.delete('recipes', id);
  }

  // ----------------------------------------------------------------- plan

  /// Meals planned from [from] to [to] (both included).
  Stream<List<Meal>> watchMeals(DateTime from, DateTime to) =>
      (db.select(db.meals)
            ..where(
              (m) =>
                  m.deletedAt.isNull() &
                  m.plannedOn.isBiggerOrEqualValue(isoDate(from)) &
                  m.plannedOn.isSmallerOrEqualValue(isoDate(to)),
            )
            ..orderBy([(m) => OrderingTerm.asc(m.plannedOn), (m) => OrderingTerm.asc(m.createdAt)]))
          .watch();

  /// Plans a recipe (its name is kept as the dish too) or a typed dish.
  Future<String> addMeal(DateTime day, String slot, {Recipe? recipe, String? dish, String? note}) {
    assert(mealSlots.contains(slot));
    return writer.insert('meals', {
      'planned_on': isoDate(day),
      'slot': slot,
      'recipe_id': recipe?.id,
      'dish': recipe?.name ?? dish?.trim(),
      'note': _blankToNull(note),
    });
  }

  Future<void> removeMeal(String id) => writer.delete('meals', id);

  /// Puts on the grocery list what the recipes planned from [from] to [to]
  /// need and the pantry lacks, skipping what is already on the list.
  Future<GroceryResult> addPlanToGrocery(DateTime from, DateTime to) async {
    final meals =
        await (db.select(db.meals)..where(
              (m) =>
                  m.deletedAt.isNull() &
                  m.recipeId.isNotNull() &
                  m.plannedOn.isBiggerOrEqualValue(isoDate(from)) &
                  m.plannedOn.isSmallerOrEqualValue(isoDate(to)),
            ))
            .get();
    final ingredients = _byRecipe(await (db.select(db.recipeIngredients)..where((i) => i.deletedAt.isNull())).get());
    final pantry = await (db.select(db.pantryItems)..where((p) => p.deletedAt.isNull())).get();
    final grocery = PantryRepository(db, writer, now: _now);
    final listed = {
      for (final g in await (db.select(
        db.groceryItems,
      )..where((g) => g.deletedAt.isNull() & g.isBought.equals(false) & g.clearedAt.isNull())).get())
        _key(g.name),
    };

    var added = 0, inPantry = 0, already = 0;
    for (final n in needsFor(meals, ingredients)) {
      final short = shortfall(n, pantry);
      if (short == null) {
        inPantry++;
      } else if (listed.contains(_key(n.name))) {
        already++;
      } else {
        await grocery.addGrocery(n.name, quantityText: short);
        listed.add(_key(n.name));
        added++;
      }
    }
    return (added: added, inPantry: inPantry, listed: already);
  }

  // ---------------------------------------------------------------------

  /// Sends only the fields whose (before, after) differ.
  Future<void> _update(String entity, String id, Map<String, (Object?, Object?)> fields) async {
    final changed = {
      for (final e in fields.entries)
        if (e.value.$1 != e.value.$2) e.key: e.value.$2,
    };
    if (changed.isNotEmpty) await writer.update(entity, id, changed);
  }
}

String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();

/// "1.5", "1,5", "1/2" or "1 1/2" → a number; null when blank or unreadable.
double? parseAmount(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(t);
  if (mixed != null) {
    final d = int.parse(mixed[3]!);
    return d == 0 ? null : int.parse(mixed[1]!) + int.parse(mixed[2]!) / d;
  }
  final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(t);
  if (frac != null) {
    final d = int.parse(frac[2]!);
    return d == 0 ? null : int.parse(frac[1]!) / d;
  }
  final v = double.tryParse(t);
  return v == null || v < 0 ? null : v;
}

/// The name to show for a planned meal: its recipe's current name, else the
/// dish kept on the meal.
String mealName(Meal m, Map<String, Recipe> recipes) => recipes[m.recipeId]?.name ?? m.dish ?? '';
