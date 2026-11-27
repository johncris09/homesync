import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../sync/sync_widgets.dart';
import 'inventory_providers.dart';
import 'inventory_repository.dart';

const _manggaText = Color(0xFF8A5A00); // Mangga, darkened for text

IconData categoryIcon(String category) => switch (category) {
  'appliance' => Icons.kitchen_outlined,
  'electronics' => Icons.tv_outlined,
  'furniture' => Icons.chair_outlined,
  'tools' => Icons.handyman_outlined,
  _ => Icons.inventory_2_outlined,
};

/// "Carrier · Inverter 1HP" (brand and model, when set).
String? makeLine(InventoryItem i) {
  final parts = [?i.brand, ?i.model];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// What needs attention about [i]: its warranty ending soon, or who has it.
String? attentionLine(AppLocalizations l10n, String locale, InventoryItem i, DateTime today) {
  final w = warrantyOf(i, today);
  if (w == Warranty.soon) {
    return l10n.inventoryWarrantyEnds(DateFormat.MMMd(locale).format(parseIsoDate(i.warrantyUntil)!));
  }
  if (i.lentTo != null) {
    final since = parseIsoDate(i.lentOn);
    return since == null
        ? l10n.inventoryLentTo(i.lentTo!)
        : l10n.inventoryLentSince(i.lentTo!, DateFormat.MMMd(locale).format(since));
  }
  return null;
}

void _openSheet(BuildContext context, Widget sheet) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

/// Household Inventory: everything by room (owner picked layout A), with
/// warranties ending soon and things lent out on top.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final s = ref.watch(inventorySummaryProvider);
    final adult = ref.watch(canEditInventoryProvider);
    final query = _search.text;
    final groups = s.byRoom(query: query);
    final attention = query.isEmpty ? s.needsAttention : const <InventoryItem>[];
    final title = Theme.of(context).textTheme.titleMedium;

    final figure = s.isEmpty ? l10n.inventoryNoneFigure : l10n.inventoryCountFigure(s.count);
    final caption = s.isEmpty
        ? l10n.inventoryEmptyCaption
        : [
            if (adult && s.totalValue > 0) l10n.inventoryWorth(formatPeso(s.totalValue, locale: locale, whole: true)),
            l10n.inventoryRoomCount(s.rooms.length),
            if (s.needsAttention.isNotEmpty) l10n.inventoryAttentionCount(s.needsAttention.length),
          ].join(' · ');

    return Scaffold(
      floatingActionButton: !adult || s.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('add-item'),
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => _openSheet(context, const ItemForm()),
              icon: const Icon(Icons.add),
              label: Text(l10n.inventoryAddItem),
            ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: HomeColors.ube,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (s.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(adult ? l10n.inventoryEmpty : l10n.inventoryEmptyHelper, textAlign: TextAlign.center),
                  ),
                  if (adult)
                    Center(
                      child: FilledButton.icon(
                        key: const Key('add-item'),
                        onPressed: () => _openSheet(context, const ItemForm()),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.inventoryAddItem),
                      ),
                    ),
                ] else ...[
                  TextField(
                    key: const Key('inventory-search'),
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.inventorySearch,
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.inventoryClearSearch,
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(_search.clear),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (attention.isNotEmpty) ...[
                    Text(l10n.inventoryNeedsAttention, style: title),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(children: [for (final i in attention) _ItemTile(item: i, attention: true)]),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (groups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(l10n.inventoryNoMatch, textAlign: TextAlign.center),
                    ),
                  for (final (room, items) in groups) ...[
                    Text(room.isEmpty ? l10n.inventoryNoRoom : room, style: title),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(children: [for (final i in items) _ItemTile(item: i)]),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item, this.attention = false});

  final InventoryItem item;

  /// In the "Needs attention" list: say why, and the room.
  final bool attention;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(inventoryRepoProvider).today;
    final why = attentionLine(l10n, locale, item, today);
    final soon = warrantyOf(item, today) == Warranty.soon;
    final details = attention ? [?item.room, ?makeLine(item)].join(' · ') : makeLine(item);
    return ListTile(
      key: Key('item-${item.name}${attention ? '-attention' : ''}'),
      leading: _Thumb(item: item),
      title: Text(item.name, overflow: TextOverflow.ellipsis),
      subtitle: (details == null || details.isEmpty) && why == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details != null && details.isNotEmpty) Text(details, overflow: TextOverflow.ellipsis),
                if (why != null)
                  Text(
                    why,
                    style: TextStyle(color: soon ? _manggaText : HomeColors.dagat, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
      trailing: SyncMarker(entity: 'inventory_items', id: item.id),
      onTap: () => _openSheet(context, ItemSheet(itemId: item.id)),
    );
  }
}

/// The item's photo as a small round picture, or its category icon.
class _Thumb extends ConsumerWidget {
  const _Thumb({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = CircleAvatar(
      backgroundColor: HomeColors.ube,
      foregroundColor: Colors.white,
      child: Icon(categoryIcon(item.category)),
    );
    final sha = item.photoSha256;
    if (sha == null) return icon;
    final bytes = ref.watch(inventoryPhotoProvider(sha)).value;
    if (bytes == null) return icon;
    return CircleAvatar(backgroundImage: MemoryImage(bytes));
  }
}

/// The full photo, or a note when it hasn't reached this device yet.
class _Photo extends ConsumerWidget {
  const _Photo({required this.sha});

  final String sha;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final photo = ref.watch(inventoryPhotoProvider(sha));
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 200,
        child: switch (photo) {
          AsyncData(value: final bytes?) => Image.memory(bytes, key: const Key('item-photo'), fit: BoxFit.cover),
          AsyncLoading() => const ColoredBox(
            color: HomeColors.capiz,
            child: Center(child: CircularProgressIndicator()),
          ),
          _ => ColoredBox(
            color: HomeColors.capiz,
            child: Center(
              child: TextButton.icon(
                onPressed: () => ref.invalidate(inventoryPhotoProvider(sha)),
                icon: const Icon(Icons.cloud_download_outlined),
                label: Text(l10n.inventoryPhotoNotHere),
              ),
            ),
          ),
        },
      ),
    );
  }
}

/// One item: photo, details, and for adults lend / return, edit, remove.
class ItemSheet extends ConsumerWidget {
  const ItemSheet({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(inventoryRepoProvider);
    final adult = ref.watch(canEditInventoryProvider);
    final item = ref.watch(inventoryItemProvider(itemId)).value;
    if (item == null) return const SizedBox(height: 120);
    final text = Theme.of(context).textTheme;
    String date(String iso) => DateFormat.yMMMd(locale).format(parseIsoDate(iso)!);

    void replace(Widget sheet) {
      Navigator.pop(context);
      _openSheet(context, sheet);
    }

    Future<void> pickPhoto(ImageSource source) async {
      final x = await ImagePicker().pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
      if (x == null) return;
      try {
        await repo.setPhoto(item, await x.readAsBytes());
      } on PhotoTooBig {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.inventoryPhotoTooBig)));
        }
      }
    }

    final warranty = warrantyOf(item, repo.today);
    final warrantyText = switch (warranty) {
      Warranty.none => null,
      Warranty.active => l10n.inventoryWarrantyUntil(date(item.warrantyUntil!)),
      Warranty.soon => l10n.inventoryWarrantyEnds(date(item.warrantyUntil!)),
      Warranty.ended => l10n.inventoryWarrantyEnded(date(item.warrantyUntil!)),
    };
    final bought = [
      if (item.boughtOn != null) l10n.inventoryBoughtOn(date(item.boughtOn!)),
      if (adult && item.priceMinor != null) formatPeso(item.priceMinor!, locale: locale, whole: true),
    ].join(' · ');

    return SheetBody(
      title: item.name,
      children: [
        if (item.photoSha256 != null) ...[_Photo(sha: item.photoSha256!), const SizedBox(height: 8)],
        if (adult)
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                key: const Key('item-take-photo'),
                avatar: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(item.photoSha256 == null ? l10n.inventoryTakePhoto : l10n.inventoryRetakePhoto),
                onPressed: () => pickPhoto(ImageSource.camera),
              ),
              ActionChip(
                key: const Key('item-choose-photo'),
                avatar: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(l10n.inventoryChoosePhoto),
                onPressed: () => pickPhoto(ImageSource.gallery),
              ),
              if (item.photoSha256 != null)
                ActionChip(
                  avatar: const Icon(Icons.hide_image_outlined, size: 18),
                  label: Text(l10n.inventoryRemovePhoto),
                  onPressed: () => repo.removePhoto(item),
                ),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          [l10n.inventoryCategory(item.category), item.room ?? l10n.inventoryNoRoom].join(' · '),
          key: const Key('item-where'),
          style: text.titleMedium,
        ),
        if (makeLine(item) != null) Text(makeLine(item)!, style: text.bodyMedium),
        if (item.serialNo != null) Text(l10n.inventorySerialLine(item.serialNo!), style: text.bodyMedium),
        if (bought.isNotEmpty) Text(bought, style: text.bodyMedium),
        if (warrantyText != null)
          Text(
            warrantyText,
            key: const Key('item-warranty'),
            style: text.bodyMedium?.copyWith(
              color: switch (warranty) {
                Warranty.soon => _manggaText,
                Warranty.ended => HomeColors.gumamela,
                _ => HomeColors.dahon,
              },
              fontWeight: FontWeight.w600,
            ),
          ),
        if (item.lentTo != null)
          Text(
            attentionLine(l10n, locale, item.copyWith(warrantyUntil: const Value(null)), repo.today)!,
            key: const Key('item-lent'),
            style: text.bodyMedium?.copyWith(color: HomeColors.dagat, fontWeight: FontWeight.w600),
          ),
        if (item.note != null) Text(item.note!, style: text.bodySmall),
        if (adult) ...[
          const SizedBox(height: 16),
          if (item.lentTo == null)
            FilledButton.icon(
              key: const Key('item-lend'),
              onPressed: () => _openSheet(context, LendForm(item: item)),
              icon: const Icon(Icons.outbox_outlined),
              label: Text(l10n.inventoryLend),
            )
          else
            FilledButton.icon(
              key: const Key('item-returned'),
              onPressed: () => repo.returned(item),
              icon: const Icon(Icons.move_to_inbox_outlined),
              label: Text(l10n.inventoryReturned),
            ),
          TextButton(
            onPressed: () => replace(ItemForm(item: item)),
            child: Text(l10n.inventoryEditItem),
          ),
          TextButton(
            key: const Key('item-remove'),
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(l10n.inventoryRemoveTitle(item.name)),
                  content: Text(l10n.inventoryRemoveBody),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.inventoryRemoveItem)),
                  ],
                ),
              );
              if (ok != true) return;
              await repo.remove(item.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.inventoryRemoveItem),
          ),
        ],
      ],
    );
  }
}

/// A date that can be left empty.
class _OptionalDate extends StatelessWidget {
  const _OptionalDate({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.first,
    required this.last,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime first;
  final DateTime last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: Text(value == null ? l10n.inventoryNotSet : DateFormat.yMMMd(locale).format(value!)),
      trailing: value == null
          ? null
          : IconButton(
              tooltip: l10n.inventoryClearDate,
              icon: const Icon(Icons.close),
              onPressed: () => onChanged(null),
            ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: first,
          lastDate: last,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Add or edit an item.
class ItemForm extends ConsumerStatefulWidget {
  const ItemForm({super.key, this.item});

  final InventoryItem? item;

  @override
  ConsumerState<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends ConsumerState<ItemForm> {
  late final ItemDraft? _start = widget.item == null ? null : ItemDraft.of(widget.item!);
  late final _name = TextEditingController(text: _start?.name ?? '');
  late final _room = TextEditingController(text: _start?.room ?? '');
  late final _brand = TextEditingController(text: _start?.brand ?? '');
  late final _model = TextEditingController(text: _start?.model ?? '');
  late final _serial = TextEditingController(text: _start?.serialNo ?? '');
  late final _price = TextEditingController(text: _pesoText(_start?.priceMinor));
  late final _note = TextEditingController(text: _start?.note ?? '');
  late String _category = _start?.category ?? inventoryCategories.first;
  late DateTime? _bought = _start?.boughtOn;
  late DateTime? _warranty = _start?.warrantyUntil;
  bool _tried = false;

  static String _pesoText(int? minor) =>
      minor == null ? '' : (minor % 100 == 0 ? '${minor ~/ 100}' : (minor / 100).toStringAsFixed(2));

  @override
  void dispose() {
    for (final c in [_name, _room, _brand, _model, _serial, _price, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _priceBad => _price.text.trim().isNotEmpty && (parsePeso(_price.text) ?? -1) < 0;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _priceBad) {
      setState(() => _tried = true);
      return;
    }
    final draft = ItemDraft(
      name: _name.text,
      category: _category,
      room: _room.text,
      brand: _brand.text,
      model: _model.text,
      serialNo: _serial.text,
      boughtOn: _bought,
      priceMinor: _price.text.trim().isEmpty ? null : parsePeso(_price.text),
      warrantyUntil: _warranty,
      note: _note.text,
    );
    final repo = ref.read(inventoryRepoProvider);
    final item = widget.item;
    if (item == null) {
      await repo.add(draft);
    } else {
      await repo.edit(item, draft);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(inventoryRepoProvider).today;
    final editing = widget.item != null;
    final used = ref.watch(inventorySummaryProvider).rooms;
    final rooms = [
      ...used,
      for (final r in l10n.inventoryDefaultRooms.split(','))
        if (!used.any((u) => u.toLowerCase() == r.trim().toLowerCase())) r.trim(),
    ];
    return SheetBody(
      title: editing ? l10n.inventoryEditItem : l10n.inventoryAddItem,
      children: [
        TextField(
          key: const Key('item-name'),
          controller: _name,
          autofocus: !editing,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.inventoryItemName,
            hintText: l10n.inventoryItemNameHint,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in inventoryCategories)
              ChoiceChip(
                key: Key('category-$c'),
                avatar: Icon(categoryIcon(c), size: 18),
                label: Text(l10n.inventoryCategory(c)),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('item-room'),
          controller: _room,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: l10n.inventoryRoom),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: [
            for (final r in rooms)
              ChoiceChip(
                key: Key('room-$r'),
                label: Text(r),
                selected: _room.text.trim().toLowerCase() == r.toLowerCase(),
                onSelected: (_) => setState(() => _room.text = r),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('item-brand'),
                controller: _brand,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.inventoryBrand),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const Key('item-model'),
                controller: _model,
                decoration: InputDecoration(labelText: l10n.inventoryModel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('item-serial'),
          controller: _serial,
          decoration: InputDecoration(labelText: l10n.inventorySerial),
        ),
        _OptionalDate(
          key: const Key('item-bought'),
          label: l10n.inventoryBought,
          value: _bought,
          onChanged: (d) => setState(() => _bought = d),
          first: DateTime(today.year - 40),
          last: today,
        ),
        TextField(
          key: const Key('item-price'),
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.inventoryPrice,
            errorText: _tried && _priceBad ? l10n.amountInvalid : null,
          ),
        ),
        _OptionalDate(
          key: const Key('item-warranty-until'),
          label: l10n.inventoryWarrantyField,
          value: _warranty,
          onChanged: (d) => setState(() => _warranty = d),
          first: DateTime(today.year - 10),
          last: DateTime(today.year + 15, 12, 31),
        ),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.inventoryNote),
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('item-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// Lend an item: to whom, since when.
class LendForm extends ConsumerStatefulWidget {
  const LendForm({super.key, required this.item});

  final InventoryItem item;

  @override
  ConsumerState<LendForm> createState() => _LendFormState();
}

class _LendFormState extends ConsumerState<LendForm> {
  final _who = TextEditingController();
  late DateTime _on = ref.read(inventoryRepoProvider).today;
  bool _tried = false;

  @override
  void dispose() {
    _who.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_who.text.trim().isEmpty) {
      setState(() => _tried = true);
      return;
    }
    await ref.read(inventoryRepoProvider).lend(widget.item, _who.text, on: _on);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(inventoryRepoProvider).today;
    return SheetBody(
      title: l10n.inventoryLendTitle(widget.item.name),
      children: [
        TextField(
          key: const Key('lend-who'),
          controller: _who,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.inventoryLendWho,
            errorText: _tried && _who.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.inventoryLendSince),
          subtitle: Text(DateFormat.yMMMEd(locale).format(_on)),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _on,
              firstDate: DateTime(today.year - 5),
              lastDate: today,
            );
            if (picked != null) setState(() => _on = picked);
          },
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('lend-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
