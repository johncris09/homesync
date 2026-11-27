import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'vehicles_repository.dart';

final vehiclesRepoProvider = Provider<VehiclesRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return VehiclesRepository(s.db, s.writer);
});

/// Vehicles are for adults (`read`/`write` in api/config/homesync.php).
final canSeeVehiclesProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) => ref.watch(vehiclesRepoProvider).watchVehicles());

final vehicleLogsProvider = StreamProvider<List<VehicleLog>>((ref) => ref.watch(vehiclesRepoProvider).watchLogs());

final vehicleProvider = StreamProvider.family<Vehicle?, String>(
  (ref, id) => ref.watch(vehiclesRepoProvider).watchVehicle(id),
);

final vehicleHistoryProvider = StreamProvider.family<List<VehicleLog>, String>(
  (ref, id) => ref.watch(vehiclesRepoProvider).watchHistory(id),
);

final vehiclesSummaryProvider = Provider<VehiclesSummary>((ref) {
  final repo = ref.watch(vehiclesRepoProvider);
  return VehiclesSummary(
    ref.watch(vehiclesProvider).value ?? const <Vehicle>[],
    ref.watch(vehicleLogsProvider).value ?? const <VehicleLog>[],
    repo.today,
  );
});
