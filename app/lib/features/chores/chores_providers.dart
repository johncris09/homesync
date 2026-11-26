import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'chores_repository.dart';

final choresRepoProvider = Provider<ChoresRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return ChoresRepository(s.db, s.writer);
});

/// Adults add, change and remove chores (`write` in api/config/homesync.php).
final canManageChoresProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

/// Whether the active profile may tick [chore]: adults any; others (not
/// viewers) their own and unassigned ones.
final canTickProvider = Provider<bool Function(Chore)>((ref) {
  final active = ref.watch(authProvider).session?.active;
  return (chore) {
    if (active == null || active.role == 'viewer') return false;
    return active.isAdult || chore.assignedTo == null || chore.assignedTo == active.memberId;
  };
});

final choresProvider = StreamProvider<List<Chore>>((ref) => ref.watch(choresRepoProvider).watchChores());

final choreCompletionsProvider = StreamProvider<List<ChoreCompletion>>(
  (ref) => ref.watch(choresRepoProvider).watchCompletions(),
);

final choreBoardProvider = Provider<ChoreBoard>((ref) {
  final repo = ref.watch(choresRepoProvider);
  return ChoreBoard(
    ref.watch(choresProvider).value ?? const <Chore>[],
    ref.watch(choreCompletionsProvider).value ?? const <ChoreCompletion>[],
    repo.today,
    me: ref.watch(authProvider).session?.active.memberId,
  );
});
