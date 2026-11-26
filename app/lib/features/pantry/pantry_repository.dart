import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';

enum Expiry { none, soon, expired }

/// Days ahead that count as "expires soon".
const expirySoonDays = 7;

/// Pantry & Grocery data. Reads the local database; writes go through
/// [LocalWriter] so they sync. `is_bought` is forward-only on the hub and
/// pantry `quantity` is a counter (changed by increments only).
class PantryRepository {
  PantryRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  // ---------------------------------------------------------------- grocery

  /// Items still to buy, grouped by store (no store last), then by name.
  Stream<List<GroceryItem>> watchToBuy() => _toBuy().watch();

  /// Bought items not cleared yet, newest first.
  Stream<List<GroceryItem>> watchBought() => _bought().watch();

  SimpleSelectStatement<$GroceryItemsTable, GroceryItem> _toBuy() => db.select(db.groceryItems)
    ..where((g) => g.deletedAt.isNull() & g.isBought.equals(false))
    ..orderBy([
      (g) => OrderingTerm(expression: g.store.isNull()),
      (g) => OrderingTerm(expression: g.store.lower()),
      (g) => OrderingTerm(expression: g.name.lower()),
    ]);

  SimpleSelectStatement<$GroceryItemsTable, GroceryItem> _bought() => db.select(db.groceryItems)
    ..where((g) => g.deletedAt.isNull() & g.isBought.equals(true))
    ..orderBy([(g) => OrderingTerm.desc(g.boughtAt)]);

  Future<String> addGrocery(String name, {String? quantityText, String? store, String? note}) =>
      writer.insert('grocery_items', {
        'name': name.trim(),
        'quantity_text': _blankToNull(quantityText),
        'store': _blankToNull(store),
        'note': _blankToNull(note),
        'is_bought': false,
        'requested_by': writer.identity.memberId,
      });

  Future<void> setBought(String id, bool bought) =>
      writer.update('grocery_items', id, {'is_bought': bought, 'bought_at': bought ? _now().toUtc() : null});

  Future<void> editGrocery(
    GroceryItem item, {
    required String name,
    String? quantityText,
    String? store,
    String? note,
  }) {
    final next = {
      'name': name.trim(),
      'quantity_text': _blankToNull(quantityText),
      'store': _blankToNull(store),
      'note': _blankToNull(note),
    };
    final current = {'name': item.name, 'quantity_text': item.quantityText, 'store': item.store, 'note': item.note};
    next.removeWhere((k, v) => current[k] == v);
    return writer.update('grocery_items', item.id, next);
  }

  Future<void> removeGrocery(String id) => writer.delete('grocery_items', id);

  /// Clears the bought list (tombstones). Returns how many were cleared.
  Future<int> clearBought() async {
    final bought = await _bought().get();
    for (final g in bought) {
      await writer.delete('grocery_items', g.id);
    }
    return bought.length;
  }

  // ----------------------------------------------------------------- pantry

  /// Pantry items: running low first, then expiring, then by name.
  Stream<List<PantryItem>> watchPantry() =>
      (db.select(db.pantryItems)..where((p) => p.deletedAt.isNull())).watch().map((items) {
        final today = _now();
        int rank(PantryItem p) => isLow(p) ? 0 : (expiryOf(p, today) != Expiry.none ? 1 : 2);
        return [...items]..sort((a, b) {
          final r = rank(a).compareTo(rank(b));
          if (r != 0) return r;
          final e = (a.expiresOn ?? '9999').compareTo(b.expiresOn ?? '9999');
          return e != 0 ? e : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      });

  Future<String> addPantry({
    required String name,
    String? unit,
    double quantity = 0,
    double? minQuantity,
    String? location,
    String? expiresOn,
  }) => writer.insert('pantry_items', {
    'name': name.trim(),
    'unit': _blankToNull(unit),
    'quantity': quantity,
    'min_quantity': minQuantity,
    'location': _blankToNull(location),
    'expires_on': expiresOn,
  });

  /// Adds or uses up stock. Increments merge across offline devices.
  Future<void> adjust(String id, double delta) => writer.increment('pantry_items', id, {'quantity': delta});

  /// Sets the count after a stock-take, sent as the difference so that
  /// changes made elsewhere meanwhile are kept.
  Future<void> setQuantity(PantryItem item, double quantity) async {
    final delta = quantity - item.quantity;
    if (delta != 0) await adjust(item.id, delta);
  }

  Future<void> editPantry(
    PantryItem item, {
    required String name,
    String? unit,
    double? minQuantity,
    String? location,
    String? expiresOn,
  }) {
    final next = {
      'name': name.trim(),
      'unit': _blankToNull(unit),
      'min_quantity': minQuantity,
      'location': _blankToNull(location),
      'expires_on': expiresOn,
    };
    final current = {
      'name': item.name,
      'unit': item.unit,
      'min_quantity': item.minQuantity,
      'location': item.location,
      'expires_on': item.expiresOn,
    };
    next.removeWhere((k, v) => current[k] == v);
    return writer.update('pantry_items', item.id, next);
  }

  Future<void> removePantry(String id) => writer.delete('pantry_items', id);

  /// Puts a pantry item on the grocery list unless it is already there
  /// (same name, not bought). Returns false when it was already listed.
  Future<bool> addToGrocery(PantryItem item) async {
    final open = await _toBuy().get();
    final name = item.name.trim().toLowerCase();
    if (open.any((g) => g.name.trim().toLowerCase() == name)) return false;
    await addGrocery(item.name);
    return true;
  }

  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}

/// At or below its minimum (only when a minimum is set).
bool isLow(PantryItem p) => p.minQuantity != null && p.quantity <= p.minQuantity!;

Expiry expiryOf(PantryItem p, DateTime today) {
  final on = p.expiresOn == null ? null : DateTime.tryParse(p.expiresOn!);
  if (on == null) return Expiry.none;
  final days = daysUntil(on, today);
  if (days < 0) return Expiry.expired;
  return days <= expirySoonDays ? Expiry.soon : Expiry.none;
}

/// Whole calendar days from [today] to [date] (negative when past).
int daysUntil(DateTime date, DateTime today) =>
    DateTime.utc(date.year, date.month, date.day).difference(DateTime.utc(today.year, today.month, today.day)).inDays;

/// `YYYY-MM-DD` for a picked date.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 2.0 -> "2", 1.5 -> "1.5".
String formatQuantity(double q) {
  if (q == q.roundToDouble()) return q.toInt().toString();
  return q.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
