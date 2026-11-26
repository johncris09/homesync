import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'bills_repository.dart';

final billsRepoProvider = Provider<BillsRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return BillsRepository(s.db, s.writer);
});

/// Bills and subscriptions are for adults (`read`/`write` in
/// api/config/homesync.php).
final canSeeBillsProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

final unpaidBillsProvider = StreamProvider<List<Bill>>((ref) => ref.watch(billsRepoProvider).watchUnpaid());

final paidBillsProvider = StreamProvider<List<Bill>>((ref) => ref.watch(billsRepoProvider).watchPaid());

final subscriptionsProvider = StreamProvider<List<Subscription>>(
  (ref) => ref.watch(billsRepoProvider).watchSubscriptions(),
);

final billsSummaryProvider = Provider<BillsSummary>((ref) {
  final repo = ref.watch(billsRepoProvider);
  return BillsSummary(
    ref.watch(unpaidBillsProvider).value ?? const <Bill>[],
    ref.watch(subscriptionsProvider).value ?? const <Subscription>[],
    repo.today,
  );
});
