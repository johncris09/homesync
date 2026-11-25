import '../db/database.dart';
import 'hlc.dart';

/// Typed access to the `sync_state` key/value table.
class SyncStateStore {
  SyncStateStore(this._db);

  final AppDatabase _db;

  static const _cursor = 'cursor';
  static const _lastSyncedAt = 'last_synced_at';
  static const _hlcLast = 'hlc_last';
  static const _hlcSkew = 'hlc_skew_ms';

  Future<String?> read(String key) async {
    final row = await (_db.select(_db.syncState)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) => _db
      .into(_db.syncState)
      .insertOnConflictUpdate(SyncStateCompanion.insert(key: key, value: value));

  Future<int> cursor() async => int.tryParse(await read(_cursor) ?? '') ?? 0;

  Future<void> setCursor(int cursor) => write(_cursor, '$cursor');

  Future<DateTime?> lastSyncedAt() async =>
      DateTime.tryParse(await read(_lastSyncedAt) ?? '');

  Future<void> setLastSyncedAt(DateTime at) =>
      write(_lastSyncedAt, at.toUtc().toIso8601String());

  Stream<DateTime?> watchLastSyncedAt() =>
      (_db.select(_db.syncState)..where((t) => t.key.equals(_lastSyncedAt)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : DateTime.tryParse(row.value));

  Future<HlcClock> loadClock(String deviceId, {int Function()? now}) async {
    return HlcClock(
      deviceId: deviceId,
      last: Hlc.tryParse(await read(_hlcLast)),
      skewMs: int.tryParse(await read(_hlcSkew) ?? '') ?? 0,
      now: now,
    );
  }

  Future<void> saveClock(HlcClock clock) async {
    final last = clock.last;
    if (last != null) await write(_hlcLast, last.toString());
    await write(_hlcSkew, '${clock.skewMs}');
  }
}
