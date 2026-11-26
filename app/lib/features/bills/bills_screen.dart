import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../budget/budget_repository.dart' show categoryIcon, categoryLabel, expenseCategories;
import '../sync/sync_widgets.dart';
import 'bills_providers.dart';
import 'bills_repository.dart';

/// Bills & Subscriptions: what is due, paying it (posted to the Budget
/// ledger), and recurring subscriptions.
class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this, initialIndex: widget.initialTab)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final summary = ref.watch(billsSummaryProvider);
    final next = summary.next;

    final figure = summary.due > 0
        ? l10n.billsToPay(formatPeso(summary.due, locale: locale, whole: true))
        : l10n.billsAllPaid;
    final caption = summary.overdue > 0
        ? l10n.billsOverdueCaption(summary.overdue)
        : next != null
        ? l10n.billsNextCaption(next.name, _shortDate(locale, next.dueOn))
        : l10n.billsEmptyCaption;
    final color = summary.overdue > 0 ? HomeColors.gumamela : HomeColors.narra;
    final onSubs = _tabs.index == 1;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HomeColors.mangga,
        foregroundColor: HomeColors.narra,
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => onSubs ? const SubscriptionForm() : const BillForm(),
        ),
        icon: const Icon(Icons.add),
        label: Text(onSubs ? l10n.subscriptionAdd : l10n.billAdd),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: color,
            leading: const BackButton(color: Colors.white),
          ),
          Material(
            color: color,
            child: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: HomeColors.mangga,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.billsTab),
                Tab(text: l10n.subscriptionsTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(controller: _tabs, children: const [BillsTab(), SubscriptionsTab()]),
          ),
        ],
      ),
    );
  }
}

String _shortDate(String locale, String iso) {
  final d = parseIsoDate(iso);
  return d == null ? iso : DateFormat.MMMd(locale).format(d);
}

/// "Overdue by 3 days", "Due today", "Due in 2 days", "Due Dec 5".
String dueText(AppLocalizations l10n, String locale, String? dueOn, DateTime today) {
  final on = parseIsoDate(dueOn);
  if (on == null) return l10n.billNoDueDate;
  final days = daysUntil(on, today);
  if (days < 0) return l10n.billOverdueBy(-days);
  if (days <= dueSoonDays) return l10n.billDueIn(days);
  return l10n.billDueOn(DateFormat.MMMd(locale).format(on));
}

Color dueColor(DueStatus s) => switch (s) {
  DueStatus.overdue => HomeColors.gumamela,
  DueStatus.soon => const Color(0xFF8A5A00), // Mangga, darkened for text
  _ => HomeColors.narra,
};

// -------------------------------------------------------------------- bills

class BillsTab extends ConsumerWidget {
  const BillsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unpaid = ref.watch(unpaidBillsProvider).value ?? const <Bill>[];
    final paid = ref.watch(paidBillsProvider).value ?? const <Bill>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (unpaid.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(paid.isEmpty ? l10n.billsEmpty : l10n.billsNoneDue, textAlign: TextAlign.center),
          )
        else
          Card(
            child: Column(children: [for (final b in unpaid) _BillTile(bill: b)]),
          ),
        if (paid.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.billsPaidRecently, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(children: [for (final b in paid) _BillTile(bill: b)]),
          ),
        ],
      ],
    );
  }
}

class _BillTile extends ConsumerWidget {
  const _BillTile({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(billsRepoProvider).today;
    final b = bill;
    final status = b.isPaid ? DueStatus.none : dueStatus(b.dueOn, today);
    final subtitle = b.isPaid
        ? l10n.billPaidOn(DateFormat.MMMd(locale).format((b.paidAt ?? today).toLocal()))
        : dueText(l10n, locale, b.dueOn, today);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: b.isPaid ? HomeColors.dahon : HomeColors.capiz,
        foregroundColor: b.isPaid ? Colors.white : HomeColors.narra,
        child: Icon(b.isPaid ? Icons.check : categoryIcon(b.category)),
      ),
      title: Row(
        children: [
          Flexible(child: Text(b.name, overflow: TextOverflow.ellipsis)),
          if (b.repeat == 'monthly') ...[
            const SizedBox(width: 6),
            Icon(Icons.repeat, size: 16, semanticLabel: l10n.billMonthly),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: dueColor(status), fontWeight: status == DueStatus.overdue ? FontWeight.w600 : null),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatPeso(b.amountMinor, locale: locale),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          SyncMarker(entity: 'bills', id: b.id),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => BillSheet(bill: b),
      ),
    );
  }
}

/// One bill: pay it (amount can be adjusted), edit, remove; or undo a
/// payment you recorded.
class BillSheet extends ConsumerStatefulWidget {
  const BillSheet({super.key, required this.bill});

  final Bill bill;

  @override
  ConsumerState<BillSheet> createState() => _BillSheetState();
}

class _BillSheetState extends ConsumerState<BillSheet> {
  late final _amount = TextEditingController(text: _plain(widget.bill.amountMinor));
  late final Future<bool> _canUndo = widget.bill.isPaid
      ? ref.read(billsRepoProvider).canUndo(widget.bill)
      : Future.value(false);
  bool _tried = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final v = parsePeso(_amount.text);
    if (v == null) {
      setState(() => _tried = true);
      return;
    }
    await ref.read(billsRepoProvider).payBill(widget.bill, amountMinor: v);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final b = widget.bill;
    final repo = ref.read(billsRepoProvider);

    if (b.isPaid) {
      return SheetBody(
        title: b.name,
        children: [
          Text(
            '${formatPeso(b.amountMinor, locale: locale)} · '
            '${l10n.billPaidOn(DateFormat.yMMMd(locale).format((b.paidAt ?? repo.today).toLocal()))}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FutureBuilder<bool>(
            future: _canUndo,
            builder: (context, snap) => snap.data == true
                ? OutlinedButton(
                    onPressed: () async {
                      await repo.undoPaid(b);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(l10n.billUndoPaid),
                  )
                : Text(l10n.billUndoOnlyPayer, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      );
    }

    return SheetBody(
      title: b.name,
      children: [
        Text(
          '${dueText(l10n, locale, b.dueOn, repo.today)} · ${categoryLabel(l10n, b.category)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('pay-amount'),
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.billAmountPaid,
            errorText: _tried && parsePeso(_amount.text) == null ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.billPayHint(categoryLabel(l10n, b.category ?? defaultBillCategory)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _pay, icon: const Icon(Icons.check), label: Text(l10n.billMarkPaid)),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => BillForm(bill: b),
            );
          },
          child: Text(l10n.billEdit),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await repo.removeBill(b.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.billRemove),
        ),
      ],
    );
  }
}

String _plain(int minor) => minor % 100 == 0 ? '${minor ~/ 100}' : (minor / 100).toStringAsFixed(2);

/// Add or edit a bill.
class BillForm extends ConsumerStatefulWidget {
  const BillForm({super.key, this.bill});

  final Bill? bill;

  @override
  ConsumerState<BillForm> createState() => _BillFormState();
}

class _BillFormState extends ConsumerState<BillForm> {
  late final _name = TextEditingController(text: widget.bill?.name ?? '');
  late final _amount = TextEditingController(text: widget.bill == null ? '' : _plain(widget.bill!.amountMinor));
  late String _category = widget.bill?.category ?? defaultBillCategory;
  late bool _monthly = widget.bill == null || widget.bill!.repeat == 'monthly';
  late DateTime _due = parseIsoDate(widget.bill?.dueOn) ?? ref.read(billsRepoProvider).today;
  bool _tried = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parsePeso(_amount.text);
    if (_name.text.trim().isEmpty || amount == null) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(billsRepoProvider);
    final b = widget.bill;
    if (b == null) {
      await repo.addBill(name: _name.text, amountMinor: amount, dueOn: _due, category: _category, monthly: _monthly);
    } else {
      await repo.editBill(
        b,
        name: _name.text,
        amountMinor: amount,
        dueOn: _due,
        category: _category,
        monthly: _monthly,
        provider: b.provider,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(billsRepoProvider).today;
    return SheetBody(
      title: widget.bill == null ? l10n.billAdd : l10n.billEdit,
      children: [
        TextField(
          key: const Key('bill-name'),
          controller: _name,
          autofocus: widget.bill == null,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.billNameHint,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('bill-amount'),
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.amount,
            helperText: l10n.billAmountHelp,
            errorText: _tried && parsePeso(_amount.text) == null ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.billDueLabel(DateFormat.yMMMEd(locale).format(_due))),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _due,
              firstDate: DateTime(today.year - 1),
              lastDate: DateTime(today.year + 2),
            );
            if (picked != null) setState(() => _due = picked);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.billRepeatMonthly),
          subtitle: Text(l10n.billRepeatHelp),
          value: _monthly,
          onChanged: (v) => setState(() => _monthly = v),
        ),
        const SizedBox(height: 8),
        _CategoryChips(selected: _category, onSelected: (c) => setState(() => _category = c)),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.billCategoryLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in expenseCategories)
              ChoiceChip(
                avatar: Icon(categoryIcon(c), size: 18),
                label: Text(categoryLabel(l10n, c)),
                selected: selected == c,
                onSelected: (_) => onSelected(c),
              ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ subscriptions

class SubscriptionsTab extends ConsumerWidget {
  const SubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final subs = ref.watch(subscriptionsProvider).value ?? const <Subscription>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (subs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.subscriptionsEmpty, textAlign: TextAlign.center),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              l10n.subscriptionsMonthly(formatPeso(monthlyCost(subs), locale: locale, whole: true)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Column(children: [for (final s in subs) _SubscriptionTile(sub: s)]),
          ),
        ],
      ],
    );
  }
}

class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile({required this.sub});

  final Subscription sub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(billsRepoProvider).today;
    final s = sub;
    final status = dueStatus(s.nextDueOn, today);
    final cycle = s.cycle == 'yearly' ? l10n.subscriptionYearly : l10n.subscriptionMonthly;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: HomeColors.capiz,
        foregroundColor: HomeColors.narra,
        child: Icon(categoryIcon(s.category)),
      ),
      title: Text(s.name),
      subtitle: Text(
        '$cycle · ${dueText(l10n, locale, s.nextDueOn, today)}',
        style: TextStyle(color: dueColor(status), fontWeight: status == DueStatus.overdue ? FontWeight.w600 : null),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatPeso(s.priceMinor, locale: locale),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          SyncMarker(entity: 'subscriptions', id: s.id),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => SubscriptionSheet(sub: s),
      ),
    );
  }
}

class SubscriptionSheet extends ConsumerWidget {
  const SubscriptionSheet({super.key, required this.sub});

  final Subscription sub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(billsRepoProvider);
    final s = sub;
    return SheetBody(
      title: s.name,
      children: [
        Text(
          '${formatPeso(s.priceMinor, locale: locale)} · ${dueText(l10n, locale, s.nextDueOn, repo.today)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.subscriptionPayHint(categoryLabel(l10n, s.category ?? defaultSubscriptionCategory)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            await repo.paySubscription(s);
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.check),
          label: Text(l10n.billMarkPaid),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => SubscriptionForm(sub: s),
            );
          },
          child: Text(l10n.subscriptionEdit),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await repo.removeSubscription(s.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.subscriptionRemove),
        ),
      ],
    );
  }
}

/// Add or edit a subscription.
class SubscriptionForm extends ConsumerStatefulWidget {
  const SubscriptionForm({super.key, this.sub});

  final Subscription? sub;

  @override
  ConsumerState<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends ConsumerState<SubscriptionForm> {
  late final _name = TextEditingController(text: widget.sub?.name ?? '');
  late final _price = TextEditingController(text: widget.sub == null ? '' : _plain(widget.sub!.priceMinor));
  late String _cycle = widget.sub?.cycle ?? 'monthly';
  late String _category = widget.sub?.category ?? defaultSubscriptionCategory;
  late DateTime _next = parseIsoDate(widget.sub?.nextDueOn) ?? ref.read(billsRepoProvider).today;
  bool _tried = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = parsePeso(_price.text);
    if (_name.text.trim().isEmpty || price == null) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(billsRepoProvider);
    final s = widget.sub;
    if (s == null) {
      await repo.addSubscription(
        name: _name.text,
        priceMinor: price,
        nextDueOn: _next,
        cycle: _cycle,
        category: _category,
      );
    } else {
      await repo.editSubscription(
        s,
        name: _name.text,
        priceMinor: price,
        nextDueOn: _next,
        cycle: _cycle,
        category: _category,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(billsRepoProvider).today;
    return SheetBody(
      title: widget.sub == null ? l10n.subscriptionAdd : l10n.subscriptionEdit,
      children: [
        TextField(
          key: const Key('sub-name'),
          controller: _name,
          autofocus: widget.sub == null,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.subscriptionNameHint,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('sub-price'),
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.subscriptionPrice,
            errorText: _tried && parsePeso(_price.text) == null ? l10n.amountInvalid : null,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'monthly', label: Text(l10n.subscriptionMonthly)),
            ButtonSegment(value: 'yearly', label: Text(l10n.subscriptionYearly)),
          ],
          selected: {_cycle},
          onSelectionChanged: (s) => setState(() => _cycle = s.first),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.subscriptionNextLabel(DateFormat.yMMMEd(locale).format(_next))),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _next,
              firstDate: DateTime(today.year - 1),
              lastDate: DateTime(today.year + 2),
            );
            if (picked != null) setState(() => _next = picked);
          },
        ),
        const SizedBox(height: 8),
        _CategoryChips(selected: _category, onSelected: (c) => setState(() => _category = c)),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
