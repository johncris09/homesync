import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/hlc.dart';
import 'package:homesync/core/sync/outbox.dart';

const householdId = '01900000-0000-7000-8000-000000000001';

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

SyncIdentity identity({required String memberId, required String deviceId}) =>
    SyncIdentity(householdId: householdId, memberId: memberId, deviceId: deviceId);

LocalWriter writer(AppDatabase db, SyncIdentity id, {int Function()? now}) =>
    LocalWriter(db: db, identity: id, clock: HlcClock(deviceId: id.deviceId, now: now));

/// Reads a synced row as a plain map (column name -> raw SQL value).
Future<Map<String, Object?>?> rawRow(AppDatabase db, String table, String id) async {
  final row = await db
      .customSelect('SELECT * FROM "$table" WHERE id = ?', variables: [Variable<String>(id)])
      .getSingleOrNull();
  return row?.data;
}
