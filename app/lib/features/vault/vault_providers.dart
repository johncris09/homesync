import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/vault/vault_session.dart';
import 'vault_repository.dart';

final vaultRepoProvider = Provider<VaultRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return VaultRepository(db: s.db, writer: s.writer, session: s.vault, crypto: s.vaultCrypto, files: s.vaultFiles);
});

final vaultSessionProvider = ChangeNotifierProvider<VaultSession>((ref) => ref.watch(servicesProvider).vault);

/// The vault is for the owner and adults (`read` in api/config/homesync.php).
final canSeeVaultProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

/// Only the owner sets up the vault, changes its passphrase and settles
/// vault conflicts.
final isVaultOwnerProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.role == 'owner');

/// Whether this device may keep the vault key after unlocking: an Android
/// phone (not the shared tablet) with app lock on (docs/vault.md).
final vaultMayKeepKeyProvider = Provider<bool>((ref) {
  final session = ref.watch(authProvider).session;
  return !kIsWeb && ref.watch(appLockProvider).enabled && !(session?.isShared ?? true);
});

final vaultKeyRowProvider = StreamProvider<VaultKey?>((ref) => ref.watch(vaultRepoProvider).watchKeyRow());

/// Documents without opening them: enough for counts and expiry while locked.
final vaultItemsProvider = StreamProvider<List<VaultItem>>((ref) => ref.watch(vaultRepoProvider).watchItems());

/// Documents opened with the vault key; empty while locked.
final vaultDocsProvider = FutureProvider<List<VaultDoc>>((ref) async {
  final unlocked = ref.watch(vaultSessionProvider.select((s) => s.unlocked));
  final items = ref.watch(vaultItemsProvider).value ?? const <VaultItem>[];
  if (!unlocked) return const [];
  return ref.watch(vaultRepoProvider).openAll(items);
});

final vaultDocProvider = FutureProvider.family<VaultDoc?, String>((ref, id) async {
  final unlocked = ref.watch(vaultSessionProvider.select((s) => s.unlocked));
  final item = await ref.watch(_vaultItemProvider(id).future);
  if (item == null || !unlocked) return null;
  return VaultDoc(item, await ref.watch(vaultRepoProvider).openFields(item.id, item.sealed));
});

final _vaultItemProvider = StreamProvider.family<VaultItem?, String>(
  (ref, id) => ref.watch(vaultRepoProvider).watchItem(id),
);

final _vaultFileRowsProvider = StreamProvider.family<List<VaultFile>, String>(
  (ref, itemId) => ref.watch(vaultRepoProvider).watchFiles(itemId),
);

final vaultFilesProvider = FutureProvider.family<List<VaultFileMeta>, String>((ref, itemId) async {
  final unlocked = ref.watch(vaultSessionProvider.select((s) => s.unlocked));
  final rows = await ref.watch(_vaultFileRowsProvider(itemId).future);
  if (!unlocked) return const [];
  return ref.watch(vaultRepoProvider).openMeta(rows);
});

/// Open conflicts on a document (never auto-merged, sync-protocol §6).
final vaultConflictsProvider = StreamProvider.family<List<ConflictRecord>, String>((ref, itemId) {
  final db = ref.watch(servicesProvider).db;
  return (db.select(db.conflicts)
        ..where(
          (c) =>
              c.entity.equals('vault_items') & c.entityId.equals(itemId) & c.resolvedAt.isNull() & c.deletedAt.isNull(),
        )
        ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
      .watch();
});
