import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../sync/sync_widgets.dart';
import 'grocery_history_screen.dart';
import 'pantry_providers.dart';
import 'pantry_repository.dart';

/// Pantry & Grocery: the shared shopping list and what's in stock.
class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final toBuy = ref.watch(toBuyProvider).value?.length ?? 0;
    final low = ref.watch(pantryItemsProvider).value?.where(isLow).length ?? 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              figure: l10n.groceryToBuy(toBuy),
              caption: l10n.pantryLowCaption(low),
              color: HomeColors.ube,
              leading: const BackButton(color: Colors.white),
            ),
            Material(
              color: HomeColors.ube,
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: HomeColors.mangga,
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: l10n.groceryTab),
                  Tab(text: l10n.pantryTab),
                ],
              ),
            ),
            const Expanded(child: TabBarView(children: [GroceryTab(), PantryTab()])),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ grocery

class GroceryTab extends ConsumerStatefulWidget {
  const GroceryTab({super.key});

  @override
  ConsumerState<GroceryTab> createState() => _GroceryTabState();
}

class _GroceryTabState extends ConsumerState<GroceryTab> {
  final _add = TextEditingController();

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  Future<void> _quickAdd() async {
    final name = _add.text.trim();
    if (name.isEmpty) return;
    _add.clear();
    await ref.read(pantryRepoProvider).addGrocery(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final toBuy = ref.watch(toBuyProvider).value ?? const <GroceryItem>[];
    final bought = ref.watch(boughtProvider).value ?? const <GroceryItem>[];
    final canEdit = ref.watch(canEditPantryProvider);
    final names = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m.name};

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (canEdit) ...[
          TextField(
            key: const Key('grocery-add'),
            controller: _add,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.groceryAddHint,
              suffixIcon: IconButton(
                tooltip: l10n.groceryAdd,
                icon: const Icon(Icons.add_circle, color: HomeColors.ube),
                onPressed: _quickAdd,
              ),
            ),
            // Keeps the field focused so several items can be typed in a row.
            onEditingComplete: _quickAdd,
          ),
          const SizedBox(height: 16),
        ],
        if (toBuy.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.groceryEmpty, textAlign: TextAlign.center),
          )
        else
          Card(
            child: Column(
              children: [
                for (final g in toBuy) _GroceryTile(item: g, requester: names[g.requestedBy], canEdit: canEdit),
              ],
            ),
          ),
        if (bought.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text(l10n.groceryBought, style: Theme.of(context).textTheme.titleMedium)),
              if (canEdit)
                TextButton(
                  onPressed: () => ref.read(pantryRepoProvider).clearBought(),
                  child: Text(l10n.groceryClearBought),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final g in bought) _GroceryTile(item: g, requester: names[g.requestedBy], canEdit: canEdit),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          child: TextButton.icon(
            key: const Key('grocery-history'),
            onPressed: () => context.push(Routes.groceryHistory),
            icon: const Icon(Icons.history),
            label: Text(l10n.groceryHistory),
          ),
        ),
      ],
    );
  }
}

class _GroceryTile extends ConsumerWidget {
  const _GroceryTile({required this.item, required this.requester, required this.canEdit});

  final GroceryItem item;
  final String? requester;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final details = [?item.quantityText, ?item.store, if (requester != null) l10n.groceryFor(requester!)].join(' · ');
    return ListTile(
      leading: Checkbox(
        value: item.isBought,
        activeColor: HomeColors.dahon,
        onChanged: canEdit ? (v) => ref.read(pantryRepoProvider).setBought(item.id, v ?? false) : null,
      ),
      title: Text(
        item.name,
        style: item.isBought ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black45) : null,
      ),
      subtitle: details.isEmpty ? null : Text(details),
      trailing: item.isBought && item.boughtAt != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BoughtChip(item: item, canEdit: canEdit),
                SyncMarker(entity: 'grocery_items', id: item.id),
              ],
            )
          : SyncMarker(entity: 'grocery_items', id: item.id),
      onTap: canEdit
          ? () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => GroceryForm(item: item),
            )
          : null,
    );
  }
}

/// The day a bought item was bought ("Today" unless changed); tap to change.
class _BoughtChip extends ConsumerWidget {
  const _BoughtChip({required this.item, required this.canEdit});

  final GroceryItem item;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final at = item.boughtAt!.toLocal();
    final day = DateTime(at.year, at.month, at.day);
    return ActionChip(
      key: Key('bought-on-${item.id}'),
      label: Text(boughtDayLabel(context, day, DateTime.now())),
      tooltip: canEdit ? l10n.groceryChangeDate : null,
      backgroundColor: HomeColors.mangga.withValues(alpha: 0.25),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      visualDensity: VisualDensity.compact,
      onPressed: canEdit
          ? () async {
              final picked = await pickBoughtDay(context, day);
              if (picked != null && picked != day) await ref.read(pantryRepoProvider).setBoughtOn(item, picked);
            }
          : null,
    );
  }
}

class GroceryForm extends ConsumerStatefulWidget {
  const GroceryForm({super.key, required this.item});

  final GroceryItem item;

  @override
  ConsumerState<GroceryForm> createState() => _GroceryFormState();
}

class _GroceryFormState extends ConsumerState<GroceryForm> {
  late final _name = TextEditingController(text: widget.item.name);
  late final _qty = TextEditingController(text: widget.item.quantityText ?? '');
  late final _store = TextEditingController(text: widget.item.store ?? '');
  late final _note = TextEditingController(text: widget.item.note ?? '');
  late final DateTime? _boughtDay = _dayOf(widget.item.boughtAt);
  late DateTime? _day = _boughtDay;
  bool _tried = false;

  static DateTime? _dayOf(DateTime? at) {
    if (at == null) return null;
    final l = at.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  @override
  void dispose() {
    for (final c in [_name, _qty, _store, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(pantryRepoProvider);
    await repo.editGrocery(
      widget.item,
      name: _name.text,
      quantityText: _qty.text,
      store: _store.text,
      note: _note.text,
    );
    if (widget.item.isBought && _day != null && _day != _boughtDay) await repo.setBoughtOn(widget.item, _day!);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _remove() async {
    await ref.read(pantryRepoProvider).removeGrocery(widget.item.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Sheet(
      title: l10n.groceryEditTitle,
      children: [
        TextField(
          key: const Key('grocery-name'),
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qty,
          decoration: InputDecoration(labelText: l10n.groceryQuantity, hintText: l10n.groceryQuantityHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _store,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.groceryStore, hintText: l10n.groceryStoreHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.itemNote),
        ),
        if (widget.item.isBought && _day != null) ...[
          const SizedBox(height: 8),
          ListTile(
            key: const Key('grocery-bought-on'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(l10n.groceryBoughtOn(boughtDayLabel(context, _day!, DateTime.now()))),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final picked = await pickBoughtDay(context, _day!);
              if (picked != null) setState(() => _day = picked);
            },
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
        TextButton(
          onPressed: _remove,
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          child: Text(l10n.groceryRemove),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- pantry

class PantryTab extends ConsumerWidget {
  const PantryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(pantryItemsProvider).value ?? const <PantryItem>[];
    final canEdit = ref.watch(canEditPantryProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (canEdit) ...[
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const PantryForm(),
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.pantryAdd),
            style: OutlinedButton.styleFrom(
              foregroundColor: HomeColors.ube,
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.pantryEmpty, textAlign: TextAlign.center),
          )
        else
          Card(
            child: Column(
              children: [for (final p in items) _PantryTile(item: p, canEdit: canEdit)],
            ),
          ),
      ],
    );
  }
}

class _PantryTile extends ConsumerWidget {
  const _PantryTile({required this.item, required this.canEdit});

  final PantryItem item;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(pantryRepoProvider);
    final qty = formatQuantity(item.quantity);
    final status = pantryStatus(l10n, item, DateTime.now());
    final where = [item.unit == null ? qty : '$qty ${item.unit}', ?item.location].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      title: Row(
        children: [
          Flexible(child: Text(item.name, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 6),
          SyncMarker(entity: 'pantry_items', id: item.id),
        ],
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: where),
            if (status != null) ...[
              const TextSpan(text: ' · '),
              TextSpan(
                text: status.$1,
                style: TextStyle(color: status.$2, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
      trailing: canEdit
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.pantryUseOne(item.name),
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: item.quantity >= 1 ? () => repo.adjust(item.id, -1) : null,
                ),
                IconButton(
                  tooltip: l10n.pantryAddOne(item.name),
                  icon: const Icon(Icons.add_circle_outline, color: HomeColors.dahon),
                  onPressed: () => repo.adjust(item.id, 1),
                ),
              ],
            )
          : null,
      onTap: canEdit
          ? () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => PantryForm(item: item),
            )
          : null,
    );
  }
}

/// Short status for a pantry row and its colour, or null when all is fine.
/// Gumamela is kept for expired food only (the design reserves it for
/// overdue and emergencies).
(String, Color)? pantryStatus(AppLocalizations l10n, PantryItem p, DateTime today) {
  final expiry = expiryOf(p, today);
  if (expiry == Expiry.expired) return (l10n.pantryExpired, HomeColors.gumamela);
  if (expiry == Expiry.soon) {
    return (l10n.pantryExpiresIn(daysUntil(DateTime.parse(p.expiresOn!), today)), const Color(0xFF9A6B00));
  }
  if (isLow(p)) return (l10n.pantryLow, const Color(0xFF9A6B00));
  return null;
}

class PantryForm extends ConsumerStatefulWidget {
  const PantryForm({super.key, this.item});

  /// Null when adding.
  final PantryItem? item;

  @override
  ConsumerState<PantryForm> createState() => _PantryFormState();
}

class _PantryFormState extends ConsumerState<PantryForm> {
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late final _unit = TextEditingController(text: widget.item?.unit ?? '');
  late final _qty = TextEditingController(text: widget.item == null ? '' : formatQuantity(widget.item!.quantity));
  late final _min = TextEditingController(
    text: widget.item?.minQuantity == null ? '' : formatQuantity(widget.item!.minQuantity!),
  );
  late final _location = TextEditingController(text: widget.item?.location ?? '');
  late String? _expires = widget.item?.expiresOn;
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_name, _unit, _qty, _min, _location]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _number(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool get _qtyInvalid => _qty.text.trim().isNotEmpty && (_number(_qty) == null || _number(_qty)! < 0);
  bool get _minInvalid => _min.text.trim().isNotEmpty && (_number(_min) == null || _number(_min)! < 0);

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _qtyInvalid || _minInvalid) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(pantryRepoProvider);
    final item = widget.item;
    if (item == null) {
      await repo.addPantry(
        name: _name.text,
        unit: _unit.text,
        quantity: _number(_qty) ?? 0,
        minQuantity: _number(_min),
        location: _location.text,
        expiresOn: _expires,
      );
    } else {
      await repo.editPantry(
        item,
        name: _name.text,
        unit: _unit.text,
        minQuantity: _number(_min),
        location: _location.text,
        expiresOn: _expires,
      );
      final count = _number(_qty);
      if (count != null) await repo.setQuantity(item, count);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expires == null ? now : DateTime.parse(_expires!),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _expires = isoDate(picked));
  }

  Future<void> _toGrocery() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = await ref.read(pantryRepoProvider).addToGrocery(widget.item!);
    if (mounted) Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(added ? l10n.pantryAddedToList : l10n.pantryAlreadyOnList)));
  }

  Future<void> _remove() async {
    await ref.read(pantryRepoProvider).removePantry(widget.item!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final adding = widget.item == null;
    const numbers = TextInputType.numberWithOptions(decimal: true);
    return _Sheet(
      title: adding ? l10n.pantryAdd : l10n.pantryEditTitle,
      children: [
        TextField(
          key: const Key('pantry-name'),
          controller: _name,
          autofocus: adding,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('pantry-quantity'),
                controller: _qty,
                keyboardType: numbers,
                decoration: InputDecoration(
                  labelText: adding ? l10n.pantryQuantity : l10n.pantryCountNow,
                  errorText: _tried && _qtyInvalid ? l10n.pantryNumber : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _unit,
                decoration: InputDecoration(labelText: l10n.pantryUnit, hintText: l10n.pantryUnitHint),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('pantry-min'),
          controller: _min,
          keyboardType: numbers,
          decoration: InputDecoration(
            labelText: l10n.pantryMin,
            helperText: l10n.pantryMinHelp,
            errorText: _tried && _minInvalid ? l10n.pantryNumber : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _location,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.pantryLocation, hintText: l10n.pantryLocationHint),
        ),
        const SizedBox(height: 4),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(_expires == null ? l10n.pantryNoExpiry : l10n.pantryExpiresOn(_expires!)),
          onTap: _pickDate,
          trailing: _expires == null
              ? null
              : IconButton(
                  tooltip: l10n.pantryClearExpiry,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _expires = null),
                ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
        if (!adding) ...[
          TextButton.icon(
            onPressed: _toGrocery,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(l10n.pantryToGrocery),
          ),
          TextButton(
            onPressed: _remove,
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            child: Text(l10n.pantryRemove),
          ),
        ],
      ],
    );
  }
}

/// Bottom-sheet body that stays above the keyboard and scrolls when tall.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
