import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/sheet_body.dart';
import '../pantry/pantry_providers.dart' show pantryItemsProvider;
import '../sync/sync_widgets.dart';
import 'food_providers.dart';
import 'food_repository.dart';

void _openSheet(BuildContext context, Widget sheet) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// "2 of 3 in the pantry · Needs Chicken" or "Everything is in the pantry".
String matchLine(AppLocalizations l10n, PantryMatch m) => m.missing.isEmpty
    ? l10n.foodAllInPantry
    : '${l10n.foodInPantryCount(m.have, m.total)} · ${l10n.foodNeeds(m.missing.join(', '))}';

/// Food Planner: the week's meals by day and slot (owner picked layout A),
/// and the family's recipes.
class FoodScreen extends ConsumerStatefulWidget {
  const FoodScreen({super.key});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPlan = ref.watch(canPlanMealsProvider);
    final today = _day(ref.watch(foodRepoProvider).now);
    final thisWeek = weekStart(today, MaterialLocalizations.of(context).firstDayOfWeekIndex);
    final planned = {for (final m in ref.watch(weekMealsProvider(thisWeek)).value ?? const <Meal>[]) m.plannedOn};
    final tonight = ref.watch(tonightProvider);

    return Scaffold(
      floatingActionButton: canPlan && _tabs.index == 1
          ? FloatingActionButton.extended(
              key: const Key('add-recipe'),
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => _openSheet(context, const RecipeForm()),
              icon: const Icon(Icons.add),
              label: Text(l10n.foodAddRecipe),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            figure: tonight == null ? l10n.foodNoDinnerFigure : l10n.foodTonightFigure(tonight),
            caption: l10n.foodDaysPlanned(planned.length),
            color: HomeColors.dahon,
            leading: const BackButton(color: Colors.white),
          ),
          Material(
            color: HomeColors.dahon,
            child: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: HomeColors.mangga,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.foodWeekTab),
                Tab(text: l10n.foodRecipesTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                WeekTab(thisWeek: thisWeek, today: today),
                const RecipesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------- week

class WeekTab extends ConsumerStatefulWidget {
  const WeekTab({super.key, required this.thisWeek, required this.today});

  final DateTime thisWeek;
  final DateTime today;

  @override
  ConsumerState<WeekTab> createState() => _WeekTabState();
}

class _WeekTabState extends ConsumerState<WeekTab> {
  int _offset = 0;
  final _todayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Open on today's card.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _todayKey.currentContext;
      if (ctx != null && ctx.mounted) Scrollable.ensureVisible(ctx);
    });
  }

  DateTime get _start => DateTime(widget.thisWeek.year, widget.thisWeek.month, widget.thisWeek.day + 7 * _offset);

  Future<void> _toGrocery(DateTime from, DateTime to) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref.read(foodRepoProvider).addPlanToGrocery(from, to);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          [
            l10n.foodGroceryAdded(r.added),
            if (r.inPantry > 0) l10n.foodGroceryInPantry(r.inPantry),
            if (r.listed > 0) l10n.foodGroceryListed(r.listed),
          ].join(' · '),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final canPlan = ref.watch(canPlanMealsProvider);
    final start = _start;
    final end = DateTime(start.year, start.month, start.day + 6);
    final meals = ref.watch(weekMealsProvider(start)).value ?? const <Meal>[];
    final recipes = ref.watch(recipesByIdProvider);
    final title = Theme.of(context).textTheme.titleMedium;
    final md = DateFormat.MMMd(locale);
    final from = start.isBefore(widget.today) ? widget.today : start;
    final hasRecipes = meals.any((m) => m.recipeId != null && m.plannedOn.compareTo(isoDate(from)) >= 0);

    // A column, not a lazy list: seven small cards, and today must be built
    // to scroll to it.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                key: const Key('week-prev'),
                tooltip: l10n.foodPrevWeek,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _offset--),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('${md.format(start)} – ${md.format(end)}', key: const Key('week-range'), style: title),
                    if (_offset != 0)
                      TextButton(onPressed: () => setState(() => _offset = 0), child: Text(l10n.foodThisWeek)),
                  ],
                ),
              ),
              IconButton(
                key: const Key('week-next'),
                tooltip: l10n.foodNextWeek,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _offset++),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < 7; i++) ...[
            () {
              final day = DateTime(start.year, start.month, start.day + i);
              final label = DateFormat.MMMEd(locale).format(day);
              return day == widget.today
                  ? Text(l10n.foodToday(label), key: _todayKey, style: title)
                  : Text(label, style: title);
            }(),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final slot in mealSlots)
                      _SlotRow(
                        day: DateTime(start.year, start.month, start.day + i),
                        slot: slot,
                        meals: [
                          for (final m in meals)
                            if (m.plannedOn == isoDate(DateTime(start.year, start.month, start.day + i)) &&
                                m.slot == slot)
                              m,
                        ],
                        recipes: recipes,
                        canPlan: canPlan,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (canPlan && hasRecipes) ...[
            OutlinedButton.icon(
              key: const Key('plan-to-grocery'),
              onPressed: () => _toGrocery(from, end),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(l10n.foodPlanToGrocery),
            ),
            const SizedBox(height: 4),
            Text(l10n.foodPlanToGroceryHint, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _SlotRow extends ConsumerWidget {
  const _SlotRow({
    required this.day,
    required this.slot,
    required this.meals,
    required this.recipes,
    required this.canPlan,
  });

  final DateTime day;
  final String slot;
  final List<Meal> meals;
  final Map<String, Recipe> recipes;
  final bool canPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final label = l10n.foodSlot(slot);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 4, 2),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final m in meals)
                  InputChip(
                    key: Key('meal-${mealName(m, recipes)}'),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text(mealName(m, recipes), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        SyncMarker(entity: 'meals', id: m.id),
                      ],
                    ),
                    avatar: m.recipeId != null && recipes.containsKey(m.recipeId)
                        ? const Icon(Icons.menu_book_outlined, size: 18)
                        : null,
                    onPressed: recipes[m.recipeId] == null
                        ? null
                        : () => _openSheet(context, RecipeSheet(recipeId: m.recipeId!)),
                    onDeleted: canPlan ? () => ref.read(foodRepoProvider).removeMeal(m.id) : null,
                    deleteButtonTooltipMessage: l10n.foodRemoveMeal(mealName(m, recipes)),
                  ),
              ],
            ),
          ),
          if (canPlan)
            IconButton(
              key: Key('add-${isoDate(day)}-$slot'),
              tooltip: l10n.foodAddTo(label),
              icon: const Icon(Icons.add_circle_outline, color: HomeColors.dahon),
              onPressed: () => _openSheet(context, MealSheet(day: day, slot: slot)),
            )
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// Adds a dish to a slot: type one, or pick a recipe (those the pantry can
/// cook first).
class MealSheet extends ConsumerStatefulWidget {
  const MealSheet({super.key, required this.day, required this.slot});

  final DateTime day;
  final String slot;

  @override
  ConsumerState<MealSheet> createState() => _MealSheetState();
}

class _MealSheetState extends ConsumerState<MealSheet> {
  final _dish = TextEditingController();

  @override
  void dispose() {
    _dish.dispose();
    super.dispose();
  }

  Future<void> _add({Recipe? recipe}) async {
    final dish = _dish.text.trim();
    if (recipe == null && dish.isEmpty) return;
    await ref.read(foodRepoProvider).addMeal(widget.day, widget.slot, recipe: recipe, dish: dish);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final query = _dish.text.trim().toLowerCase();
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final matches = query.isEmpty ? ref.watch(pantryMatchesProvider).take(5).toList() : const <PantryMatch>[];
    final ingredients = ref.watch(ingredientsProvider).value ?? const {};
    final shown = [
      for (final r in recipes)
        if (r.name.toLowerCase().contains(query)) r,
    ];
    final title = Theme.of(context).textTheme.titleMedium;

    return SheetBody(
      title: l10n.foodMealSheetTitle(l10n.foodSlot(widget.slot), DateFormat.MMMEd(locale).format(widget.day)),
      children: [
        TextField(
          key: const Key('meal-dish'),
          controller: _dish,
          autofocus: recipes.isEmpty,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: l10n.foodDishHint, prefixIcon: const Icon(Icons.restaurant)),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _add(),
        ),
        if (query.isNotEmpty)
          ListTile(
            key: const Key('meal-add-dish'),
            leading: const Icon(Icons.add),
            title: Text(l10n.foodAddDish(_dish.text.trim())),
            onTap: _add,
          ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.foodCanCook, style: title),
          for (final m in matches)
            ListTile(
              key: Key('cook-${m.recipe.name}'),
              leading: const Icon(Icons.kitchen_outlined, color: HomeColors.dahon),
              title: Text(m.recipe.name),
              subtitle: Text(matchLine(l10n, m)),
              onTap: () => _add(recipe: m.recipe),
            ),
        ],
        const SizedBox(height: 16),
        Text(l10n.foodYourRecipes, style: title),
        if (recipes.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(l10n.foodNoRecipesToPick))
        else if (shown.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(l10n.foodNoMatch)),
        for (final r in shown)
          ListTile(
            key: Key('pick-${r.name}'),
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(r.name),
            subtitle: Text(l10n.foodIngredientCount(ingredients[r.id]?.length ?? 0)),
            onTap: () => _add(recipe: r),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------ recipes

class RecipesTab extends ConsumerWidget {
  const RecipesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canPlan = ref.watch(canPlanMealsProvider);
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final ingredients = ref.watch(ingredientsProvider).value ?? const {};
    final matches = ref.watch(pantryMatchesProvider);
    final title = Theme.of(context).textTheme.titleMedium;

    if (recipes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(canPlan ? l10n.foodRecipesEmpty : l10n.foodRecipesEmptyViewer, textAlign: TextAlign.center),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (matches.isNotEmpty) ...[
          Text(l10n.foodCanCook, style: title),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final m in matches.take(5))
                  ListTile(
                    key: Key('match-${m.recipe.name}'),
                    leading: CircleAvatar(
                      backgroundColor: m.missing.isEmpty ? HomeColors.dahon : HomeColors.mangga,
                      foregroundColor: m.missing.isEmpty ? Colors.white : HomeColors.narra,
                      child: const Icon(Icons.kitchen_outlined),
                    ),
                    title: Text(m.recipe.name),
                    subtitle: Text(matchLine(l10n, m)),
                    onTap: () => _openSheet(context, RecipeSheet(recipeId: m.recipe.id)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(l10n.foodYourRecipes, style: title),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (final r in recipes)
                ListTile(
                  key: Key('recipe-${r.name}'),
                  leading: const CircleAvatar(
                    backgroundColor: HomeColors.dahon,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.menu_book_outlined),
                  ),
                  title: Row(
                    children: [
                      Flexible(child: Text(r.name, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      SyncMarker(entity: 'recipes', id: r.id),
                    ],
                  ),
                  subtitle: Text(
                    [
                      if (r.servings != null) l10n.foodServingsCount(r.servings!),
                      l10n.foodIngredientCount(ingredients[r.id]?.length ?? 0),
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openSheet(context, RecipeSheet(recipeId: r.id)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A recipe: ingredients (with what the pantry has), steps and note.
class RecipeSheet extends ConsumerWidget {
  const RecipeSheet({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final r = ref.watch(recipesByIdProvider)[recipeId];
    if (r == null) return const SizedBox.shrink();
    final canPlan = ref.watch(canPlanMealsProvider);
    final lines = ref.watch(ingredientsProvider).value?[recipeId] ?? const <RecipeIngredient>[];
    final pantry = ref.watch(pantryItemsProvider).value ?? const <PantryItem>[];
    final title = Theme.of(context).textTheme.titleMedium;

    return SheetBody(
      title: r.name,
      children: [
        if (r.servings != null) Text(l10n.foodServingsCount(r.servings!)),
        const SizedBox(height: 12),
        Text(l10n.foodIngredients, style: title),
        if (lines.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.foodIngredientCount(0))),
        for (final i in lines)
          () {
            final short = canPlan ? shortfall(Need(i.name, i.quantity, i.unit), pantry) : null;
            return ListTile(
              key: Key('line-${i.name}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: canPlan
                  ? Icon(
                      short == null ? Icons.check_circle : Icons.shopping_cart_outlined,
                      color: short == null ? HomeColors.dahon : HomeColors.narra,
                    )
                  : const Icon(Icons.circle, size: 8),
              title: Text(i.name),
              subtitle: amountText(i.quantity, i.unit) == null ? null : Text(amountText(i.quantity, i.unit)!),
              trailing: !canPlan
                  ? null
                  : Text(
                      short == null
                          ? l10n.foodInPantry
                          : short.isEmpty
                          ? l10n.foodToBuy
                          : l10n.foodToBuyAmount(short),
                    ),
            );
          }(),
        if (r.steps != null) ...[
          const SizedBox(height: 12),
          Text(l10n.foodSteps, style: title),
          const SizedBox(height: 4),
          Text(r.steps!),
        ],
        if (r.note != null) ...[
          const SizedBox(height: 12),
          Text(l10n.foodNote, style: title),
          const SizedBox(height: 4),
          Text(r.note!),
        ],
        if (canPlan) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('recipe-edit'),
            onPressed: () {
              Navigator.pop(context);
              _openSheet(context, RecipeForm(recipe: r));
            },
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.foodEdit),
          ),
        ],
      ],
    );
  }
}

class _Line {
  _Line({this.id, String name = '', String qty = '', String unit = ''})
    : name = TextEditingController(text: name),
      qty = TextEditingController(text: qty),
      unit = TextEditingController(text: unit);

  final String? id;
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController unit;

  void dispose() {
    name.dispose();
    qty.dispose();
    unit.dispose();
  }
}

/// Adds or edits a recipe and its ingredient lines.
class RecipeForm extends ConsumerStatefulWidget {
  const RecipeForm({super.key, this.recipe});

  final Recipe? recipe;

  @override
  ConsumerState<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends ConsumerState<RecipeForm> {
  late final _name = TextEditingController(text: widget.recipe?.name);
  late final _servings = TextEditingController(text: widget.recipe?.servings?.toString());
  late final _steps = TextEditingController(text: widget.recipe?.steps);
  late final _note = TextEditingController(text: widget.recipe?.note);
  late final List<_Line> _lines;
  bool _nameMissing = false;

  @override
  void initState() {
    super.initState();
    final saved = widget.recipe == null
        ? const <RecipeIngredient>[]
        : ref.read(ingredientsProvider).value?[widget.recipe!.id] ?? const <RecipeIngredient>[];
    _lines = [
      for (final i in saved)
        _Line(id: i.id, name: i.name, qty: i.quantity == null ? '' : amountText(i.quantity, null)!, unit: i.unit ?? ''),
      if (saved.isEmpty) _Line(),
    ];
  }

  @override
  void dispose() {
    for (final c in [_name, _servings, _steps, _note]) {
      c.dispose();
    }
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameMissing = true);
      return;
    }
    final repo = ref.read(foodRepoProvider);
    final servings = int.tryParse(_servings.text.trim());
    final lines = [
      for (final l in _lines) (id: l.id, name: l.name.text, quantity: parseAmount(l.qty.text), unit: l.unit.text),
    ];
    final r = widget.recipe;
    if (r == null) {
      await repo.addRecipe(
        name: _name.text,
        servings: servings,
        steps: _steps.text,
        note: _note.text,
        ingredients: lines,
      );
    } else {
      await repo.editRecipe(
        r,
        name: _name.text,
        servings: servings,
        steps: _steps.text,
        note: _note.text,
        ingredients: lines,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final r = widget.recipe!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.foodDeleteRecipeConfirm(r.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            key: const Key('recipe-delete-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.foodDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(foodRepoProvider).removeRecipe(r.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = Theme.of(context).textTheme.titleMedium;
    return SheetBody(
      title: widget.recipe == null ? l10n.foodAddRecipe : l10n.foodEditRecipe,
      children: [
        TextField(
          key: const Key('recipe-name'),
          controller: _name,
          autofocus: widget.recipe == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.foodRecipeName,
            errorText: _nameMissing ? l10n.foodRecipeNameRequired : null,
          ),
          onChanged: (_) {
            if (_nameMissing) setState(() => _nameMissing = false);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('recipe-servings'),
          controller: _servings,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.foodServings),
        ),
        const SizedBox(height: 16),
        Text(l10n.foodIngredients, style: title),
        const SizedBox(height: 8),
        for (final (n, l) in _lines.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    key: Key('ing-name-$n'),
                    controller: l.name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l10n.foodIngredientName),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: Key('ing-qty-$n'),
                    controller: l.qty,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.foodQuantity),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: Key('ing-unit-$n'),
                    controller: l.unit,
                    decoration: InputDecoration(labelText: l10n.foodUnit),
                  ),
                ),
                IconButton(
                  tooltip: l10n.foodRemoveIngredient,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _lines.removeAt(n).dispose()),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('ing-add'),
            onPressed: () => setState(() => _lines.add(_Line())),
            icon: const Icon(Icons.add),
            label: Text(l10n.foodAddIngredient),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('recipe-steps'),
          controller: _steps,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.foodSteps, alignLabelWithHint: true),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('recipe-note'),
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.foodNote),
        ),
        const SizedBox(height: 16),
        FilledButton(key: const Key('recipe-save'), onPressed: _save, child: Text(l10n.save)),
        if (widget.recipe != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            key: const Key('recipe-delete'),
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.foodDeleteRecipe),
          ),
        ],
      ],
    );
  }
}
