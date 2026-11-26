import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'budget_repository.dart';

final budgetRepoProvider = Provider<BudgetRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return BudgetRepository(s.db, s.writer);
});

/// Adults read the whole ledger and set budgets (`read`/`write` in
/// api/config/homesync.php).
final canSeeBudgetProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

/// Everyone but viewers may record spending.
final canRecordSpendingProvider = Provider<bool>((ref) {
  final role = ref.watch(authProvider).session?.active.role;
  return role != null && role != 'viewer';
});

/// Month shown on the Budget screen (first day, local).
final budgetMonthProvider = StateProvider<DateTime>((ref) => monthOf(ref.watch(budgetRepoProvider).today));

/// Entries of the shown month. Non-adults only see their own, also on the
/// shared tablet where the ledger is pulled with an adult's token.
final monthEntriesProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final month = ref.watch(budgetMonthProvider);
  return ref.watch(budgetRepoProvider).watchMonth(month, memberId: ref.watch(_ledgerFilterProvider));
});

/// Null = every entry (adults); a member id = only theirs; '' = none.
final _ledgerFilterProvider = Provider<String?>((ref) {
  final session = ref.watch(authProvider).session;
  if (session == null) return '';
  return session.active.isAdult ? null : session.active.memberId;
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) => ref.watch(budgetRepoProvider).watchBudgets());

final monthSummaryProvider = Provider<MonthSummary>((ref) {
  final entries = ref.watch(monthEntriesProvider).value ?? const <LedgerEntry>[];
  final budgets = ref.watch(canSeeBudgetProvider)
      ? (ref.watch(budgetsProvider).value ?? const <Budget>[])
      : const <Budget>[];
  return MonthSummary(entries, budgets);
});

/// This month's summary for the home tile, independent of the month shown.
final currentMonthSummaryProvider = StreamProvider<MonthSummary>((ref) async* {
  final repo = ref.watch(budgetRepoProvider);
  final adult = ref.watch(canSeeBudgetProvider);
  final budgets = adult ? (ref.watch(budgetsProvider).value ?? const <Budget>[]) : const <Budget>[];
  await for (final entries in repo.watchMonth(repo.today, memberId: ref.watch(_ledgerFilterProvider))) {
    yield MonthSummary(entries, budgets);
  }
});
