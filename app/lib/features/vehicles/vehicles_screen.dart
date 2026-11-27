import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../bills/bills_screen.dart' show dueColor;
import '../bills/bills_repository.dart' show DueStatus;
import '../budget/budget_repository.dart' show categoryLabel;
import '../sync/sync_widgets.dart';
import 'vehicles_providers.dart';
import 'vehicles_repository.dart';

IconData vehicleIcon(String kind) => kind == 'motorcycle' ? Icons.two_wheeler : Icons.directions_car_outlined;

IconData dueIcon(String kind) => switch (kind) {
  'registration' => Icons.badge_outlined,
  'insurance' => Icons.shield_outlined,
  _ => Icons.build_outlined,
};

IconData logIcon(String kind) => switch (kind) {
  'fuel' => Icons.local_gas_station_outlined,
  'odometer' => Icons.speed,
  _ => dueIcon(kind),
};

Color vehicleDueColor(VehicleDue s) => dueColor(switch (s) {
  VehicleDue.overdue => DueStatus.overdue,
  VehicleDue.soon => DueStatus.soon,
  VehicleDue.later => DueStatus.later,
});

String km(String locale, int value) => NumberFormat.decimalPattern(locale).format(value);

/// "in 9 days" / "in 300 km" for [d], plus the other limit of a PMS due by
/// date and km ("or at 45,000 km").
({String when, String? extra}) dueWhen(AppLocalizations l10n, String locale, DueItem d, DateTime today) {
  String byDate(DateTime on) {
    final days = daysUntil(on, today);
    if (days < 0) return l10n.vehicleDueOverdue(-days);
    if (days <= vehicleSoonDays) return l10n.vehicleDueIn(days);
    return l10n.vehicleDueOn(DateFormat.MMMd(locale).format(on));
  }

  String byKm(int left) => left <= 0 ? l10n.vehicleKmPast(km(locale, -left)) : l10n.vehicleKmLeft(km(locale, left));

  if (d.kmLeft != null && (d.on == null || d.kmFirst)) {
    return (
      when: byKm(d.kmLeft!),
      extra: d.on == null ? null : l10n.vehicleOrOn(DateFormat.MMMd(locale).format(d.on!)),
    );
  }
  if (d.on != null) {
    return (when: byDate(d.on!), extra: d.km == null ? null : l10n.vehicleOrAt(km(locale, d.km!)));
  }
  return (when: l10n.vehicleAtKm(km(locale, d.km!)), extra: null);
}

/// Vehicles: what is due next across the household's cars and motorcycles
/// (registration, insurance, PMS), the vehicles, and their costs.
class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(vehiclesRepoProvider);
    final vehicles = ref.watch(vehiclesProvider).value ?? const <Vehicle>[];
    final summary = ref.watch(vehiclesSummaryProvider);
    final next = summary.next;
    final spent = formatPeso(summary.monthSpent, locale: locale, whole: true);

    final String figure;
    final String caption;
    if (vehicles.isEmpty) {
      figure = l10n.vehiclesNoneFigure;
      caption = l10n.vehiclesEmptyCaption;
    } else if (next == null) {
      figure = l10n.vehiclesNothingDue;
      caption = l10n.vehiclesSpentLine(spent);
    } else {
      final w = dueWhen(l10n, locale, next, repo.today);
      figure = l10n.vehiclesNextFigure(l10n.vehicleDueKind(next.kind), w.when);
      caption = [
        next.vehicle.name,
        ?w.extra,
        if (summary.overdue > 1) l10n.vehiclesMoreOverdue(summary.overdue - 1),
      ].join(' · ');
    }

    void open(Widget sheet) =>
        showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

    return Scaffold(
      floatingActionButton: vehicles.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('log-fuel'),
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => open(const CostForm(kind: 'fuel')),
              icon: const Icon(Icons.local_gas_station_outlined),
              label: Text(l10n.vehicleLogFuel),
            ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: summary.overdue > 0 ? HomeColors.gumamela : HomeColors.dagat,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vehicles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l10n.vehiclesEmpty, textAlign: TextAlign.center),
                  ),
                if (summary.due.isNotEmpty) ...[
                  Text(l10n.vehiclesComingUp, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(children: [for (final d in summary.due) _DueTile(item: d)]),
                  ),
                  const SizedBox(height: 16),
                ],
                if (vehicles.isNotEmpty) ...[
                  Text(l10n.vehiclesOurs, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [for (final v in vehicles) _VehicleTile(vehicle: v, odometer: summary.odometers[v.id])],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.vehiclesSpentLine(spent), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                ],
                Align(
                  alignment: vehicles.isEmpty ? Alignment.center : Alignment.centerLeft,
                  child: (vehicles.isEmpty ? FilledButton.icon : OutlinedButton.icon)(
                    key: const Key('add-vehicle'),
                    onPressed: () => open(const VehicleForm()),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.vehicleAdd),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DueTile extends ConsumerWidget {
  const _DueTile({required this.item});

  final DueItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final w = dueWhen(l10n, locale, item, ref.read(vehiclesRepoProvider).today);
    final color = vehicleDueColor(item.status);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: item.status == VehicleDue.soon ? HomeColors.mangga : HomeColors.capiz,
        foregroundColor: item.status == VehicleDue.overdue ? HomeColors.gumamela : HomeColors.narra,
        child: Icon(dueIcon(item.kind)),
      ),
      title: Text(item.vehicle.name),
      subtitle: Text(
        [l10n.vehiclesNextFigure(l10n.vehicleDueKind(item.kind), w.when), ?w.extra].join(' · '),
        style: TextStyle(color: color, fontWeight: item.status == VehicleDue.overdue ? FontWeight.w600 : null),
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => VehicleSheet(vehicleId: item.vehicle.id),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle, required this.odometer});

  final Vehicle vehicle;
  final int? odometer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final v = vehicle;
    final details = [?v.plate, ?v.color, if (odometer != null) l10n.vehicleOdometer(km(locale, odometer!))].join(' · ');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: HomeColors.dagat,
        foregroundColor: Colors.white,
        child: Icon(vehicleIcon(v.kind)),
      ),
      title: Text(v.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(details.isEmpty ? l10n.vehicleKind(v.kind) : details),
      trailing: SyncMarker(entity: 'vehicles', id: v.id),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => VehicleSheet(vehicleId: v.id),
      ),
    );
  }
}

/// One vehicle, kept live: odometer, what is due, log fuel or another cost,
/// update the odometer, edit, remove, and its history.
class VehicleSheet extends ConsumerWidget {
  const VehicleSheet({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(vehiclesRepoProvider);
    final v = ref.watch(vehicleProvider(vehicleId)).value;
    if (v == null) return const SizedBox(height: 120);
    final history = ref.watch(vehicleHistoryProvider(vehicleId)).value ?? const <VehicleLog>[];
    final odometer = odometerOf(v.id, history);
    final due = dueItemsOf(v, odometer, repo.today);
    final details = [l10n.vehicleKind(v.kind), ?v.plate, ?v.color].join(' · ');
    final text = Theme.of(context).textTheme;

    void open(Widget sheet) =>
        showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

    return SheetBody(
      title: v.name,
      children: [
        Text(details, style: text.bodyMedium),
        const SizedBox(height: 8),
        Text(
          odometer == null ? l10n.vehicleNoOdometer : l10n.vehicleOdometer(km(locale, odometer)),
          key: const Key('vehicle-odometer'),
          style: text.titleLarge,
        ),
        for (final d in due)
          Builder(
            builder: (context) {
              final w = dueWhen(l10n, locale, d, repo.today);
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(dueIcon(d.kind), size: 18, color: vehicleDueColor(d.status)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        [l10n.vehiclesNextFigure(l10n.vehicleDueKind(d.kind), w.when), ?w.extra].join(' · '),
                        style: TextStyle(color: vehicleDueColor(d.status)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        if (v.note != null) ...[const SizedBox(height: 4), Text(v.note!, style: text.bodySmall)],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => open(CostForm(vehicle: v, kind: 'fuel')),
          icon: const Icon(Icons.local_gas_station_outlined),
          label: Text(l10n.vehicleLogFuel),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => open(CostForm(vehicle: v, kind: 'pms')),
          child: Text(l10n.vehicleAddCost),
        ),
        TextButton(
          onPressed: () => open(OdometerForm(vehicle: v)),
          child: Text(l10n.vehicleUpdateOdometer),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            open(VehicleForm(vehicle: v));
          },
          child: Text(l10n.vehicleEdit),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await repo.removeVehicle(v.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.vehicleRemove),
        ),
        const SizedBox(height: 8),
        Text(l10n.vehicleHistory, style: text.titleMedium),
        if (history.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.vehicleHistoryEmpty))
        else
          for (final l in history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(logIcon(l.kind)),
              title: Text(l10n.vehicleLogKind(l.kind)),
              subtitle: Text(
                [
                  DateFormat.yMMMd(locale).format(parseIsoDate(l.loggedOn)!),
                  if (l.odometerKm != null) l10n.vehicleOdometer(km(locale, l.odometerKm!)),
                  if (l.litres != null) l10n.vehicleLitresLine(NumberFormat.decimalPattern(locale).format(l.litres)),
                  ?l.note,
                ].join(' · '),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (l.amountMinor != null)
                    Text(
                      formatPeso(l.amountMinor!, locale: locale, whole: true),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  if (repo.canRemove(l))
                    IconButton(
                      tooltip: l10n.vehicleRemoveEntry,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => repo.removeLog(l),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

int? _intOrNull(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim().replaceAll(',', ''));
bool _badInt(String s) => s.trim().isNotEmpty && ((_intOrNull(s) ?? -1) <= 0);

/// Log a cost: fuel (with optional litres), PMS, repair, registration or
/// insurance, with an optional odometer reading. Without a [vehicle] (the
/// screen's Log fuel button) it asks which one when there are several.
class CostForm extends ConsumerStatefulWidget {
  const CostForm({super.key, this.vehicle, required this.kind});

  final Vehicle? vehicle;
  final String kind;

  @override
  ConsumerState<CostForm> createState() => _CostFormState();
}

class _CostFormState extends ConsumerState<CostForm> {
  late String _kind = widget.kind;
  String? _vehicleId;
  final _amount = TextEditingController();
  final _odometer = TextEditingController();
  final _litres = TextEditingController();
  final _note = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_amount, _odometer, _litres, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  double? get _litresValue => _litres.text.trim().isEmpty ? null : double.tryParse(_litres.text.trim());
  bool get _litresBad => _litres.text.trim().isNotEmpty && (_litresValue == null || _litresValue! <= 0);

  Vehicle? _vehicle(List<Vehicle> all) {
    if (widget.vehicle != null) return widget.vehicle;
    if (all.length == 1) return all.single;
    for (final v in all) {
      if (v.id == _vehicleId) return v;
    }
    return null;
  }

  Future<void> _save(Vehicle? v) async {
    final amount = parsePeso(_amount.text);
    if (v == null || amount == null || amount <= 0 || _badInt(_odometer.text) || _litresBad) {
      setState(() => _tried = true);
      return;
    }
    await ref
        .read(vehiclesRepoProvider)
        .logCost(
          v,
          _kind,
          amount,
          odometerKm: _intOrNull(_odometer.text),
          litres: _kind == 'fuel' ? _litresValue : null,
          note: _note.text,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final all = ref.watch(vehiclesProvider).value ?? const <Vehicle>[];
    final v = _vehicle(all);
    final amount = parsePeso(_amount.text);
    final odo = v == null ? null : ref.watch(vehiclesSummaryProvider).odometers[v.id];
    return SheetBody(
      title: _kind == 'fuel' ? l10n.vehicleLogFuel : l10n.vehicleAddCost,
      children: [
        if (widget.vehicle == null && all.length > 1) ...[
          Text(l10n.vehicleWhich, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final x in all)
                ChoiceChip(
                  avatar: Icon(vehicleIcon(x.kind), size: 18),
                  label: Text(x.name),
                  selected: v?.id == x.id,
                  onSelected: (_) => setState(() => _vehicleId = x.id),
                ),
            ],
          ),
          if (_tried && v == null) Text(l10n.vehicleWhich, style: const TextStyle(color: HomeColors.gumamela)),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in costKinds)
              ChoiceChip(
                key: Key('cost-$k'),
                avatar: Icon(logIcon(k), size: 18),
                label: Text(l10n.vehicleLogKind(k)),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('cost-amount'),
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _tried ? setState(() {}) : null,
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.vehicleAmount,
            errorText: _tried && (amount == null || amount <= 0) ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('cost-odometer'),
          controller: _odometer,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.vehicleOdometerOptional,
            helperText: odo == null ? null : l10n.vehicleLastReading(km(locale, odo)),
            suffixText: 'km',
            errorText: _tried && _badInt(_odometer.text) ? l10n.vehicleOdometerInvalid : null,
          ),
        ),
        if (_kind == 'fuel') ...[
          const SizedBox(height: 12),
          TextField(
            key: const Key('cost-litres'),
            controller: _litres,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.vehicleLitres,
              suffixText: 'L',
              errorText: _tried && _litresBad ? l10n.amountInvalid : null,
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.vehicleNote),
        ),
        const SizedBox(height: 8),
        Text(
          [
            l10n.billPayHint(categoryLabel(l10n, vehicleCategory)),
            if (dueKinds.contains(_kind)) l10n.vehicleRenewHint(_kind),
          ].join(' '),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton(key: const Key('cost-save'), onPressed: () => _save(v), child: Text(l10n.save)),
      ],
    );
  }
}

/// A new odometer reading with no cost.
class OdometerForm extends ConsumerStatefulWidget {
  const OdometerForm({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  ConsumerState<OdometerForm> createState() => _OdometerFormState();
}

class _OdometerFormState extends ConsumerState<OdometerForm> {
  final _km = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    _km.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = _intOrNull(_km.text);
    if (v == null || v <= 0) {
      setState(() => _tried = true);
      return;
    }
    await ref.read(vehiclesRepoProvider).logOdometer(widget.vehicle, v);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = _intOrNull(_km.text);
    return SheetBody(
      title: l10n.vehicleUpdateOdometer,
      children: [
        TextField(
          key: const Key('odometer-km'),
          controller: _km,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.vehicleOdometerLabel,
            suffixText: 'km',
            errorText: _tried && (v == null || v <= 0) ? l10n.vehicleOdometerInvalid : null,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// Add or edit a vehicle and its due dates. The kind is chosen when adding.
class VehicleForm extends ConsumerStatefulWidget {
  const VehicleForm({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  ConsumerState<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<VehicleForm> {
  late String _kind = widget.vehicle?.kind ?? 'car';
  late final _name = TextEditingController(text: widget.vehicle?.name ?? '');
  late final _plate = TextEditingController(text: widget.vehicle?.plate ?? '');
  late final _color = TextEditingController(text: widget.vehicle?.color ?? '');
  final _odometer = TextEditingController();
  late final _pmsKm = TextEditingController(text: widget.vehicle?.pmsDueKm?.toString() ?? '');
  late final _everyMonths = TextEditingController(text: widget.vehicle?.pmsEveryMonths?.toString() ?? '');
  late final _everyKm = TextEditingController(text: widget.vehicle?.pmsEveryKm?.toString() ?? '');
  late final _note = TextEditingController(text: widget.vehicle?.note ?? '');
  late final _dates = <String, DateTime?>{
    'registration': parseIsoDate(widget.vehicle?.registrationDueOn),
    'insurance': parseIsoDate(widget.vehicle?.insuranceDueOn),
    'pms': parseIsoDate(widget.vehicle?.pmsDueOn),
  };
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_name, _plate, _color, _odometer, _pmsKm, _everyMonths, _everyKm, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _numbers => [_odometer, _pmsKm, _everyMonths, _everyKm];

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _numbers.any((c) => _badInt(c.text))) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(vehiclesRepoProvider);
    final v = widget.vehicle;
    if (v == null) {
      await repo.addVehicle(
        kind: _kind,
        name: _name.text,
        plate: _plate.text,
        color: _color.text,
        registrationDueOn: _dates['registration'],
        insuranceDueOn: _dates['insurance'],
        pmsDueOn: _dates['pms'],
        pmsDueKm: _intOrNull(_pmsKm.text),
        pmsEveryMonths: _intOrNull(_everyMonths.text),
        pmsEveryKm: _intOrNull(_everyKm.text),
        odometerKm: _intOrNull(_odometer.text),
        note: _note.text,
      );
    } else {
      await repo.editVehicle(
        v,
        name: _name.text,
        plate: _plate.text,
        color: _color.text,
        registrationDueOn: _dates['registration'],
        insuranceDueOn: _dates['insurance'],
        pmsDueOn: _dates['pms'],
        pmsDueKm: _intOrNull(_pmsKm.text),
        pmsEveryMonths: _intOrNull(_everyMonths.text),
        pmsEveryKm: _intOrNull(_everyKm.text),
        note: _note.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _number(Key key, TextEditingController c, String label, {String? suffix}) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextField(
      key: key,
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        errorText: _tried && _badInt(c.text) ? AppLocalizations.of(context).vehicleOdometerInvalid : null,
      ),
    ),
  );

  Widget _date(String kind) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(vehiclesRepoProvider).today;
    final on = _dates[kind];
    return ListTile(
      key: Key('due-$kind'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(dueIcon(kind)),
      title: Text(l10n.vehicleDueDateLabel(kind)),
      subtitle: Text(on == null ? l10n.vehicleNotSet : DateFormat.yMMMEd(locale).format(on)),
      trailing: on == null
          ? null
          : IconButton(
              tooltip: l10n.vehicleClearDate,
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _dates[kind] = null),
            ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: on ?? today,
          firstDate: DateTime(today.year - 3),
          lastDate: DateTime(today.year + 5),
        );
        if (picked != null) setState(() => _dates[kind] = picked);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final adding = widget.vehicle == null;
    return SheetBody(
      title: adding ? l10n.vehicleAdd : l10n.vehicleEdit,
      children: [
        if (adding) ...[
          Wrap(
            spacing: 8,
            children: [
              for (final k in vehicleKinds)
                ChoiceChip(
                  avatar: Icon(vehicleIcon(k), size: 18),
                  label: Text(l10n.vehicleKind(k)),
                  selected: _kind == k,
                  onSelected: (_) => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          key: const Key('vehicle-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.vehicleNameHint(_kind),
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('vehicle-plate'),
          controller: _plate,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: l10n.vehiclePlate),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _color,
          decoration: InputDecoration(labelText: l10n.vehicleColor),
        ),
        if (adding) _number(const Key('vehicle-odometer-field'), _odometer, l10n.vehicleOdometerOptional, suffix: 'km'),
        const SizedBox(height: 8),
        _date('registration'),
        _date('insurance'),
        _date('pms'),
        _number(const Key('vehicle-pms-km'), _pmsKm, l10n.vehiclePmsKm, suffix: 'km'),
        _number(const Key('vehicle-every-months'), _everyMonths, l10n.vehiclePmsEveryMonths),
        _number(const Key('vehicle-every-km'), _everyKm, l10n.vehiclePmsEveryKm, suffix: 'km'),
        const SizedBox(height: 4),
        Text(l10n.vehiclePmsHelp, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.vehicleNote),
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('vehicle-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
