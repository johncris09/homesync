import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'inventory_repository.dart';

final inventoryRepoProvider = Provider<InventoryRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return InventoryRepository(s.db, s.writer, files: s.vaultFiles);
});

/// Everyone sees the inventory; adults add and change it and see prices
/// (`write` in api/config/homesync.php).
final canEditInventoryProvider = Provider<bool>((ref) => ref.watch(authProvider).session?.active.isAdult ?? false);

final inventoryItemsProvider = StreamProvider<List<InventoryItem>>(
  (ref) => ref.watch(inventoryRepoProvider).watchItems(),
);

final inventoryItemProvider = StreamProvider.family<InventoryItem?, String>(
  (ref, id) => ref.watch(inventoryRepoProvider).watchItem(id),
);

final inventorySummaryProvider = Provider<InventorySummary>(
  (ref) => InventorySummary(
    ref.watch(inventoryItemsProvider).value ?? const <InventoryItem>[],
    ref.watch(inventoryRepoProvider).today,
  ),
);

/// A photo's bytes by SHA-256 (kept once loaded).
final inventoryPhotoProvider = FutureProvider.family<Uint8List?, String>(
  (ref, sha) => ref.watch(inventoryRepoProvider).readPhoto(sha),
);
