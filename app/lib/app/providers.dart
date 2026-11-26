import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_services.dart';
import '../core/auth/app_lock.dart';
import '../core/auth/auth_service.dart';
import '../core/db/database.dart';
import '../core/sync/sync_scheduler.dart';
import '../core/sync/sync_state_store.dart';
import '../core/sync/sync_status_repository.dart';

/// Overridden in main() with the opened services.
final servicesProvider = Provider<AppServices>((ref) => throw UnimplementedError('override servicesProvider'));

final authProvider = ChangeNotifierProvider<AuthService>((ref) => ref.watch(servicesProvider).auth);
final appLockProvider = ChangeNotifierProvider<AppLock>((ref) => ref.watch(servicesProvider).appLock);

final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final scheduler = ref.watch(servicesProvider).scheduler;
  yield scheduler.status;
  yield* scheduler.statusStream;
});

final lastSyncedProvider = StreamProvider<DateTime?>(
  (ref) => SyncStateStore(ref.watch(servicesProvider).db).watchLastSyncedAt(),
);

/// Release version the hub last reported; null until it has answered once.
final hubVersionProvider = StreamProvider<String?>(
  (ref) => SyncStateStore(ref.watch(servicesProvider).db).watchHubVersion(),
);

final syncStatusRepoProvider = Provider<SyncStatusRepository>(
  (ref) => SyncStatusRepository(ref.watch(servicesProvider).db),
);

final conflictInboxProvider = Provider<ConflictInbox>((ref) => ConflictInbox(ref.watch(servicesProvider).writer));

final pendingCountProvider = StreamProvider<int>((ref) => ref.watch(syncStatusRepoProvider).watchPendingCount());
final openConflictsProvider = StreamProvider<List<ConflictRecord>>(
  (ref) => ref.watch(syncStatusRepoProvider).watchOpenConflicts(),
);
final syncErrorsProvider = StreamProvider<List<SyncError>>((ref) => ref.watch(syncStatusRepoProvider).watchErrors());

/// Per-record markers: ids of an entity with pending changes / open conflicts.
final pendingIdsProvider = StreamProvider.family<Set<String>, String>(
  (ref, entity) => ref.watch(syncStatusRepoProvider).watchPendingIds(entity),
);
final conflictIdsProvider = StreamProvider.family<Set<String>, String>(
  (ref, entity) => ref.watch(syncStatusRepoProvider).watchConflictIds(entity),
);

/// Current household members (for profile picker and "who changed it").
final membersProvider = StreamProvider<List<Member>>((ref) {
  final db = ref.watch(servicesProvider).db;
  return (db.select(db.members)
        ..where((m) => m.deletedAt.isNull())
        ..orderBy([(m) => OrderingTerm.asc(m.name)]))
      .watch();
});
