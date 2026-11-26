import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show IconData, Icons;
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../l10n/app_localizations.dart';

/// Spending categories (fixed list for Phase 1; stored as these keys).
const expenseCategories = [
  'food',
  'utilities',
  'transport',
  'school',
  'health',
  'household',
  'load',
  'personal',
  'giving',
  'other',
];

/// Category of money coming in.
const incomeCategory = 'income';

String categoryLabel(AppLocalizations l10n, String? key) => switch (key) {
  'food' => l10n.catFood,
  'utilities' => l10n.catUtilities,
  'transport' => l10n.catTransport,
  'school' => l10n.catSchool,
  'health' => l10n.catHealth,
  'household' => l10n.catHousehold,
  'load' => l10n.catLoad,
  'personal' => l10n.catPersonal,
  'giving' => l10n.catGiving,
  'income' => l10n.catIncome,
  _ => l10n.catOther,
};

IconData categoryIcon(String? key) => switch (key) {
  'food' => Icons.restaurant_outlined,
  'utilities' => Icons.bolt_outlined,
  'transport' => Icons.directions_bus_outlined,
  'school' => Icons.school_outlined,
  'health' => Icons.medical_services_outlined,
  'household' => Icons.home_outlined,
  'load' => Icons.wifi_outlined,
  'personal' => Icons.person_outline,
  'giving' => Icons.volunteer_activism_outlined,
  'income' => Icons.savings_outlined,
  _ => Icons.more_horiz,
};

/// Namespace for derived ids (sync-protocol §2.1).
const derivedIdNamespace = '6f1c2b7e-3d4a-5e8f-9a0b-1c2d3e4f5a6b';

/// The one budget row for [category] in [householdId], the same on every device.
String budgetId(String householdId, String category) =>
    const Uuid().v5(derivedIdNamespace, 'budgets/$householdId/$category');

/// First day of the month of [d] (local).
DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

/// One month of money: what was spent per category against its budget.
class MonthSummary {
  MonthSummary(List<LedgerEntry> entries, List<Budget> budgets) {
    for (final e in entries) {
      if (e.amountMinor < 0) {
        final cat = e.category ?? 'other';
        spentByCategory[cat] = (spentByCategory[cat] ?? 0) - e.amountMinor;
        spent -= e.amountMinor;
      } else {
        income += e.amountMinor;
      }
    }
    for (final b in budgets) {
      if (b.limitMinor > 0) {
        limits[b.category] = b.limitMinor;
        budgeted += b.limitMinor;
      }
    }
  }

  final Map<String, int> spentByCategory = {};
  final Map<String, int> limits = {};
  int spent = 0;
  int income = 0;
  int budgeted = 0;

  bool get hasBudget => budgeted > 0;

  /// Budget left this month (negative when over).
  int get left => budgeted - spent;

  /// Categories to show: every budgeted one plus any with spending, in the
  /// fixed category order.
  List<String> get categories => [
    for (final c in expenseCategories)
      if (limits.containsKey(c) || spentByCategory.containsKey(c)) c,
  ];
}

/// Budget data. The ledger (`transactions`) is append-only: an entry's
/// amount, category and date never change; fix a mistake by removing the
/// entry and adding it again. Expenses are negative, income positive.
class BudgetRepository {
  BudgetRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today => _now();

  /// Entries in [month] (local calendar month), newest first. With
  /// [memberId], only that member's entries (for roles that may record
  /// but not read the ledger).
  Stream<List<LedgerEntry>> watchMonth(DateTime month, {String? memberId}) {
    final start = monthOf(month).toUtc();
    final end = DateTime(month.year, month.month + 1).toUtc();
    final q = db.select(db.transactions)
      ..where(
        (t) =>
            t.deletedAt.isNull() &
            t.occurredAt.isBiggerOrEqualValue(start) &
            t.occurredAt.isSmallerThanValue(end) &
            (memberId == null ? const Constant(true) : t.memberId.equals(memberId)),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt), (t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch();
  }

  Stream<List<Budget>> watchBudgets() => (db.select(db.budgets)..where((b) => b.deletedAt.isNull())).watch();

  /// Records money out ([income] false) or in. [amountMinor] is positive.
  Future<String> addEntry({
    required int amountMinor,
    required String category,
    required DateTime occurredAt,
    bool income = false,
    String? note,
  }) {
    if (amountMinor <= 0) throw ArgumentError.value(amountMinor, 'amountMinor', 'must be positive');
    return writer.insert('transactions', {
      'amount_minor': income ? amountMinor : -amountMinor,
      'category': income ? incomeCategory : category,
      'currency': 'PHP',
      'occurred_at': occurredAt.toUtc(),
      'member_id': writer.identity.memberId,
      'source_type': 'manual',
      'note': _blankToNull(note),
    });
  }

  Future<void> setNote(String id, String? note) => writer.update('transactions', id, {'note': _blankToNull(note)});

  Future<void> removeEntry(String id) => writer.delete('transactions', id);

  /// Sets the monthly limit for [category]; 0 means no budget. Uses the
  /// derived id so devices setting it offline share one row.
  Future<void> setBudget(String category, int limitMinor) async {
    final id = budgetId(writer.identity.householdId, category);
    final existing = await (db.select(db.budgets)..where((b) => b.id.equals(id))).getSingleOrNull();
    if (existing == null) {
      await writer.insert('budgets', {'category': category, 'limit_minor': limitMinor, 'currency': 'PHP'}, id: id);
    } else if (existing.limitMinor != limitMinor) {
      await writer.update('budgets', id, {'limit_minor': limitMinor});
    }
  }

  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}
