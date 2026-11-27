import 'package:cryptography/cryptography.dart' show Sha256;
import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../core/vault/vault_files_api.dart';
import '../../shared/dates.dart';

/// [InventoryItems.category], in the order the app offers them.
const inventoryCategories = ['appliance', 'electronics', 'furniture', 'tools', 'other'];

/// A warranty ending this close needs attention.
const warrantySoonDays = 30;

/// Largest photo kept (the picker already shrinks it to about 1600 px).
const inventoryPhotoMaxBytes = 5 * 1024 * 1024;

enum Warranty { none, active, soon, ended }

/// Where [item]'s warranty stands on [today].
Warranty warrantyOf(InventoryItem item, DateTime today) {
  final until = parseIsoDate(item.warrantyUntil);
  if (until == null) return Warranty.none;
  final days = daysUntil(until, today);
  if (days < 0) return Warranty.ended;
  if (days <= warrantySoonDays) return Warranty.soon;
  return Warranty.active;
}

/// What an item form fills in. Blank strings mean "not set".
class ItemDraft {
  const ItemDraft({
    required this.name,
    required this.category,
    this.room,
    this.brand,
    this.model,
    this.serialNo,
    this.boughtOn,
    this.priceMinor,
    this.warrantyUntil,
    this.note,
  });

  factory ItemDraft.of(InventoryItem i) => ItemDraft(
    name: i.name,
    category: i.category,
    room: i.room,
    brand: i.brand,
    model: i.model,
    serialNo: i.serialNo,
    boughtOn: parseIsoDate(i.boughtOn),
    priceMinor: i.priceMinor,
    warrantyUntil: parseIsoDate(i.warrantyUntil),
    note: i.note,
  );

  final String name;
  final String category;
  final String? room;
  final String? brand;
  final String? model;
  final String? serialNo;
  final DateTime? boughtOn;
  final int? priceMinor;
  final DateTime? warrantyUntil;
  final String? note;

  Map<String, Object?> toWire() => {
    'name': name.trim(),
    'category': category,
    'room': _blankToNull(room),
    'brand': _blankToNull(brand),
    'model': _blankToNull(model),
    'serial_no': _blankToNull(serialNo),
    'bought_on': boughtOn == null ? null : isoDate(boughtOn!),
    'price_minor': priceMinor,
    'warranty_until': warrantyUntil == null ? null : isoDate(warrantyUntil!),
    'note': _blankToNull(note),
  };
}

/// The screen's view of the inventory: items by room, and what needs
/// attention (warranty ending within [warrantySoonDays] or lent out).
class InventorySummary {
  InventorySummary(List<InventoryItem> items, this.today) : items = [...items]..sort(_byName);

  final List<InventoryItem> items;
  final DateTime today;

  bool get isEmpty => items.isEmpty;
  int get count => items.length;

  /// What everything cost (items with a price).
  int get totalValue => items.fold(0, (sum, i) => sum + (i.priceMinor ?? 0));

  /// Warranties ending soon (soonest first), then things lent out (longest out first).
  List<InventoryItem> get needsAttention {
    final soon = items.where((i) => warrantyOf(i, today) == Warranty.soon).toList()
      ..sort((a, b) => a.warrantyUntil!.compareTo(b.warrantyUntil!));
    final lent = items.where((i) => i.lentTo != null && !soon.contains(i)).toList()
      ..sort((a, b) => (a.lentOn ?? '').compareTo(b.lentOn ?? ''));
    return [...soon, ...lent];
  }

  /// Rooms in name order with their items; items with no room come last
  /// under the key `''`. [query] matches name, brand, model, serial, room and
  /// who borrowed it.
  List<(String, List<InventoryItem>)> byRoom({String query = ''}) {
    final q = query.trim().toLowerCase();
    final groups = <String, List<InventoryItem>>{};
    for (final i in items) {
      if (q.isNotEmpty && !_matches(i, q)) continue;
      (groups[i.room?.trim() ?? ''] ??= []).add(i);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty != b.isEmpty) return a.isEmpty ? 1 : -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return [for (final k in keys) (k, groups[k]!)];
  }

  /// Room names already used, for the room picker.
  List<String> get rooms =>
      {for (final i in items) ?i.room?.trim()}.where((r) => r.isNotEmpty).toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  static bool _matches(InventoryItem i, String q) =>
      [i.name, i.brand, i.model, i.serialNo, i.room, i.lentTo].any((f) => f != null && f.toLowerCase().contains(q));

  static int _byName(InventoryItem a, InventoryItem b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
}

/// Household Inventory. Photos are plain JPEGs kept in [VaultBlobs] and
/// uploaded after sync by the same uploader as vault files (sync-protocol §7).
class InventoryRepository {
  InventoryRepository(this.db, this.writer, {this.files, DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;

  /// Downloads photos added on other devices; null in tests that don't need it.
  final VaultFilesApi? files;
  final DateTime Function() _now;

  DateTime get today => _now();

  Stream<List<InventoryItem>> watchItems() =>
      (db.select(db.inventoryItems)..where((i) => i.deletedAt.isNull())).watch();

  Stream<InventoryItem?> watchItem(String id) =>
      (db.select(db.inventoryItems)..where((i) => i.id.equals(id) & i.deletedAt.isNull())).watchSingleOrNull();

  Future<String> add(ItemDraft d) => writer.insert('inventory_items', {...d.toWire(), 'currency': 'PHP'});

  /// Sends only the fields that changed.
  Future<void> edit(InventoryItem item, ItemDraft d) async {
    final before = ItemDraft.of(item).toWire();
    final after = d.toWire();
    final changed = {
      for (final e in after.entries)
        if (before[e.key] != e.value) e.key: e.value,
    };
    if (changed.isEmpty) return;
    await writer.update('inventory_items', item.id, changed);
  }

  Future<void> remove(String id) => writer.delete('inventory_items', id);

  Future<void> lend(InventoryItem item, String to, {DateTime? on}) =>
      writer.update('inventory_items', item.id, {'lent_to': to.trim(), 'lent_on': isoDate(on ?? today)});

  Future<void> returned(InventoryItem item) =>
      writer.update('inventory_items', item.id, {'lent_to': null, 'lent_on': null});

  /// Keeps [bytes] on this device until the next sync uploads them.
  Future<void> setPhoto(InventoryItem item, Uint8List bytes) async {
    if (bytes.length > inventoryPhotoMaxBytes) throw const PhotoTooBig();
    final sha = await sha256Hex(bytes);
    await db
        .into(db.vaultBlobs)
        .insertOnConflictUpdate(VaultBlobsCompanion.insert(sha256: sha, data: bytes, needsUpload: const Value(true)));
    await writer.update('inventory_items', item.id, {'photo_sha256': sha, 'photo_size': bytes.length});
  }

  Future<void> removePhoto(InventoryItem item) =>
      writer.update('inventory_items', item.id, {'photo_sha256': null, 'photo_size': null});

  /// The photo's bytes, from this device or the hub. Null when there is no
  /// photo, the hub can't be reached, or the device that took it hasn't
  /// uploaded it yet.
  Future<Uint8List?> readPhoto(String sha) async {
    final blob = await (db.select(db.vaultBlobs)..where((b) => b.sha256.equals(sha))).getSingleOrNull();
    if (blob != null) return blob.data;
    final api = files;
    if (api == null) return null;
    try {
      final bytes = await api.download(sha);
      if (bytes == null || await sha256Hex(bytes) != sha) return null;
      await db.into(db.vaultBlobs).insertOnConflictUpdate(VaultBlobsCompanion.insert(sha256: sha, data: bytes));
      return bytes;
    } on Exception {
      return null;
    }
  }

  static Future<String> sha256Hex(List<int> bytes) async {
    final hash = await Sha256().hash(bytes);
    return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

class PhotoTooBig implements Exception {
  const PhotoTooBig();
}

String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
