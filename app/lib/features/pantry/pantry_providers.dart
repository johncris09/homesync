import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import 'pantry_repository.dart';

final pantryRepoProvider = Provider<PantryRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return PantryRepository(s.db, s.writer);
});

final toBuyProvider = StreamProvider<List<GroceryItem>>((ref) => ref.watch(pantryRepoProvider).watchToBuy());
final boughtProvider = StreamProvider<List<GroceryItem>>((ref) => ref.watch(pantryRepoProvider).watchBought());
final pantryItemsProvider = StreamProvider<List<PantryItem>>((ref) => ref.watch(pantryRepoProvider).watchPantry());

/// Everyone in the household may change the list and the pantry, except
/// viewers (matches `write` for both entities in api/config/homesync.php).
final canEditPantryProvider = Provider<bool>((ref) {
  final role = ref.watch(authProvider).session?.active.role;
  return role != null && role != 'viewer';
});
