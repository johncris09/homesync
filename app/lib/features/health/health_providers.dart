import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../vault/vault_providers.dart' show vaultSessionProvider;
import 'health_repository.dart';

final healthRepoProvider = Provider<HealthRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return HealthRepository(s.db, s.writer, session: s.vault, crypto: s.vaultCrypto);
});

/// Everyone sees medicines, doses and checkups (`read` in
/// api/config/homesync.php).
final canSeeHealthProvider = Provider<bool>((ref) => ref.watch(authProvider).session != null);

/// Everyone but viewers gives doses.
final canGiveDosesProvider = Provider<bool>((ref) {
  final role = ref.watch(authProvider).session?.active.role;
  return role != null && role != 'viewer';
});

/// Adults manage medicines, checkups and profiles.
final canManageHealthProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

final medicinesProvider = StreamProvider<List<Medicine>>((ref) => ref.watch(healthRepoProvider).watchMedicines());

final medicineProvider = StreamProvider.family<Medicine?, String>(
  (ref, id) => ref.watch(healthRepoProvider).watchMedicine(id),
);

final recentDosesProvider = StreamProvider<List<MedDose>>((ref) => ref.watch(healthRepoProvider).watchRecentDoses());

final medicineDosesProvider = StreamProvider.family<List<MedDose>, String>(
  (ref, id) => ref.watch(healthRepoProvider).watchDoses(id),
);

final checkupsProvider = StreamProvider<List<Checkup>>((ref) => ref.watch(healthRepoProvider).watchCheckups());

final healthProfilesProvider = StreamProvider<List<HealthProfile>>(
  (ref) => ref.watch(healthRepoProvider).watchProfiles(),
);

/// Profiles opened with the vault key, by member; empty while locked.
final openProfilesProvider = FutureProvider<Map<String, HealthFields>>((ref) async {
  final unlocked = ref.watch(vaultSessionProvider.select((s) => s.unlocked));
  final rows = ref.watch(healthProfilesProvider).value ?? const <HealthProfile>[];
  if (!unlocked) return const {};
  final repo = ref.watch(healthRepoProvider);
  final out = <String, HealthFields>{};
  for (final r in rows) {
    final f = await repo.openProfile(r);
    if (f != null) out[r.memberId] = f;
  }
  return out;
});

final healthSummaryProvider = Provider<HealthSummary>((ref) {
  final repo = ref.watch(healthRepoProvider);
  return HealthSummary(
    medicines: ref.watch(medicinesProvider).value ?? const <Medicine>[],
    doses: ref.watch(recentDosesProvider).value ?? const <MedDose>[],
    checkups: ref.watch(checkupsProvider).value ?? const <Checkup>[],
    today: repo.today,
  );
});
