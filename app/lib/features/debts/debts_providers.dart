import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'debts_repository.dart';

final debtsRepoProvider = Provider<DebtsRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return DebtsRepository(s.db, s.writer);
});

/// Debts are for adults (`read`/`write` in api/config/homesync.php).
final canSeeDebtsProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

final openDebtsProvider = StreamProvider<List<Debt>>((ref) => ref.watch(debtsRepoProvider).watchOpen());

final closedDebtsProvider = StreamProvider<List<Debt>>((ref) => ref.watch(debtsRepoProvider).watchClosed());

final debtPaymentsProvider = StreamProvider<List<DebtPayment>>((ref) => ref.watch(debtsRepoProvider).watchPayments());

final debtProvider = StreamProvider.family<Debt?, String>((ref, id) => ref.watch(debtsRepoProvider).watchDebt(id));

final debtHistoryProvider = StreamProvider.family<List<DebtPayment>, String>(
  (ref, id) => ref.watch(debtsRepoProvider).watchHistory(id),
);

final debtsSummaryProvider = Provider<DebtsSummary>((ref) {
  final repo = ref.watch(debtsRepoProvider);
  return DebtsSummary(
    ref.watch(openDebtsProvider).value ?? const <Debt>[],
    ref.watch(debtPaymentsProvider).value ?? const <DebtPayment>[],
    repo.today,
  );
});
