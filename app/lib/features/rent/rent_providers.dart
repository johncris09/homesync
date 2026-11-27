import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'rent_repository.dart';

final rentRepoProvider = Provider<RentRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return RentRepository(s.db, s.writer);
});

/// Rent is for adults (`read`/`write` in api/config/homesync.php).
final canSeeRentProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

final rentalUnitsProvider = StreamProvider<List<RentalUnit>>((ref) => ref.watch(rentRepoProvider).watchUnits());

final leasesProvider = StreamProvider<List<Lease>>((ref) => ref.watch(rentRepoProvider).watchLeases());

final rentPaymentsProvider = StreamProvider<List<RentPayment>>((ref) => ref.watch(rentRepoProvider).watchPayments());

final rentHistoryProvider = StreamProvider.family<List<RentPayment>, String>(
  (ref, leaseId) => ref.watch(rentRepoProvider).watchHistory(leaseId),
);

final rentSummaryProvider = Provider<RentSummary>((ref) {
  final repo = ref.watch(rentRepoProvider);
  return RentSummary(
    ref.watch(rentalUnitsProvider).value ?? const <RentalUnit>[],
    ref.watch(leasesProvider).value ?? const <Lease>[],
    ref.watch(rentPaymentsProvider).value ?? const <RentPayment>[],
    repo.today,
  );
});
