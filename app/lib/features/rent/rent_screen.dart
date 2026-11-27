import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../sync/sync_widgets.dart';
import 'rent_providers.dart';
import 'rent_repository.dart';

const _manggaText = Color(0xFF8A5A00); // Mangga, darkened for text

/// "5 days late" / "due Dec 10" for a lease that owes something.
String rentWhen(AppLocalizations l10n, String locale, LeaseStatus s) {
  if (s.daysLate > 0) return l10n.rentDaysLate(s.daysLate);
  return l10n.rentDueOn(DateFormat.MMMd(locale).format(s.oldestDue!));
}

/// "Room 2 · Jun".
String leaseTitle(RentalUnit unit, Lease lease) => '${unit.name} · ${lease.tenantName}';

/// Rent the household collects: who still owes first (owner picked layout A),
/// then who has paid this month, then vacant units.
class RentScreen extends ConsumerWidget {
  const RentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(rentRepoProvider);
    final s = ref.watch(rentSummaryProvider);
    String peso(int v) => formatPeso(v, locale: locale, whole: true);

    final String figure;
    final String caption;
    if (s.isEmpty) {
      figure = l10n.rentNoneFigure;
      caption = l10n.rentEmptyCaption;
    } else {
      figure = s.totalOwed > 0 ? l10n.rentToCollectFigure(peso(s.totalOwed)) : l10n.rentAllPaidFigure;
      caption = [
        DateFormat.MMMM(locale).format(repo.today),
        if (s.activeCount > 0) l10n.rentPaidCount(s.paid.length, s.activeCount),
        if (s.overdueCount > 0) l10n.rentOverdueCount(s.overdueCount),
        if (s.activeCount == 0) l10n.rentVacantCount(s.vacant.length),
      ].join(' · ');
    }

    void open(Widget sheet) =>
        showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);
    final title = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      floatingActionButton: s.current.isEmpty && s.toCollect.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('record-payment'),
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => open(const PaymentForm()),
              icon: const Icon(Icons.add),
              label: Text(l10n.rentRecordPayment),
            ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: HomeColors.dahon,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (s.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l10n.rentEmpty, textAlign: TextAlign.center),
                  ),
                if (s.toCollect.isNotEmpty) ...[
                  Text(l10n.rentToCollect, style: title),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(children: [for (final r in s.toCollect) _OwingTile(row: r)]),
                  ),
                  const SizedBox(height: 16),
                ],
                if (s.paid.isNotEmpty) ...[
                  Text(l10n.rentPaidThisMonth, style: title),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(children: [for (final r in s.paid) _PaidTile(row: r)]),
                  ),
                  const SizedBox(height: 16),
                ],
                if (s.vacant.isNotEmpty) ...[
                  Text(l10n.rentVacant, style: title),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (final u in s.vacant)
                          ListTile(
                            key: Key('vacant-${u.name}'),
                            leading: const CircleAvatar(
                              backgroundColor: HomeColors.capiz,
                              foregroundColor: HomeColors.narra,
                              child: Icon(Icons.meeting_room_outlined),
                            ),
                            title: Text(u.name),
                            subtitle: Text(l10n.rentVacantLine),
                            trailing: SyncMarker(entity: 'rental_units', id: u.id),
                            onTap: () => open(UnitSheet(unit: u)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Align(
                  alignment: s.isEmpty ? Alignment.center : Alignment.centerLeft,
                  child: (s.isEmpty ? FilledButton.icon : OutlinedButton.icon)(
                    key: const Key('add-unit'),
                    onPressed: () => open(const UnitForm()),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.rentAddUnit),
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

class _OwingTile extends StatelessWidget {
  const _OwingTile({required this.row});

  final UnitRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final s = row.status!;
    String peso(int v) => formatPeso(v, locale: locale, whole: true);
    final ended = s.lease.endsOn != null;
    final late = s.due == RentDue.overdue;
    final soon = s.due == RentDue.soon;
    final amount = s.owed > s.oldestLeft!
        ? l10n.rentOwesLine(peso(s.owed))
        : s.partlyPaid
        ? l10n.rentLeftOf(peso(s.oldestLeft!), peso(rentFor(s.lease, monthOf(s.oldestDue!))))
        : peso(s.owed);
    final details = [
      amount,
      if (ended) l10n.rentMovedOut(DateFormat.MMMd(locale).format(parseIsoDate(s.lease.endsOn)!)),
    ].join(' · ');
    return ListTile(
      key: Key('owing-${s.lease.tenantName}'),
      leading: CircleAvatar(
        backgroundColor: late ? HomeColors.gumamela : HomeColors.dagat,
        foregroundColor: Colors.white,
        child: Text(_initial(row.unit.name)),
      ),
      title: Text(leaseTitle(row.unit, s.lease), overflow: TextOverflow.ellipsis),
      subtitle: Text(details),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SyncMarker(entity: 'leases', id: s.lease.id),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: late
                  ? HomeColors.gumamela
                  : soon
                  ? HomeColors.mangga
                  : HomeColors.capiz,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              rentWhen(l10n, locale, s),
              style: TextStyle(color: late ? Colors.white : HomeColors.narra, fontSize: 12),
            ),
          ),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => LeaseSheet(leaseId: s.lease.id),
      ),
    );
  }
}

class _PaidTile extends StatelessWidget {
  const _PaidTile({required this.row});

  final UnitRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final s = row.status!;
    final last = s.lastPayment;
    final details = [
      formatPeso(s.lease.rentMinor, locale: locale, whole: true),
      if (last != null) l10n.rentPaidOn(DateFormat.MMMd(locale).format(parseIsoDate(last.paidOn)!)),
      if (last?.method != null) l10n.rentMethod(last!.method!),
      if (s.credit > 0) l10n.rentAhead(formatPeso(s.credit, locale: locale, whole: true)),
    ].join(' · ');
    return ListTile(
      key: Key('paid-${s.lease.tenantName}'),
      leading: const CircleAvatar(
        backgroundColor: HomeColors.dahon,
        foregroundColor: Colors.white,
        child: Icon(Icons.check),
      ),
      title: Text(leaseTitle(row.unit, s.lease), overflow: TextOverflow.ellipsis),
      subtitle: Text(details),
      trailing: SyncMarker(entity: 'leases', id: s.lease.id),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => LeaseSheet(leaseId: s.lease.id),
      ),
    );
  }
}

String _initial(String name) {
  final digits = RegExp(r'\d+').firstMatch(name)?.group(0);
  if (digits != null && digits.length <= 2) return digits;
  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

/// A vacant unit: add a tenant, rename, remove.
class UnitSheet extends ConsumerWidget {
  const UnitSheet({super.key, required this.unit});

  final RentalUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    void replace(Widget sheet) {
      Navigator.pop(context);
      showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);
    }

    return SheetBody(
      title: unit.name,
      children: [
        Text(l10n.rentVacantLine),
        if (unit.note != null) ...[const SizedBox(height: 4), Text(unit.note!)],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('add-tenant'),
          onPressed: () => replace(LeaseForm(unitId: unit.id)),
          icon: const Icon(Icons.person_add_alt),
          label: Text(l10n.rentAddTenant),
        ),
        TextButton(
          onPressed: () => replace(UnitForm(unit: unit)),
          child: Text(l10n.rentEditUnit),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await ref.read(rentRepoProvider).removeUnit(unit.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.rentRemoveUnit),
        ),
      ],
    );
  }
}

/// One tenant, kept live: what they owe, call or text, record a payment,
/// waive, edit, move out, and their payments.
class LeaseSheet extends ConsumerWidget {
  const LeaseSheet({super.key, required this.leaseId});

  final String leaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(rentRepoProvider);
    final leases = ref.watch(leasesProvider).value ?? const <Lease>[];
    final units = ref.watch(rentalUnitsProvider).value ?? const <RentalUnit>[];
    final lease = leases.where((l) => l.id == leaseId).firstOrNull;
    final unit = lease == null ? null : units.where((u) => u.id == lease.unitId).firstOrNull;
    if (lease == null || unit == null) return const SizedBox(height: 120);
    final history = ref.watch(rentHistoryProvider(leaseId)).value ?? const <RentPayment>[];
    final s = LeaseStatus.of(lease, history, repo.today);
    final text = Theme.of(context).textTheme;
    String peso(int v) => formatPeso(v, locale: locale, whole: true);
    String date(String iso) => DateFormat.yMMMd(locale).format(parseIsoDate(iso)!);
    final active = leaseActive(lease, repo.today);
    final vacantHere = !(ref.watch(rentSummaryProvider).current.containsKey(unit.id));

    void replace(Widget sheet) {
      Navigator.pop(context);
      showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);
    }

    void open(Widget sheet) =>
        showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

    final statusColor = switch (s.due) {
      RentDue.overdue => HomeColors.gumamela,
      RentDue.soon => _manggaText,
      RentDue.paid => HomeColors.dahon,
      RentDue.later => HomeColors.narra,
    };

    return SheetBody(
      title: leaseTitle(unit, lease),
      children: [
        Text(
          s.owed == 0
              ? (s.credit > 0 ? l10n.rentAhead(peso(s.credit)) : l10n.rentAllPaidFigure)
              : '${l10n.rentOwesLine(peso(s.owed))} · ${rentWhen(l10n, locale, s)}',
          key: const Key('lease-status'),
          style: text.titleLarge?.copyWith(color: statusColor),
        ),
        const SizedBox(height: 8),
        Text(l10n.rentEveryLine(peso(lease.rentMinor), lease.dueDay), style: text.bodyMedium),
        Text(
          [
            l10n.rentSince(date(lease.startsOn)),
            if (lease.endsOn != null) l10n.rentMovedOut(date(lease.endsOn!)),
          ].join(' · '),
          style: text.bodyMedium,
        ),
        if (lease.depositMinor != null)
          Text(
            lease.depositReturnedOn != null
                ? l10n.rentDepositReturned(peso(lease.depositReturnedMinor ?? 0), peso(lease.depositMinor!))
                : l10n.rentDepositLine(peso(lease.depositMinor!)),
            style: text.bodyMedium,
          ),
        if (lease.note != null) Text(lease.note!, style: text.bodySmall),
        if (lease.phone != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(lease.phone!, style: text.bodyLarge),
              ActionChip(
                avatar: const Icon(Icons.call_outlined, size: 18),
                label: Text(l10n.rentCall),
                onPressed: () => launchUrl(Uri(scheme: 'tel', path: _dialable(lease.phone!))),
              ),
              ActionChip(
                avatar: const Icon(Icons.sms_outlined, size: 18),
                label: Text(l10n.rentText),
                onPressed: () => launchUrl(Uri(scheme: 'sms', path: _dialable(lease.phone!))),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('lease-pay'),
          onPressed: () => open(PaymentForm(lease: lease)),
          icon: const Icon(Icons.payments_outlined),
          label: Text(l10n.rentRecordPayment),
        ),
        if (s.owed > 0)
          TextButton(
            key: const Key('lease-waive'),
            onPressed: () => open(WaiveForm(lease: lease, owed: s.owed)),
            child: Text(l10n.rentWaive),
          ),
        TextButton(
          onPressed: () => replace(LeaseForm(unitId: unit.id, lease: lease)),
          child: Text(l10n.rentEditTenant),
        ),
        if (active)
          TextButton(
            key: const Key('lease-move-out'),
            onPressed: () => open(MoveOutForm(lease: lease)),
            child: Text(l10n.rentMoveOut),
          )
        else if (vacantHere)
          TextButton(onPressed: () => repo.undoMoveOut(lease), child: Text(l10n.rentUndoMoveOut)),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await repo.removeLease(lease.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.rentRemoveTenant),
        ),
        const SizedBox(height: 8),
        Text(l10n.rentHistory, style: text.titleMedium),
        if (history.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.rentHistoryEmpty))
        else
          for (final p in history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(p.kind == rentWaivedKind ? Icons.volunteer_activism_outlined : Icons.payments_outlined),
              title: Text(l10n.rentKind(p.kind)),
              subtitle: Text([date(p.paidOn), if (p.method != null) l10n.rentMethod(p.method!), ?p.note].join(' · ')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(peso(p.amountMinor), style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (repo.canRemove(p))
                    IconButton(
                      tooltip: l10n.rentRemoveEntry,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => repo.removePayment(p),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

String _dialable(String phone) => phone.replaceAll(RegExp(r'[^\d+]'), '');

/// Add or rename a unit.
class UnitForm extends ConsumerStatefulWidget {
  const UnitForm({super.key, this.unit});

  final RentalUnit? unit;

  @override
  ConsumerState<UnitForm> createState() => _UnitFormState();
}

class _UnitFormState extends ConsumerState<UnitForm> {
  late final _name = TextEditingController(text: widget.unit?.name ?? '');
  late final _note = TextEditingController(text: widget.unit?.note ?? '');
  bool _tried = false;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(rentRepoProvider);
    final u = widget.unit;
    if (u == null) {
      final id = await repo.addUnit(_name.text, note: _note.text);
      if (!mounted) return;
      // Straight on to its tenant; closing that leaves the unit vacant.
      Navigator.pop(context);
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => LeaseForm(unitId: id),
      );
      return;
    }
    await repo.editUnit(u, name: _name.text, note: _note.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: widget.unit == null ? l10n.rentAddUnit : l10n.rentEditUnit,
      children: [
        TextField(
          key: const Key('unit-name'),
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.rentUnitName,
            hintText: l10n.rentUnitNameHint,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.rentNote),
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('unit-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

int? _intOrNull(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());

/// Add a tenant to a unit, or edit one.
class LeaseForm extends ConsumerStatefulWidget {
  const LeaseForm({super.key, required this.unitId, this.lease});

  final String unitId;
  final Lease? lease;

  @override
  ConsumerState<LeaseForm> createState() => _LeaseFormState();
}

class _LeaseFormState extends ConsumerState<LeaseForm> {
  late final _name = TextEditingController(text: widget.lease?.tenantName ?? '');
  late final _phone = TextEditingController(text: widget.lease?.phone ?? '');
  late final _rent = TextEditingController(text: _pesoText(widget.lease?.rentMinor));
  late final _dueDay = TextEditingController(text: widget.lease?.dueDay.toString() ?? '');
  late final _deposit = TextEditingController(text: _pesoText(widget.lease?.depositMinor));
  late final _note = TextEditingController(text: widget.lease?.note ?? '');
  late DateTime _starts = parseIsoDate(widget.lease?.startsOn) ?? ref.read(rentRepoProvider).today;
  bool _tried = false;

  static String _pesoText(int? minor) =>
      minor == null ? '' : (minor % 100 == 0 ? '${minor ~/ 100}' : (minor / 100).toStringAsFixed(2));

  @override
  void dispose() {
    for (final c in [_name, _phone, _rent, _dueDay, _deposit, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _rentBad => (parsePeso(_rent.text) ?? 0) <= 0;
  bool get _dueBad {
    final d = _intOrNull(_dueDay.text);
    return d == null || d < 1 || d > 31;
  }

  bool get _depositBad => _deposit.text.trim().isNotEmpty && (parsePeso(_deposit.text) ?? -1) < 0;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _rentBad || _dueBad || _depositBad) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(rentRepoProvider);
    final deposit = _deposit.text.trim().isEmpty ? null : parsePeso(_deposit.text);
    final l = widget.lease;
    if (l == null) {
      await repo.addLease(
        unitId: widget.unitId,
        tenantName: _name.text,
        phone: _phone.text,
        rentMinor: parsePeso(_rent.text)!,
        dueDay: _intOrNull(_dueDay.text)!,
        startsOn: _starts,
        depositMinor: deposit,
        note: _note.text,
      );
    } else {
      await repo.editLease(
        l,
        tenantName: _name.text,
        phone: _phone.text,
        rentMinor: parsePeso(_rent.text)!,
        dueDay: _intOrNull(_dueDay.text)!,
        startsOn: _starts,
        depositMinor: deposit,
        note: _note.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(rentRepoProvider).today;
    final editing = widget.lease != null;
    return SheetBody(
      title: editing ? l10n.rentEditTenant : l10n.rentAddTenant,
      children: [
        TextField(
          key: const Key('tenant-name'),
          controller: _name,
          autofocus: !editing,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.rentTenantName,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('tenant-phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: l10n.rentPhone),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('tenant-rent'),
          controller: _rent,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.rentMonthly,
            helperText: editing ? l10n.rentChangeHint : null,
            errorText: _tried && _rentBad ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('tenant-due-day'),
          controller: _dueDay,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.rentDueDay,
            helperText: l10n.rentDueDayHelp,
            errorText: _tried && _dueBad ? l10n.rentDueDayInvalid : null,
          ),
        ),
        ListTile(
          key: const Key('tenant-starts'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.rentStartsOn),
          subtitle: Text(DateFormat.yMMMEd(locale).format(_starts)),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _starts,
              firstDate: DateTime(today.year - 10),
              lastDate: DateTime(today.year + 1, 12, 31),
            );
            if (picked != null) setState(() => _starts = picked);
          },
        ),
        TextField(
          key: const Key('tenant-deposit'),
          controller: _deposit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.rentDeposit,
            errorText: _tried && _depositBad ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.rentNote),
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('tenant-save'), onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// Record money received. Without a [lease] (the screen's button) it asks
/// which tenant when there are several.
class PaymentForm extends ConsumerStatefulWidget {
  const PaymentForm({super.key, this.lease});

  final Lease? lease;

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  String? _leaseId;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _method;
  late DateTime _paidOn = ref.read(rentRepoProvider).today;
  bool _tried = false;
  String? _prefilledFor;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Tenants to pick from: who owes first, then current tenants.
  List<UnitRow> _choices(RentSummary s) {
    final seen = <String>{};
    return [
      for (final r in [...s.toCollect, ...s.paid])
        if (seen.add(r.status!.lease.id)) r,
    ];
  }

  UnitRow? _picked(List<UnitRow> rows) {
    final id = widget.lease?.id ?? _leaseId ?? (rows.length == 1 ? rows.single.status!.lease.id : null);
    return rows.where((r) => r.status!.lease.id == id).firstOrNull;
  }

  Future<void> _save(UnitRow? row, Lease? lease, String unitName) async {
    final amount = parsePeso(_amount.text);
    if (lease == null || amount == null || amount <= 0) {
      setState(() => _tried = true);
      return;
    }
    await ref
        .read(rentRepoProvider)
        .recordPayment(lease, unitName, amount, paidOn: _paidOn, method: _method, note: _note.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(rentRepoProvider).today;
    final summary = ref.watch(rentSummaryProvider);
    final rows = _choices(summary);
    final row = _picked(rows);
    Lease? lease = row?.status!.lease ?? widget.lease;
    var unitName = row?.unit.name;
    if (widget.lease != null && unitName == null) {
      final units = ref.watch(rentalUnitsProvider).value ?? const <RentalUnit>[];
      unitName = units.where((u) => u.id == widget.lease!.unitId).firstOrNull?.name;
    }
    // Suggest what is owed (or a month's rent) once per tenant picked.
    if (lease != null && _prefilledFor != lease.id) {
      _prefilledFor = lease.id;
      final owed = row?.status!.owed ?? 0;
      final suggest = owed > 0 ? owed : lease.rentMinor;
      _amount.text = suggest % 100 == 0 ? '${suggest ~/ 100}' : (suggest / 100).toStringAsFixed(2);
    }
    final amount = parsePeso(_amount.text);
    return SheetBody(
      title: l10n.rentRecordPayment,
      children: [
        if (widget.lease == null && rows.length > 1) ...[
          Text(l10n.rentWhich, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in rows)
                ChoiceChip(
                  label: Text(leaseTitle(r.unit, r.status!.lease)),
                  selected: row?.status!.lease.id == r.status!.lease.id,
                  onSelected: (_) => setState(() => _leaseId = r.status!.lease.id),
                ),
            ],
          ),
          if (_tried && lease == null) Text(l10n.rentWhich, style: const TextStyle(color: HomeColors.gumamela)),
          const SizedBox(height: 12),
        ] else if (lease != null && unitName != null) ...[
          Text('$unitName · ${lease.tenantName}'),
          const SizedBox(height: 8),
        ],
        TextField(
          key: const Key('payment-amount'),
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _tried ? setState(() {}) : null,
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.rentAmount,
            helperText: row != null && row.status!.owed > 0
                ? l10n.rentOwesLine(formatPeso(row.status!.owed, locale: locale, whole: true))
                : null,
            errorText: _tried && (amount == null || amount <= 0) ? l10n.amountInvalid : null,
          ),
        ),
        ListTile(
          key: const Key('payment-date'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.rentPaidOnLabel),
          subtitle: Text(DateFormat.yMMMEd(locale).format(_paidOn)),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _paidOn,
              firstDate: DateTime(today.year - 2),
              lastDate: today,
            );
            if (picked != null) setState(() => _paidOn = picked);
          },
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final m in rentMethods)
              ChoiceChip(
                key: Key('method-$m'),
                label: Text(l10n.rentMethod(m)),
                selected: _method == m,
                onSelected: (on) => setState(() => _method = on ? m : null),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.rentNote),
        ),
        const SizedBox(height: 8),
        Text(l10n.rentPayHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('payment-save'),
          onPressed: () => _save(row, lease, unitName ?? ''),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Forgive part or all of what a tenant owes.
class WaiveForm extends ConsumerStatefulWidget {
  const WaiveForm({super.key, required this.lease, required this.owed});

  final Lease lease;
  final int owed;

  @override
  ConsumerState<WaiveForm> createState() => _WaiveFormState();
}

class _WaiveFormState extends ConsumerState<WaiveForm> {
  late final _amount = TextEditingController(
    text: widget.owed % 100 == 0 ? '${widget.owed ~/ 100}' : (widget.owed / 100).toStringAsFixed(2),
  );
  final _note = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _bad {
    final a = parsePeso(_amount.text);
    return a == null || a <= 0 || a > widget.owed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: l10n.rentWaive,
      children: [
        TextField(
          key: const Key('waive-amount'),
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.rentAmount,
            errorText: _tried && _bad ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.rentNote),
        ),
        const SizedBox(height: 8),
        Text(l10n.rentWaiveHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('waive-save'),
          onPressed: () async {
            if (_bad) {
              setState(() => _tried = true);
              return;
            }
            await ref.read(rentRepoProvider).waive(widget.lease, parsePeso(_amount.text)!, note: _note.text);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// The tenant leaves: the date, and how much of the deposit went back.
class MoveOutForm extends ConsumerStatefulWidget {
  const MoveOutForm({super.key, required this.lease});

  final Lease lease;

  @override
  ConsumerState<MoveOutForm> createState() => _MoveOutFormState();
}

class _MoveOutFormState extends ConsumerState<MoveOutForm> {
  late DateTime _on = ref.read(rentRepoProvider).today;
  late final _returned = TextEditingController(
    text: widget.lease.depositMinor == null
        ? ''
        : (widget.lease.depositMinor! % 100 == 0
              ? '${widget.lease.depositMinor! ~/ 100}'
              : (widget.lease.depositMinor! / 100).toStringAsFixed(2)),
  );
  bool _tried = false;

  @override
  void dispose() {
    _returned.dispose();
    super.dispose();
  }

  bool get _bad => _returned.text.trim().isNotEmpty && (parsePeso(_returned.text) ?? -1) < 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(rentRepoProvider).today;
    return SheetBody(
      title: l10n.rentMoveOut,
      children: [
        ListTile(
          key: const Key('move-out-date'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.rentMoveOutDate),
          subtitle: Text(DateFormat.yMMMEd(locale).format(_on)),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _on,
              firstDate: parseIsoDate(widget.lease.startsOn) ?? DateTime(today.year - 10),
              lastDate: DateTime(today.year + 1, 12, 31),
            );
            if (picked != null) setState(() => _on = picked);
          },
        ),
        if (widget.lease.depositMinor != null)
          TextField(
            key: const Key('move-out-deposit'),
            controller: _returned,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₱ ',
              labelText: l10n.rentDepositBack,
              errorText: _tried && _bad ? l10n.amountInvalid : null,
            ),
          ),
        const SizedBox(height: 8),
        Text(l10n.rentMoveOutHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('move-out-save'),
          onPressed: () async {
            if (_bad) {
              setState(() => _tried = true);
              return;
            }
            final returned = widget.lease.depositMinor == null
                ? null
                : (_returned.text.trim().isEmpty ? 0 : parsePeso(_returned.text));
            await ref.read(rentRepoProvider).moveOut(widget.lease, _on, depositReturnedMinor: returned);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
