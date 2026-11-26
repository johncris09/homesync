import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../bills/bills_repository.dart' show DueStatus, dueStatus;
import '../bills/bills_screen.dart' show dueColor, dueText;
import '../sync/sync_widgets.dart';
import 'debts_providers.dart';
import 'debts_repository.dart';

IconData debtIcon(String kind) => switch (kind) {
  'loan' => Icons.account_balance_outlined,
  'card' => Icons.credit_card,
  'pawn' => Icons.diamond_outlined,
  _ => Icons.handshake_outlined,
};

String _plain(int minor) => minor % 100 == 0 ? '${minor ~/ 100}' : (minor / 100).toStringAsFixed(2);

/// Debts & Loans: what the household owes (loans, credit cards, pawn
/// tickets) and what is owed to it, with payments and their history.
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    String peso(int minor) => formatPeso(minor, locale: locale, whole: true);
    final summary = ref.watch(debtsSummaryProvider);
    final open = ref.watch(openDebtsProvider).value ?? const <Debt>[];
    final closed = ref.watch(closedDebtsProvider).value ?? const <Debt>[];
    final owe = open.where((d) => d.kind != lentKind).toList();
    final owedToUs = open.where((d) => d.kind == lentKind).toList();
    final next = summary.next;

    final figure = owe.isNotEmpty
        ? l10n.debtsOwed(peso(summary.owed))
        : owedToUs.isNotEmpty
        ? l10n.debtsOwedToUs(peso(summary.owedToUs))
        : l10n.debtsNone;
    final caption = summary.overdue > 0
        ? l10n.debtsOverdueCaption(summary.overdue)
        : next != null
        ? l10n.billsNextCaption(next.name, DateFormat.MMMd(locale).format(parseIsoDate(next.dueOn)!))
        : owe.isNotEmpty && owedToUs.isNotEmpty
        ? l10n.debtsOwedToUs(peso(summary.owedToUs))
        : l10n.debtsEmptyCaption;
    final color = summary.overdue > 0 ? HomeColors.gumamela : HomeColors.narra;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HomeColors.mangga,
        foregroundColor: HomeColors.narra,
        onPressed: () =>
            showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const DebtForm()),
        icon: const Icon(Icons.add),
        label: Text(l10n.debtAdd),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: color,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (open.isEmpty && closed.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l10n.debtsEmpty, textAlign: TextAlign.center),
                  ),
                if (owe.isNotEmpty) _Section(title: l10n.debtsYouOwe, debts: owe, balances: summary.balances),
                if (owedToUs.isNotEmpty)
                  _Section(title: l10n.debtsOwedToYou, debts: owedToUs, balances: summary.balances),
                if (closed.isNotEmpty) _Section(title: l10n.debtsPaidOff, debts: closed, balances: const {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.debts, required this.balances});

  final String title;
  final List<Debt> debts;
  final Map<String, int> balances;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [for (final d in debts) _DebtTile(debt: d, balance: balances[d.id])],
          ),
        ),
      ],
    ),
  );
}

class _DebtTile extends ConsumerWidget {
  const _DebtTile({required this.debt, required this.balance});

  final Debt debt;

  /// Null for closed debts.
  final int? balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(debtsRepoProvider).today;
    final d = debt;
    final status = d.isClosed ? DueStatus.none : dueStatus(d.nextDueOn, today);
    final when = d.isClosed
        ? l10n.debtClosedOn(d.kind, DateFormat.MMMd(locale).format((d.closedAt ?? today).toLocal()))
        : d.nextDueOn == null
        ? null
        : dueText(l10n, locale, d.nextDueOn, today);
    final subtitle = [?d.counterparty, ?when].join(' · ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: d.isClosed ? HomeColors.dahon : HomeColors.capiz,
        foregroundColor: d.isClosed ? Colors.white : HomeColors.narra,
        child: Icon(d.isClosed ? Icons.check : debtIcon(d.kind)),
      ),
      title: Text(d.name, overflow: TextOverflow.ellipsis),
      subtitle: subtitle.isEmpty
          ? Text(l10n.debtKind(d.kind))
          : Text(
              subtitle,
              style: TextStyle(
                color: dueColor(status),
                fontWeight: status == DueStatus.overdue ? FontWeight.w600 : null,
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (balance != null)
            Text(
              formatPeso(balance!, locale: locale),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const SizedBox(width: 6),
          SyncMarker(entity: 'debts', id: d.id),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => DebtSheet(debtId: d.id),
      ),
    );
  }
}

/// One debt, kept live: balance, pay, add to it, close or reopen, edit,
/// remove, and its history.
class DebtSheet extends ConsumerWidget {
  const DebtSheet({super.key, required this.debtId});

  final String debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(debtsRepoProvider);
    final d = ref.watch(debtProvider(debtId)).value;
    if (d == null) return const SizedBox(height: 120);
    final history = ref.watch(debtHistoryProvider(debtId)).value ?? const <DebtPayment>[];
    final balance = balanceOf(d, history);
    final details = [l10n.debtKind(d.kind), ?d.counterparty, ?d.reference].join(' · ');

    void open(Widget sheet) {
      showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);
    }

    return SheetBody(
      title: d.name,
      children: [
        Text(details, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          l10n.debtBalanceLine(
            formatPeso(balance, locale: locale, whole: true),
            formatPeso(d.principalMinor, locale: locale, whole: true),
          ),
          key: const Key('debt-balance'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (!d.isClosed && (d.nextDueOn != null || d.installmentMinor != null)) ...[
          const SizedBox(height: 4),
          Text(
            [
              if (d.nextDueOn != null) dueText(l10n, locale, d.nextDueOn, repo.today),
              if (d.installmentMinor != null)
                l10n.debtInstallmentLine(formatPeso(d.installmentMinor!, locale: locale, whole: true)),
            ].join(' · '),
          ),
        ],
        if (d.note != null) ...[const SizedBox(height: 4), Text(d.note!, style: Theme.of(context).textTheme.bodySmall)],
        const SizedBox(height: 16),
        if (d.isClosed)
          repo.canReopen(d)
              ? OutlinedButton(onPressed: () => repo.reopen(d), child: Text(l10n.debtReopen))
              : Text(l10n.debtReopenOnlyCloser, style: Theme.of(context).textTheme.bodySmall)
        else ...[
          FilledButton.icon(
            onPressed: () => open(PaymentForm(debt: d)),
            icon: const Icon(Icons.payments_outlined),
            label: Text(l10n.debtPay(d.kind)),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => open(PaymentForm(debt: d, charge: true)),
            child: Text(l10n.debtAddCharge(d.kind)),
          ),
          TextButton(onPressed: () => repo.close(d), child: Text(l10n.debtClose(d.kind))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              open(DebtForm(debt: d));
            },
            child: Text(l10n.debtEdit),
          ),
        ],
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await repo.removeDebt(d.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.debtRemove),
        ),
        const SizedBox(height: 8),
        Text(l10n.debtHistory, style: Theme.of(context).textTheme.titleMedium),
        if (history.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.debtHistoryEmpty))
        else
          for (final p in history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.debtEntry(p.kind)),
              subtitle: Text(DateFormat.yMMMd(locale).format(parseIsoDate(p.paidOn)!)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${p.kind == chargeKind ? '+' : '−'}${formatPeso(p.amountMinor, locale: locale, whole: true)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (repo.canRemove(p))
                    IconButton(
                      tooltip: l10n.debtRemoveEntry,
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

/// Record a payment (or interest only), or add to the balance ([charge]).
class PaymentForm extends ConsumerStatefulWidget {
  const PaymentForm({super.key, required this.debt, this.charge = false});

  final Debt debt;
  final bool charge;

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  late final _amount = TextEditingController(
    text: widget.charge || widget.debt.installmentMinor == null ? '' : _plain(widget.debt.installmentMinor!),
  );
  bool _interestOnly = false;
  bool _tried = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = parsePeso(_amount.text);
    if (v == null || v <= 0) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(debtsRepoProvider);
    if (widget.charge) {
      await repo.addCharge(widget.debt, v);
    } else {
      await repo.pay(widget.debt, v, interestOnly: _interestOnly);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = widget.debt;
    final lent = d.kind == lentKind;
    final v = parsePeso(_amount.text);
    return SheetBody(
      title: widget.charge ? l10n.debtAddCharge(d.kind) : l10n.debtPay(d.kind),
      children: [
        TextField(
          key: const Key('debt-payment-amount'),
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: widget.charge ? l10n.debtAmountAdded : l10n.debtAmountPaid,
            errorText: _tried && (v == null || v <= 0) ? l10n.amountInvalid : null,
          ),
        ),
        if (!widget.charge && !lent) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.debtInterestOnly),
            subtitle: Text(l10n.debtInterestHelp(d.kind)),
            value: _interestOnly,
            onChanged: (v) => setState(() => _interestOnly = v),
          ),
          Text(l10n.debtPayHint, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// Add or edit a debt. The kind is chosen when adding.
class DebtForm extends ConsumerStatefulWidget {
  const DebtForm({super.key, this.debt});

  final Debt? debt;

  @override
  ConsumerState<DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends ConsumerState<DebtForm> {
  late String _kind = widget.debt?.kind ?? 'loan';
  late final _name = TextEditingController(text: widget.debt?.name ?? '');
  late final _counterparty = TextEditingController(text: widget.debt?.counterparty ?? '');
  late final _reference = TextEditingController(text: widget.debt?.reference ?? '');
  late final _principal = TextEditingController(text: widget.debt == null ? '' : _plain(widget.debt!.principalMinor));
  late final _installment = TextEditingController(
    text: widget.debt?.installmentMinor == null ? '' : _plain(widget.debt!.installmentMinor!),
  );
  late final _note = TextEditingController(text: widget.debt?.note ?? '');
  late DateTime? _due = parseIsoDate(widget.debt?.nextDueOn);
  late bool _monthly = widget.debt == null ? true : widget.debt!.repeat == 'monthly';
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_name, _counterparty, _reference, _principal, _installment, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _installmentValue => _installment.text.trim().isEmpty ? null : parsePeso(_installment.text);
  bool get _installmentBad => _installment.text.trim().isNotEmpty && _installmentValue == null;

  Future<void> _save() async {
    final principal = parsePeso(_principal.text);
    if (_name.text.trim().isEmpty || principal == null || _installmentBad) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(debtsRepoProvider);
    final d = widget.debt;
    if (d == null) {
      await repo.addDebt(
        kind: _kind,
        name: _name.text,
        principalMinor: principal,
        counterparty: _counterparty.text,
        reference: _reference.text,
        installmentMinor: _installmentValue,
        nextDueOn: _due,
        monthly: _due != null && _monthly,
        note: _note.text,
      );
    } else {
      await repo.editDebt(
        d,
        name: _name.text,
        principalMinor: principal,
        counterparty: _counterparty.text,
        reference: _reference.text,
        installmentMinor: _installmentValue,
        nextDueOn: _due,
        monthly: _due != null && _monthly,
        note: _note.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(debtsRepoProvider).today;
    final adding = widget.debt == null;
    return SheetBody(
      title: adding ? l10n.debtAdd : l10n.debtEdit,
      children: [
        if (adding) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in debtKinds)
                ChoiceChip(
                  avatar: Icon(debtIcon(k), size: 18),
                  label: Text(l10n.debtKind(k)),
                  selected: _kind == k,
                  onSelected: (_) => setState(() {
                    _kind = k;
                    if (k == lentKind) _monthly = false;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          key: const Key('debt-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.debtNameHint(_kind),
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('debt-principal'),
          controller: _principal,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.debtPrincipalLabel(_kind),
            errorText: _tried && parsePeso(_principal.text) == null ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _counterparty,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.debtCounterpartyLabel(_kind)),
        ),
        if (_kind != lentKind) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _reference,
            decoration: InputDecoration(labelText: l10n.debtReferenceLabel(_kind)),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('debt-installment'),
            controller: _installment,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₱ ',
              labelText: l10n.debtInstallmentLabel(_kind),
              errorText: _tried && _installmentBad ? l10n.amountInvalid : null,
            ),
          ),
        ],
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(
            _due == null ? l10n.debtSetDue : l10n.debtDueLabel(_kind, DateFormat.yMMMEd(locale).format(_due!)),
          ),
          trailing: _due == null
              ? null
              : IconButton(
                  tooltip: l10n.debtClearDue,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _due = null),
                ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _due ?? today,
              firstDate: DateTime(today.year - 2),
              lastDate: DateTime(today.year + 5),
            );
            if (picked != null) setState(() => _due = picked);
          },
        ),
        if (_due != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.debtRepeatMonthly),
            subtitle: Text(l10n.debtRepeatHelp),
            value: _monthly,
            onChanged: (v) => setState(() => _monthly = v),
          ),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.debtNote),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
