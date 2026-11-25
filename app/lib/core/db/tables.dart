import 'package:drift/drift.dart';

/// Columns every synced table carries (docs/sync-protocol.md §2).
///
/// Drift turns the getter names into snake_case column names, so they match
/// the server's field names exactly; the sync engine relies on that.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get hlc => text().nullable()();
  IntColumn get serverVersion => integer().nullable()();
  TextColumn get updatedBy => text().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ------------------------------------------------------------ synced tables
// Same reference tables as the API (api/config/homesync.php). Modules extend
// them in Phase 1.

class Members extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get color => text().nullable()();
  TextColumn get pinHash => text().nullable()();
  IntColumn get userId => integer().nullable()();
}

class GroceryItems extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get quantityText => text().nullable()();
  TextColumn get store => text().nullable()();
  BoolColumn get isBought => boolean().withDefault(const Constant(false))();
  DateTimeColumn get boughtAt => dateTime().nullable()();
  TextColumn get requestedBy => text().nullable()();
  TextColumn get note => text().nullable()();
}

class PantryItems extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get unit => text().nullable()();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  RealColumn get minQuantity => real().nullable()();
  TextColumn get location => text().nullable()();

  /// Calendar date `YYYY-MM-DD`, kept as text so time zones never shift it.
  TextColumn get expiresOn => text().nullable()();
}

class Bills extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get provider => text().nullable()();
  IntColumn get amountMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get dueOn => text().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();
}

/// The money ledger. Append-only: only `note` and deletion change later.
@DataClassName('LedgerEntry')
class Transactions extends Table with SyncColumns {
  TextColumn get accountId => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get memberId => text().nullable()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get sourceId => text().nullable()();
  TextColumn get note => text().nullable()();
}

// ------------------------------------------------------------- sync tables

/// Local changes waiting to be pushed (sync-protocol §3).
@DataClassName('OutboxOp')
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get opId => text().unique()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();

  /// insert, update, delete or increment.
  TextColumn get op => text()();

  /// JSON object in wire format.
  TextColumn get fields => text()();
  TextColumn get hlc => text()();
  IntColumn get baseVersion => integer().nullable()();

  /// Set when a push containing this op starts. A sending op is never merged
  /// with later edits: the server may already have applied it.
  BoolColumn get sending => boolean().withDefault(const Constant(false))();

  /// Profile that made the change. On the shared tablet each PIN profile is
  /// its own device with its own token, and the op must be pushed with it:
  /// the server takes `updated_by` from the token.
  TextColumn get memberId => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
}

/// Per-field clock of the last change this device knows about.
class FieldClocks extends Table {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get hlc => text()();

  @override
  Set<Column> get primaryKey => {entity, entityId, field};
}

/// Small key/value store: pull cursor, last synced time, clock state.
@DataClassName('SyncStateEntry')
class SyncState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Ops the server rejected, kept so the user can see what didn't sync.
class SyncErrors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get opId => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get op => text()();
  TextColumn get fields => text()();
  TextColumn get error => text()();
  TextColumn get details => text().nullable()();
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
}
