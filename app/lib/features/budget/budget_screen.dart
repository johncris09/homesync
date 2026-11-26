import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../sync/sync_widgets.dart';
import 'budget_providers.dart';
import 'budget_repository.dart';

/// Budget: this month's spending against each category's limit, and the
/// ledger. Non-adults get a "record an expense" view of their own entries.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final adult = ref.watch(canSeeBudgetProvider);
    final canRecord = ref.watch(canRecordSpendingProvider);
    final month = ref.watch(budgetMonthProvider);
    final summary = ref.watch(monthSummaryProvider);
    final entries = ref.watch(monthEntriesProvider).value ?? const <LedgerEntry>[];
    final monthName = DateFormat.MMMM(locale).format(month);

    final String figure;
    final String caption;
    if (!adult) {
      figure = formatPeso(summary.spent, locale: locale, whole: true);
      caption = l10n.budgetMineCaption(monthName);
    } else if (summary.hasBudget) {
      final left = summary.left;
      figure = left >= 0
          ? l10n.budgetLeft(formatPeso(left, locale: locale, whole: true))
          : l10n.budgetOver(formatPeso(-left, locale: locale, whole: true));
      caption = l10n.budgetSpentOf(
        formatPeso(summary.spent, locale: locale, whole: true),
        formatPeso(summary.budgeted, locale: locale, whole: true),
        monthName,
      );
    } else {
      figure = l10n.budgetSpent(formatPeso(summary.spent, locale: locale, whole: true));
      caption = l10n.budgetNoLimitsCaption(monthName);
    }

    return Scaffold(
      floatingActionButton: canRecord
          ? FloatingActionButton.extended(
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => EntryForm(allowIncome: adult),
              ),
              icon: const Icon(Icons.add),
              label: Text(adult ? l10n.budgetAdd : l10n.budgetRecordExpense),
            )
          : null,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: HomeColors.dahon,
            leading: const BackButton(color: Colors.white),
          ),
          _MonthBar(month: month),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (adult) ...[
                  _CategoriesCard(summary: summary),
                  const SizedBox(height: 8),
                  if (summary.income > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(l10n.budgetMoneyIn(formatPeso(summary.income, locale: locale))),
                    ),
                  const SizedBox(height: 16),
                ],
                Text(
                  adult ? l10n.budgetEntriesTitle : l10n.budgetMyEntriesTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l10n.budgetNoEntries, textAlign: TextAlign.center),
                  )
                else
                  _EntriesList(entries: entries),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBar extends ConsumerWidget {
  const _MonthBar({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final current = monthOf(ref.read(budgetRepoProvider).today);
    void go(int delta) => ref.read(budgetMonthProvider.notifier).state = DateTime(month.year, month.month + delta);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(tooltip: l10n.budgetPrevMonth, icon: const Icon(Icons.chevron_left), onPressed: () => go(-1)),
          Expanded(
            child: Text(
              DateFormat.yMMMM(locale).format(month),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: l10n.budgetNextMonth,
            icon: const Icon(Icons.chevron_right),
            onPressed: month.isBefore(current) ? () => go(1) : null,
          ),
        ],
      ),
    );
  }
}

class _CategoriesCard extends ConsumerWidget {
  const _CategoriesCard({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final shown = summary.categories;
    final others = [
      for (final c in expenseCategories)
        if (!shown.contains(c)) c,
    ];
    final budgets = {for (final b in ref.watch(budgetsProvider).value ?? const <Budget>[]) b.category: b};

    return Card(
      child: Column(
        children: [
          for (final c in shown)
            _CategoryRow(
              category: c,
              spent: summary.spentByCategory[c] ?? 0,
              limit: summary.limits[c],
              budgetId: budgets[c]?.id,
              locale: locale,
            ),
          if (others.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.add, color: HomeColors.dahon),
              title: Text(shown.isEmpty ? l10n.budgetSetFirst : l10n.budgetSetAnother),
              onTap: () async {
                final picked = await showModalBottomSheet<String>(
                  context: context,
                  builder: (sheet) => SafeArea(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final c in others)
                          ListTile(
                            leading: Icon(categoryIcon(c)),
                            title: Text(categoryLabel(l10n, c)),
                            onTap: () => Navigator.pop(sheet, c),
                          ),
                      ],
                    ),
                  ),
                );
                if (picked != null && context.mounted) await editBudget(context, ref, picked, null);
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({
    required this.category,
    required this.spent,
    required this.limit,
    required this.budgetId,
    required this.locale,
  });

  final String category;
  final int spent;
  final int? limit;
  final String? budgetId;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final limit = this.limit;
    final ratio = limit == null ? 0.0 : spent / limit;
    final barColor = ratio > 1 ? HomeColors.gumamela : (ratio >= 0.8 ? HomeColors.mangga : HomeColors.dahon);
    final amounts = limit == null
        ? l10n.budgetNoLimit(formatPeso(spent, locale: locale, whole: true))
        : l10n.budgetOf(formatPeso(spent, locale: locale, whole: true), formatPeso(limit, locale: locale, whole: true));

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: HomeColors.capiz,
        foregroundColor: HomeColors.dahon,
        child: Icon(categoryIcon(category)),
      ),
      title: Row(
        children: [
          Expanded(child: Text(categoryLabel(l10n, category))),
          if (budgetId != null) SyncMarker(entity: 'budgets', id: budgetId!),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(amounts),
          if (limit != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio.clamp(0, 1).toDouble(),
                minHeight: 6,
                color: barColor,
                backgroundColor: HomeColors.capiz,
              ),
            ),
          ],
        ],
      ),
      onTap: () => editBudget(context, ref, category, limit),
    );
  }
}

/// Sheet to set or clear a category's monthly limit.
Future<void> editBudget(BuildContext context, WidgetRef ref, String category, int? current) async {
  final l10n = AppLocalizations.of(context);
  final result = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AmountSheet(
      title: l10n.budgetLimitFor(categoryLabel(l10n, category)),
      initial: current,
      clearLabel: current == null ? null : l10n.budgetClear,
    ),
  );
  if (result != null) await ref.read(budgetRepoProvider).setBudget(category, result);
}

class _AmountSheet extends StatefulWidget {
  const _AmountSheet({required this.title, this.initial, this.clearLabel});

  final String title;
  final int? initial;

  /// When set, a button that returns 0 (no budget).
  final String? clearLabel;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late final _amount = TextEditingController(
    text: widget.initial == null ? '' : (widget.initial! / 100).toStringAsFixed(0),
  );
  bool _tried = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final v = parsePeso(_amount.text);
    if (v == null) {
      setState(() => _tried = true);
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: widget.title,
      children: [
        TextField(
          key: const Key('budget-limit'),
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.budgetMonthlyLimit,
            errorText: _tried && parsePeso(_amount.text) == null ? l10n.amountInvalid : null,
          ),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
        if (widget.clearLabel != null)
          TextButton(onPressed: () => Navigator.pop(context, 0), child: Text(widget.clearLabel!)),
      ],
    );
  }
}

class _EntriesList extends ConsumerWidget {
  const _EntriesList({required this.entries});

  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toString();
    final days = <DateTime, List<LedgerEntry>>{};
    for (final e in entries) {
      final d = e.occurredAt.toLocal();
      days.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(e);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final day in days.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Text(DateFormat.MMMEd(locale).format(day.key), style: Theme.of(context).textTheme.labelLarge),
          ),
          Card(
            child: Column(children: [for (final e in day.value) _EntryTile(entry: e)]),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final names = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m.name};
    final income = entry.amountMinor > 0;
    final amount = formatPeso(entry.amountMinor.abs(), locale: locale);
    final cat = categoryLabel(l10n, entry.category);
    final who = names[entry.memberId];

    return ListTile(
      leading: Icon(categoryIcon(entry.category), color: income ? HomeColors.dahon : HomeColors.narra),
      title: Text(entry.note ?? cat),
      subtitle: Text([if (entry.note != null) cat, ?who].join(' · ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            income ? '+$amount' : '−$amount',
            style: TextStyle(fontWeight: FontWeight.w600, color: income ? HomeColors.dahon : HomeColors.narra),
          ),
          const SizedBox(width: 6),
          SyncMarker(entity: 'transactions', id: entry.id),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => EntrySheet(entry: entry),
      ),
    );
  }
}

/// Details of one entry: edit the note or remove it. Amount, category and
/// date can't change (the ledger is append-only).
class EntrySheet extends ConsumerStatefulWidget {
  const EntrySheet({super.key, required this.entry});

  final LedgerEntry entry;

  @override
  ConsumerState<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  late final _note = TextEditingController(text: widget.entry.note ?? '');

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final e = widget.entry;
    final session = ref.watch(authProvider).session;
    final canChange = session != null && (session.active.isAdult || e.memberId == session.active.memberId);
    final repo = ref.read(budgetRepoProvider);

    return SheetBody(
      title: '${e.amountMinor > 0 ? '+' : '−'}${formatPeso(e.amountMinor.abs(), locale: locale)}',
      children: [
        Text(
          '${categoryLabel(l10n, e.category)} · ${DateFormat.yMMMEd(locale).format(e.occurredAt.toLocal())}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('entry-note'),
          controller: _note,
          enabled: canChange,
          decoration: InputDecoration(labelText: l10n.itemNote),
        ),
        const SizedBox(height: 8),
        Text(l10n.budgetAppendOnlyHint, style: Theme.of(context).textTheme.bodySmall),
        if (canChange) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              if (_note.text.trim() != (e.note ?? '')) await repo.setNote(e.id, _note.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              await repo.removeEntry(e.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.budgetRemoveEntry),
          ),
        ],
      ],
    );
  }
}

/// Add money out (or, for adults, money in).
class EntryForm extends ConsumerStatefulWidget {
  const EntryForm({super.key, this.allowIncome = true});

  final bool allowIncome;

  @override
  ConsumerState<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends ConsumerState<EntryForm> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _income = false;
  String? _category;
  late DateTime _date = ref.read(budgetRepoProvider).today;
  bool _tried = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _amountOk => parsePeso(_amount.text) != null;
  bool get _categoryOk => _income || _category != null;

  Future<void> _save() async {
    if (!_amountOk || !_categoryOk) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(budgetRepoProvider);
    final now = repo.today;
    final sameDay = _date.year == now.year && _date.month == now.month && _date.day == now.day;
    await repo.addEntry(
      amountMinor: parsePeso(_amount.text)!,
      income: _income,
      category: _category ?? 'other',
      occurredAt: sameDay ? now : DateTime(_date.year, _date.month, _date.day, 12),
      note: _note.text,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final today = ref.read(budgetRepoProvider).today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(today.year - 1),
      lastDate: today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return SheetBody(
      title: _income ? l10n.budgetAddIncome : l10n.budgetAddExpense,
      children: [
        if (widget.allowIncome) ...[
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l10n.budgetMoneyOut)),
              ButtonSegment(value: true, label: Text(l10n.budgetMoneyInLabel)),
            ],
            selected: {_income},
            onSelectionChanged: (s) => setState(() => _income = s.first),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          key: const Key('entry-amount'),
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            labelText: l10n.amount,
            errorText: _tried && !_amountOk ? l10n.amountInvalid : null,
          ),
        ),
        if (!_income) ...[
          const SizedBox(height: 16),
          Text(l10n.category, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in expenseCategories)
                ChoiceChip(
                  avatar: Icon(categoryIcon(c), size: 18),
                  label: Text(categoryLabel(l10n, c)),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
            ],
          ),
          if (_tried && !_categoryOk)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l10n.categoryRequired, style: const TextStyle(color: HomeColors.gumamela)),
            ),
        ],
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(DateFormat.yMMMEd(locale).format(_date)),
          onTap: _pickDate,
        ),
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.itemNote, hintText: l10n.budgetNoteHint),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
