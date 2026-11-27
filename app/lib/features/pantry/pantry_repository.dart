import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';

export '../../shared/dates.dart';

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

  /// Every bought item still kept (cleared or not), newest first. Feeds the
  /// history screen; group it with [groupByDay].
  Stream<List<GroceryItem>> watchHistory() =>
      (db.select(db.groceryItems)
            ..where((g) => g.deletedAt.isNull() & g.isBought.equals(true))
            ..orderBy([(g) => OrderingTerm.desc(g.boughtAt), (g) => OrderingTerm.asc(g.name)]))
          .watch();

  SimpleSelectStatement<$GroceryItemsTable, GroceryItem> _toBuy() => db.select(db.groceryItems)
    ..where((g) => g.deletedAt.isNull() & g.isBought.equals(false))
    ..orderBy([
      (g) => OrderingTerm(expression: g.store.isNull()),
      (g) => OrderingTerm(expression: g.store.lower()),
      (g) => OrderingTerm(expression: g.name.lower()),
    ]);

  SimpleSelectStatement<$GroceryItemsTable, GroceryItem> _bought() => db.select(db.groceryItems)
    ..where((g) => g.deletedAt.isNull() & g.isBought.equals(true) & g.clearedAt.isNull())
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

  /// Ticks an item off with today's date (or puts it back on the list).
  /// Either way it is no longer cleared, so it shows on the list again.
  Future<void> setBought(String id, bool bought) => writer.update('grocery_items', id, {
    'is_bought': bought,
    'bought_at': bought ? _now().toUtc() : null,
    'cleared_at': null,
  });

  /// Changes the day an item was bought, keeping the time of day it was
  /// ticked (so items bought together stay in the same order).
  Future<void> setBoughtOn(GroceryItem item, DateTime day) {
    final at = (item.boughtAt ?? _now()).toLocal();
    final next = DateTime(day.year, day.month, day.day, at.hour, at.minute, at.second, at.millisecond);
    return writer.update('grocery_items', item.id, {'bought_at': next.toUtc()});
  }

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

  /// Clears the bought list. The items are kept (with `cleared_at`) for the
  /// history screen. Returns how many were cleared.
  Future<int> clearBought() async {
    final bought = await _bought().get();
    final at = _now().toUtc();
    for (final g in bought) {
      await writer.update('grocery_items', g.id, {'cleared_at': at});
    }
    return bought.length;
  }

  /// Puts a past item back on the list (name, quantity and store) unless the
  /// same name is already on it. Returns false when it was already listed.
  Future<bool> buyAgain(GroceryItem item) async {
    if (await _isListed(item.name)) return false;
    await addGrocery(item.name, quantityText: item.quantityText, store: item.store);
    return true;
  }

  Future<bool> _isListed(String name) async {
    final key = name.trim().toLowerCase();
    return (await _toBuy().get()).any((g) => g.name.trim().toLowerCase() == key);
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
    if (await _isListed(item.name)) return false;
    await addGrocery(item.name);
    return true;
  }

  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}

/// Bought items grouped by the local day they were bought, keeping the
/// order given (newest day first for [PantryRepository.watchHistory]).
List<({DateTime day, List<GroceryItem> items})> groupByDay(List<GroceryItem> items) {
  final groups = <({DateTime day, List<GroceryItem> items})>[];
  for (final g in items) {
    final at = (g.boughtAt ?? g.updatedAt).toLocal();
    final day = DateTime(at.year, at.month, at.day);
    if (groups.isNotEmpty && groups.last.day == day) {
      groups.last.items.add(g);
    } else {
      groups.add((day: day, items: [g]));
    }
  }
  return groups;
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

/// 2.0 -> "2", 1.5 -> "1.5".
String formatQuantity(double q) {
  if (q == q.roundToDouble()) return q.toInt().toString();
  return q.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
