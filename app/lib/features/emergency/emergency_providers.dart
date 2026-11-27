import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'emergency_repository.dart';

final emergencyRepoProvider = Provider<EmergencyRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return EmergencyRepository(s.db, s.writer);
});

/// Adults edit contacts, the plan and the hazard checklists.
final canEditEmergencyProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

/// The person using the app: their member id and role.
final emergencyMeProvider = Provider<({String id, String role})?>((ref) {
  final p = ref.watch(authProvider).session?.active;
  return p == null ? null : (id: p.memberId, role: p.role);
});

/// Whether the person using the app may tick items in [bag]: adults any bag;
/// others (not viewers) their own and the household's.
bool canTickBag(({String id, String role})? me, String? bagMemberId) {
  if (me == null || me.role == 'viewer') return false;
  if (me.role == 'owner' || me.role == 'adult') return true;
  return bagMemberId == null || bagMemberId == me.id;
}

final emergencyContactsProvider = StreamProvider<List<EmergencyContact>>(
  (ref) => ref.watch(emergencyRepoProvider).watchContacts(),
);

final emergencyPlanProvider = StreamProvider<EmergencyPlan?>((ref) => ref.watch(emergencyRepoProvider).watchPlan());

final goBagItemsProvider = StreamProvider<List<GoBagItem>>((ref) => ref.watch(emergencyRepoProvider).watchBagItems());

final emergencyChecksProvider = StreamProvider<List<EmergencyCheck>>(
  (ref) => ref.watch(emergencyRepoProvider).watchChecks(),
);

final safetyCheckinsProvider = StreamProvider<List<SafetyCheckin>>(
  (ref) => ref.watch(emergencyRepoProvider).watchCheckins(),
);

final checkinBoardProvider = Provider<CheckinBoard>(
  (ref) => CheckinBoard(
    ref.watch(membersProvider).value ?? const <Member>[],
    ref.watch(safetyCheckinsProvider).value ?? const <SafetyCheckin>[],
    ref.watch(emergencyRepoProvider).now,
  ),
);

final goBagsProvider = Provider<List<GoBag>>(
  (ref) =>
      goBags(ref.watch(membersProvider).value ?? const <Member>[], ref.watch(goBagItemsProvider).value ?? const []),
);

/// Ticked items per hazard.
final hazardDoneProvider = Provider<Map<String, Set<String>>>((ref) {
  final out = <String, Set<String>>{for (final h in hazardChecklists.keys) h: <String>{}};
  for (final c in ref.watch(emergencyChecksProvider).value ?? const <EmergencyCheck>[]) {
    if (c.done) out[c.hazard]?.add(c.item);
  }
  return out;
});
