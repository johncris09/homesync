import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'maintenance_repository.dart';

final maintenanceRepoProvider = Provider<MaintenanceRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return MaintenanceRepository(s.db, s.writer);
});

/// Adults add tasks, mark them done, log repairs and see costs; everyone
/// else sees what's due and the contractors.
final canEditMaintenanceProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

final maintenanceTasksProvider = StreamProvider<List<MaintenanceTask>>(
  (ref) => ref.watch(maintenanceRepoProvider).watchTasks(),
);

final maintenanceLogsProvider = StreamProvider<List<MaintenanceLog>>(
  (ref) => ref.watch(maintenanceRepoProvider).watchLogs(),
);

final contractorsProvider = StreamProvider<List<Contractor>>(
  (ref) => ref.watch(maintenanceRepoProvider).watchContractors(),
);

final contractorsByIdProvider = Provider<Map<String, Contractor>>(
  (ref) => {for (final c in ref.watch(contractorsProvider).value ?? const <Contractor>[]) c.id: c},
);

final maintenanceSummaryProvider = Provider<MaintenanceSummary>(
  (ref) => MaintenanceSummary(
    ref.watch(maintenanceTasksProvider).value ?? const [],
    ref.watch(maintenanceLogsProvider).value ?? const [],
    ref.watch(maintenanceRepoProvider).today,
  ),
);
