import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../budget/budget_repository.dart' show categoryLabel;
import '../members/members_screen.dart' show memberColor;
import '../sync/sync_widgets.dart';
import '../vault/vault_providers.dart' show vaultKeyRowProvider, vaultSessionProvider;
import 'health_providers.dart';
import 'health_repository.dart';

/// "8:00 PM" for a local `HH:MM`.
String slotLabel(BuildContext context, String hhmm) {
  final p = hhmm.split(':');
  return MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1])), alwaysUse24HourFormat: false);
}

String qty(String locale, double v) => NumberFormat.decimalPattern(locale).format(v);

String medicineTitle(Medicine m) => [m.name, ?m.strength].join(' ');

IconData checkupIcon(String kind) => kind == 'vaccine' ? Icons.vaccines_outlined : Icons.medical_services_outlined;

/// Health: today's doses first (owner's pick), then what is running low,
/// checkups and vaccines, all medicines, and each member's profile.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final sum = ref.watch(healthSummaryProvider);
    final medicines = ref.watch(medicinesProvider).value ?? const <Medicine>[];
    final manage = ref.watch(canManageHealthProvider);
    final members = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m};
    final next = sum.next;
    final checkup = sum.upcoming.firstOrNull;
    String? who(String? id) => id == null ? null : members[id]?.name;

    final String figure;
    final String caption;
    if (sum.slots.isEmpty) {
      figure = medicines.isEmpty ? l10n.healthNoMedicines : l10n.healthNoDosesToday;
      caption = checkup != null
          ? l10n.healthCheckupCaption(checkup.title, DateFormat.MMMd(locale).format(parseIsoDate(checkup.dueOn)!))
          : l10n.healthEmptyCaption;
    } else if (next == null) {
      figure = l10n.healthAllGiven;
      caption = l10n.healthAllGivenCaption(sum.slots.length);
    } else {
      figure = l10n.healthDosesLeft(sum.left);
      caption = l10n.healthNextDose(
        [?who(next.medicine.memberId), medicineTitle(next.medicine)].join(' · '),
        slotLabel(context, next.slot),
      );
    }

    void open(Widget sheet) =>
        showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

    Widget section(String title, List<Widget> tiles, {Widget? after}) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (tiles.isNotEmpty) Card(child: Column(children: tiles)),
          ?after,
        ],
      ),
    );

    final attention = {...sum.low, ...sum.expiring}.toList();

    return Scaffold(
      floatingActionButton: manage
          ? FloatingActionButton.extended(
              key: const Key('add-medicine'),
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => open(const MedicineForm()),
              icon: const Icon(Icons.add),
              label: Text(l10n.medicineAdd),
            )
          : null,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: HomeColors.dagat,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sum.slots.isNotEmpty)
                  section(l10n.healthToday, [for (final s in sum.slots) _DoseTile(slot: s, members: members)]),
                if (attention.isNotEmpty)
                  section(l10n.healthRunningLow, [for (final m in attention) _AttentionTile(medicine: m)]),
                section(
                  l10n.healthCheckups,
                  [for (final c in sum.upcoming) _CheckupTile(checkup: c, members: members)],
                  after: manage
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: const Key('add-checkup'),
                            onPressed: () => open(const CheckupForm()),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.checkupAdd),
                          ),
                        )
                      : (sum.upcoming.isEmpty ? Text(l10n.healthNoCheckups) : null),
                ),
                section(
                  l10n.healthMedicines,
                  [for (final m in medicines) _MedicineTile(medicine: m, members: members)],
                  after: medicines.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(l10n.healthMedicinesEmpty),
                        )
                      : null,
                ),
                if (manage) const _FamilySection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseTile extends ConsumerWidget {
  const _DoseTile({required this.slot, required this.members});

  final DoseSlot slot;
  final Map<String, Member> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(healthRepoProvider);
    final canGive = ref.watch(canGiveDosesProvider);
    final m = slot.medicine;
    final dose = slot.dose;
    final forWhom = m.memberId == null ? null : members[m.memberId]?.name;
    final givenBy = dose?.givenBy == null ? null : members[dose!.givenBy]?.name;
    final when = slotLabel(context, slot.slot);
    final canUndo = dose != null && repo.canUndo(dose);
    return ListTile(
      key: Key('dose-${m.id}-${slot.slot}'),
      title: Text([?forWhom, medicineTitle(m)].join(' · ')),
      subtitle: Text(dose == null ? when : l10n.doseGivenBy(when, givenBy ?? l10n.someone)),
      trailing: dose == null
          ? Icon(Icons.radio_button_unchecked, color: canGive ? HomeColors.narra : Colors.black26)
          : const CircleAvatar(
              radius: 13,
              backgroundColor: HomeColors.dahon,
              foregroundColor: Colors.white,
              child: Icon(Icons.check, size: 18),
            ),
      onTap: !canGive
          ? null
          : dose == null
          ? () => repo.giveDose(m, slot: slot.slot)
          : canUndo
          ? () => repo.undoDose(dose)
          : null,
    );
  }
}

class _AttentionTile extends ConsumerWidget {
  const _AttentionTile({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(healthRepoProvider);
    final m = medicine;
    final expiry = parseIsoDate(m.expiresOn);
    final expiring = expiresSoon(m, repo.today);
    final expired = expiry != null && daysUntil(expiry, repo.today) < 0;
    return ListTile(
      title: Text(medicineTitle(m)),
      subtitle: Text(
        [
          if (isLowMedicine(m)) l10n.medicineLeft(qty(locale, m.stock)),
          if (expiring)
            expired
                ? l10n.medicineExpired(DateFormat.MMMd(locale).format(expiry))
                : l10n.medicineExpires(DateFormat.MMMd(locale).format(expiry!)),
        ].join(' · '),
        style: TextStyle(color: expired ? HomeColors.gumamela : null),
      ),
      trailing: ref.watch(canGiveDosesProvider) && isLowMedicine(m)
          ? TextButton(
              key: Key('to-list-${m.id}'),
              onPressed: () async {
                final added = await repo.addToGroceryList(m);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(added ? l10n.pantryAddedToList : l10n.pantryAlreadyOnList)));
                }
              },
              child: Text(l10n.medicineAddToList),
            )
          : null,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => MedicineSheet(medicineId: m.id),
      ),
    );
  }
}

class _CheckupTile extends ConsumerWidget {
  const _CheckupTile({required this.checkup, required this.members});

  final Checkup checkup;
  final Map<String, Member> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toString();
    final c = checkup;
    final today = ref.read(healthRepoProvider).today;
    final on = parseIsoDate(c.dueOn);
    final overdue = on != null && daysUntil(on, today) < 0;
    final whom = c.memberId == null ? null : members[c.memberId]?.name;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: HomeColors.dagat,
        foregroundColor: Colors.white,
        child: Icon(checkupIcon(c.kind)),
      ),
      title: Text(c.title),
      subtitle: Text(
        [
          ?whom,
          if (on != null) DateFormat.MMMEd(locale).format(on),
          if (c.dueTime != null) slotLabel(context, c.dueTime!),
          ?c.place,
        ].join(' · '),
        style: TextStyle(color: overdue ? HomeColors.gumamela : null),
      ),
      trailing: SyncMarker(entity: 'checkups', id: c.id),
      onTap: ref.watch(canManageHealthProvider)
          ? () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => CheckupSheet(checkup: c),
            )
          : null,
    );
  }
}

class _MedicineTile extends ConsumerWidget {
  const _MedicineTile({required this.medicine, required this.members});

  final Medicine medicine;
  final Map<String, Member> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final m = medicine;
    final times = parseTimes(m.times);
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: HomeColors.capiz,
        foregroundColor: HomeColors.narra,
        child: Icon(Icons.medication_outlined),
      ),
      title: Text(medicineTitle(m)),
      subtitle: Text(
        [
          m.memberId == null ? l10n.medicineForAnyone : (members[m.memberId]?.name ?? l10n.someone),
          times.isEmpty ? l10n.medicineAsNeeded : times.map((t) => slotLabel(context, t)).join(', '),
        ].join(' · '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.medicineLeft(qty(locale, m.stock)),
            style: TextStyle(fontWeight: FontWeight.w600, color: isLowMedicine(m) ? const Color(0xFF8A5A00) : null),
          ),
          const SizedBox(width: 6),
          SyncMarker(entity: 'medicines', id: m.id),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => MedicineSheet(medicineId: m.id),
      ),
    );
  }
}

class _FamilySection extends ConsumerWidget {
  const _FamilySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final members = (ref.watch(membersProvider).value ?? const <Member>[]).where((m) => m.deletedAt == null).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final unlocked = ref.watch(vaultSessionProvider.select((s) => s.unlocked));
    final setUp = ref.watch(vaultKeyRowProvider).value != null;
    final profiles = ref.watch(openProfilesProvider).value ?? const <String, HealthFields>{};
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.healthFamily, style: text.titleMedium),
        const SizedBox(height: 8),
        if (!unlocked)
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(setUp ? l10n.healthProfilesLocked : l10n.healthProfilesNoVault),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.vault),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (final m in members)
                  ListTile(
                    key: Key('profile-${m.id}'),
                    leading: CircleAvatar(
                      backgroundColor: memberColor(m.color),
                      foregroundColor: Colors.white,
                      child: Text(m.name.characters.first.toUpperCase()),
                    ),
                    title: Text(m.name),
                    subtitle: Text(_profileLine(l10n, profiles[m.id])),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => ProfileForm(member: m, fields: profiles[m.id]),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static String _profileLine(AppLocalizations l10n, HealthFields? f) {
    if (f == null || f.isEmpty) return l10n.profileEmpty;
    return [
      if (f.bloodType != null) l10n.profileBloodLine(f.bloodType!),
      if (f.allergies != null) l10n.profileAllergyLine(f.allergies!),
      ?f.conditions,
    ].join(' · ');
  }
}

/// One medicine, kept live: give a dose, restock, stock-take, add to the
/// grocery list, edit, remove, and recent doses.
class MedicineSheet extends ConsumerWidget {
  const MedicineSheet({super.key, required this.medicineId});

  final String medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(healthRepoProvider);
    final m = ref.watch(medicineProvider(medicineId)).value;
    if (m == null) return const SizedBox(height: 120);
    final doses = ref.watch(medicineDosesProvider(medicineId)).value ?? const <MedDose>[];
    final members = {for (final x in ref.watch(membersProvider).value ?? const <Member>[]) x.id: x.name};
    final manage = ref.watch(canManageHealthProvider);
    final canGive = ref.watch(canGiveDosesProvider);
    final times = parseTimes(m.times);
    final text = Theme.of(context).textTheme;

    void open(Widget sheet) =>
        showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

    return SheetBody(
      title: medicineTitle(m),
      children: [
        Text(
          [
            m.memberId == null ? l10n.medicineForAnyone : (members[m.memberId] ?? l10n.someone),
            times.isEmpty ? l10n.medicineAsNeeded : times.map((t) => slotLabel(context, t)).join(', '),
            if (m.endsOn != null) l10n.medicineUntil(DateFormat.MMMd(locale).format(parseIsoDate(m.endsOn)!)),
          ].join(' · '),
          style: text.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.medicineStockLine(qty(locale, m.stock), m.unit ?? l10n.medicineUnitDefault),
          key: const Key('medicine-stock'),
          style: text.titleLarge,
        ),
        if (m.expiresOn != null)
          Text(l10n.medicineExpires(DateFormat.yMMMd(locale).format(parseIsoDate(m.expiresOn)!))),
        if (m.note != null) ...[const SizedBox(height: 4), Text(m.note!, style: text.bodySmall)],
        const SizedBox(height: 16),
        if (canGive)
          FilledButton.icon(
            key: const Key('give-dose'),
            onPressed: () => repo.giveDose(m),
            icon: const Icon(Icons.medication_outlined),
            label: Text(l10n.medicineGiveDose),
          ),
        if (manage) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('restock'),
            onPressed: () => open(StockForm(medicine: m)),
            child: Text(l10n.medicineRestock),
          ),
          TextButton(
            onPressed: () => open(StockForm(medicine: m, count: true)),
            child: Text(l10n.medicineStockTake),
          ),
        ],
        if (canGive)
          TextButton(
            onPressed: () async {
              final added = await repo.addToGroceryList(m);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(added ? l10n.pantryAddedToList : l10n.pantryAlreadyOnList)));
              }
            },
            child: Text(l10n.medicineAddToList),
          ),
        if (manage) ...[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              open(MedicineForm(medicine: m));
            },
            child: Text(l10n.medicineEdit),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              await repo.removeMedicine(m.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.medicineRemove),
          ),
        ],
        const SizedBox(height: 8),
        Text(l10n.medicineDoses, style: text.titleMedium),
        if (doses.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.medicineDosesEmpty))
        else
          for (final d in doses)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                [
                  DateFormat.MMMEd(locale).format(parseIsoDate(d.takenOn)!),
                  if (d.slot != null) slotLabel(context, d.slot!) else l10n.medicineExtraDose,
                ].join(' · '),
              ),
              subtitle: Text(l10n.doseGivenByName(members[d.givenBy] ?? l10n.someone)),
              trailing: repo.canUndo(d)
                  ? IconButton(
                      tooltip: l10n.doseUndo,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => repo.undoDose(d),
                    )
                  : null,
            ),
      ],
    );
  }
}

/// Restock (adds, with an optional cost) or stock-take ([count]: sets what
/// was counted).
class StockForm extends ConsumerStatefulWidget {
  const StockForm({super.key, required this.medicine, this.count = false});

  final Medicine medicine;
  final bool count;

  @override
  ConsumerState<StockForm> createState() => _StockFormState();
}

class _StockFormState extends ConsumerState<StockForm> {
  final _qty = TextEditingController();
  final _cost = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    super.dispose();
  }

  double? get _qtyValue => double.tryParse(_qty.text.trim());
  bool get _qtyBad => _qtyValue == null || _qtyValue! < 0 || (!widget.count && _qtyValue! == 0);
  int? get _costValue => _cost.text.trim().isEmpty ? null : parsePeso(_cost.text);
  bool get _costBad => _cost.text.trim().isNotEmpty && _costValue == null;

  Future<void> _save() async {
    if (_qtyBad || _costBad) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(healthRepoProvider);
    if (widget.count) {
      await repo.stockTake(widget.medicine, _qtyValue!);
    } else {
      await repo.restock(widget.medicine, _qtyValue!, costMinor: _costValue);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: widget.count ? l10n.medicineStockTake : l10n.medicineRestock,
      children: [
        TextField(
          key: const Key('stock-qty'),
          controller: _qty,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: widget.count ? l10n.medicineCounted : l10n.medicineAdded,
            suffixText: widget.medicine.unit,
            errorText: _tried && _qtyBad ? l10n.amountInvalid : null,
          ),
        ),
        if (!widget.count) ...[
          const SizedBox(height: 12),
          TextField(
            key: const Key('stock-cost'),
            controller: _cost,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₱ ',
              labelText: l10n.medicineCost,
              errorText: _tried && _costBad ? l10n.amountInvalid : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.billPayHint(categoryLabel(l10n, healthCategory)), style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        FilledButton(key: const Key('stock-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// Who a medicine or checkup is for: a member, or anyone / the family.
class _MemberPicker extends ConsumerWidget {
  const _MemberPicker({required this.value, required this.onChanged, required this.anyoneLabel});

  final String? value;
  final ValueChanged<String?> onChanged;
  final String anyoneLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = (ref.watch(membersProvider).value ?? const <Member>[]).where((m) => m.deletedAt == null).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(label: Text(anyoneLabel), selected: value == null, onSelected: (_) => onChanged(null)),
        for (final m in members)
          ChoiceChip(label: Text(m.name), selected: value == m.id, onSelected: (_) => onChanged(m.id)),
      ],
    );
  }
}

Widget _dateTile(
  BuildContext context, {
  required Key key,
  required IconData icon,
  required String label,
  required String notSet,
  required DateTime? value,
  required DateTime today,
  required ValueChanged<DateTime?> onChanged,
}) {
  final locale = Localizations.localeOf(context).toString();
  return ListTile(
    key: key,
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value == null ? notSet : DateFormat.yMMMEd(locale).format(value)),
    trailing: value == null
        ? null
        : IconButton(
            tooltip: AppLocalizations.of(context).vehicleClearDate,
            icon: const Icon(Icons.close),
            onPressed: () => onChanged(null),
          ),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: value ?? today,
        firstDate: DateTime(today.year - 3),
        lastDate: DateTime(today.year + 5),
      );
      if (picked != null) onChanged(picked);
    },
  );
}

/// Add or edit a medicine (adults).
class MedicineForm extends ConsumerStatefulWidget {
  const MedicineForm({super.key, this.medicine});

  final Medicine? medicine;

  @override
  ConsumerState<MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends ConsumerState<MedicineForm> {
  late final _name = TextEditingController(text: widget.medicine?.name ?? '');
  late final _strength = TextEditingController(text: widget.medicine?.strength ?? '');
  late final _times = TextEditingController(text: parseTimes(widget.medicine?.times).join(', '));
  late final _stock = TextEditingController();
  late final _min = TextEditingController(text: _num(widget.medicine?.minStock));
  late final _unit = TextEditingController(text: widget.medicine?.unit ?? '');
  late final _note = TextEditingController(text: widget.medicine?.note ?? '');
  late String? _memberId = widget.medicine?.memberId;
  late DateTime? _endsOn = parseIsoDate(widget.medicine?.endsOn);
  late DateTime? _expiresOn = parseIsoDate(widget.medicine?.expiresOn);
  bool _tried = false;

  static String _num(double? v) => v == null ? '' : (v == v.roundToDouble() ? '${v.toInt()}' : '$v');

  @override
  void dispose() {
    for (final c in [_name, _strength, _times, _stock, _min, _unit, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _numOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : double.tryParse(c.text.trim());
  bool _bad(TextEditingController c) => c.text.trim().isNotEmpty && (_numOrNull(c) == null || _numOrNull(c)! < 0);
  bool get _timesBad =>
      _times.text.trim().isNotEmpty &&
      parseTimes(_times.text).length != _times.text.split(',').where((t) => t.trim().isNotEmpty).length;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _bad(_stock) || _bad(_min) || _timesBad) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(healthRepoProvider);
    final m = widget.medicine;
    if (m == null) {
      await repo.addMedicine(
        name: _name.text,
        strength: _strength.text,
        memberId: _memberId,
        times: _times.text,
        endsOn: _endsOn,
        stock: _numOrNull(_stock) ?? 0,
        minStock: _numOrNull(_min),
        unit: _unit.text,
        expiresOn: _expiresOn,
        note: _note.text,
      );
    } else {
      await repo.editMedicine(
        m,
        name: _name.text,
        strength: _strength.text,
        memberId: _memberId,
        times: _times.text,
        doseQty: m.doseQty,
        endsOn: _endsOn,
        minStock: _numOrNull(_min),
        unit: _unit.text,
        expiresOn: _expiresOn,
        note: _note.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(healthRepoProvider).today;
    final adding = widget.medicine == null;
    return SheetBody(
      title: adding ? l10n.medicineAdd : l10n.medicineEdit,
      children: [
        TextField(
          key: const Key('medicine-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.medicineNameHint,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('medicine-strength'),
          controller: _strength,
          decoration: InputDecoration(labelText: l10n.medicineStrength),
        ),
        const SizedBox(height: 12),
        Text(l10n.medicineForWhom, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        _MemberPicker(
          value: _memberId,
          anyoneLabel: l10n.medicineForAnyone,
          onChanged: (v) => setState(() => _memberId = v),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('medicine-times'),
          controller: _times,
          decoration: InputDecoration(
            labelText: l10n.medicineTimes,
            helperText: l10n.medicineTimesHelp,
            errorText: _tried && _timesBad ? l10n.medicineTimesInvalid : null,
          ),
        ),
        if (adding) ...[
          const SizedBox(height: 12),
          TextField(
            key: const Key('medicine-stock-field'),
            controller: _stock,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.medicineStockNow,
              errorText: _tried && _bad(_stock) ? l10n.amountInvalid : null,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('medicine-min'),
                controller: _min,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.medicineMin,
                  errorText: _tried && _bad(_min) ? l10n.amountInvalid : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _unit,
                decoration: InputDecoration(labelText: l10n.medicineUnit, hintText: l10n.medicineUnitDefault),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _dateTile(
          context,
          key: const Key('medicine-ends'),
          icon: Icons.event_available_outlined,
          label: l10n.medicineEndsOn,
          notSet: l10n.medicineOngoing,
          value: _endsOn,
          today: today,
          onChanged: (v) => setState(() => _endsOn = v),
        ),
        _dateTile(
          context,
          key: const Key('medicine-expiry'),
          icon: Icons.hourglass_bottom,
          label: l10n.medicineExpiry,
          notSet: l10n.vehicleNotSet,
          value: _expiresOn,
          today: today,
          onChanged: (v) => setState(() => _expiresOn = v),
        ),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.vehicleNote),
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('medicine-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// A checkup: mark done (with an optional cost), undo, edit, remove.
class CheckupSheet extends ConsumerStatefulWidget {
  const CheckupSheet({super.key, required this.checkup});

  final Checkup checkup;

  @override
  ConsumerState<CheckupSheet> createState() => _CheckupSheetState();
}

class _CheckupSheetState extends ConsumerState<CheckupSheet> {
  final _cost = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    _cost.dispose();
    super.dispose();
  }

  int? get _costValue => _cost.text.trim().isEmpty ? null : parsePeso(_cost.text);
  bool get _costBad => _cost.text.trim().isNotEmpty && _costValue == null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(healthRepoProvider);
    final c = widget.checkup;
    return SheetBody(
      title: c.title,
      children: [
        TextField(
          key: const Key('checkup-cost'),
          controller: _cost,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.checkupCost,
            errorText: _tried && _costBad ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.billPayHint(categoryLabel(l10n, healthCategory)), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('checkup-done'),
          onPressed: () async {
            if (_costBad) {
              setState(() => _tried = true);
              return;
            }
            await repo.markDone(c, costMinor: _costValue);
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.check),
          label: Text(l10n.checkupMarkDone),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => CheckupForm(checkup: c),
            );
          },
          child: Text(l10n.checkupEdit),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await repo.removeCheckup(c.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.checkupRemove),
        ),
      ],
    );
  }
}

/// Add or edit a checkup or vaccine (adults).
class CheckupForm extends ConsumerStatefulWidget {
  const CheckupForm({super.key, this.checkup});

  final Checkup? checkup;

  @override
  ConsumerState<CheckupForm> createState() => _CheckupFormState();
}

class _CheckupFormState extends ConsumerState<CheckupForm> {
  late String _kind = widget.checkup?.kind ?? 'checkup';
  late final _title = TextEditingController(text: widget.checkup?.title ?? '');
  late final _time = TextEditingController(text: widget.checkup?.dueTime ?? '');
  late final _place = TextEditingController(text: widget.checkup?.place ?? '');
  late final _note = TextEditingController(text: widget.checkup?.note ?? '');
  late String? _memberId = widget.checkup?.memberId;
  late DateTime? _dueOn = parseIsoDate(widget.checkup?.dueOn);
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_title, _time, _place, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _timeBad => _time.text.trim().isNotEmpty && parseTimes(_time.text).length != 1;

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _timeBad) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(healthRepoProvider);
    final time = _time.text.trim().isEmpty ? null : parseTimes(_time.text).single;
    final c = widget.checkup;
    if (c == null) {
      await repo.addCheckup(
        kind: _kind,
        title: _title.text,
        memberId: _memberId,
        dueOn: _dueOn,
        dueTime: time,
        place: _place.text,
        note: _note.text,
      );
    } else {
      await repo.editCheckup(
        c,
        kind: _kind,
        title: _title.text,
        memberId: _memberId,
        dueOn: _dueOn,
        dueTime: time,
        place: _place.text,
        note: _note.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(healthRepoProvider).today;
    return SheetBody(
      title: widget.checkup == null ? l10n.checkupAdd : l10n.checkupEdit,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final k in checkupKinds)
              ChoiceChip(
                avatar: Icon(checkupIcon(k), size: 18),
                label: Text(l10n.checkupKind(k)),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('checkup-title'),
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.checkupTitleHint(_kind),
            errorText: _tried && _title.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.medicineForWhom, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        _MemberPicker(
          value: _memberId,
          anyoneLabel: l10n.eventEveryone,
          onChanged: (v) => setState(() => _memberId = v),
        ),
        const SizedBox(height: 8),
        _dateTile(
          context,
          key: const Key('checkup-date'),
          icon: Icons.event_outlined,
          label: l10n.checkupDate,
          notSet: l10n.vehicleNotSet,
          value: _dueOn,
          today: today,
          onChanged: (v) => setState(() => _dueOn = v),
        ),
        TextField(
          key: const Key('checkup-time'),
          controller: _time,
          decoration: InputDecoration(
            labelText: l10n.checkupTime,
            helperText: l10n.checkupTimeHelp,
            errorText: _tried && _timeBad ? l10n.medicineTimesInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _place,
          decoration: InputDecoration(labelText: l10n.checkupPlace),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.vehicleNote),
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('checkup-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// A member's health profile, sealed with the vault key (vault open).
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key, required this.member, this.fields});

  final Member member;
  final HealthFields? fields;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  late final _blood = TextEditingController(text: widget.fields?.bloodType ?? '');
  late final _allergies = TextEditingController(text: widget.fields?.allergies ?? '');
  late final _conditions = TextEditingController(text: widget.fields?.conditions ?? '');
  late final _maintenance = TextEditingController(text: widget.fields?.maintenance ?? '');
  late final _philhealth = TextEditingController(text: widget.fields?.philhealth ?? '');
  late final _hmo = TextEditingController(text: widget.fields?.hmo ?? '');
  late final _doctor = TextEditingController(text: widget.fields?.doctor ?? '');
  late final _note = TextEditingController(text: widget.fields?.note ?? '');

  List<TextEditingController> get _all => [
    _blood,
    _allergies,
    _conditions,
    _maintenance,
    _philhealth,
    _hmo,
    _doctor,
    _note,
  ];

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(healthRepoProvider)
        .saveProfile(
          widget.member.id,
          HealthFields(
            bloodType: _blood.text,
            allergies: _allergies.text,
            conditions: _conditions.text,
            maintenance: _maintenance.text,
            philhealth: _philhealth.text,
            hmo: _hmo.text,
            doctor: _doctor.text,
            note: _note.text,
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  Widget _field(Key key, TextEditingController c, String label, {String? hint}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      key: key,
      controller: c,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: l10n.profileTitle(widget.member.name),
      children: [
        Text(l10n.profileSealedHelp, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        _field(const Key('profile-blood'), _blood, l10n.profileBlood, hint: 'O+'),
        _field(const Key('profile-allergies'), _allergies, l10n.profileAllergies),
        _field(const Key('profile-conditions'), _conditions, l10n.profileConditions),
        _field(const Key('profile-maintenance'), _maintenance, l10n.profileMaintenance),
        _field(const Key('profile-philhealth'), _philhealth, l10n.profilePhilhealth),
        _field(const Key('profile-hmo'), _hmo, l10n.profileHmo),
        _field(const Key('profile-doctor'), _doctor, l10n.profileDoctor),
        _field(const Key('profile-note'), _note, l10n.vehicleNote),
        const SizedBox(height: 8),
        FilledButton(key: const Key('profile-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
