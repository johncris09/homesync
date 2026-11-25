import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'codec.dart';
import 'entities.dart';
import 'hlc.dart';
import 'sync_state_store.dart';

/// Who is writing: every local change is stamped with these.
class SyncIdentity {
  const SyncIdentity({
    required this.householdId,
    required this.memberId,
    required this.deviceId,
  });

  final String householdId;
  final String memberId;
  final String deviceId;
}

/// The only way features change synced data (sync-protocol §1.3).
///
/// Each call updates the row **and** appends an op to the outbox in one
/// transaction. Repeated edits to one record before a push are folded into a
/// single op: latest value per field, increments summed.
///
/// Field maps use wire names (`is_bought`) and Dart values (`bool`,
/// `DateTime`, `int`...).
class LocalWriter {
  LocalWriter({
    required this.db,
    required SyncIdentity identity,
    required this.clock,
    this.onWrite,
    DateTime Function()? now,
  }) : identity = identity,
       _state = SyncStateStore(db),
       _now = now ?? DateTime.now;

  final AppDatabase db;
  /// Current profile. Switched when a PIN profile takes over the tablet;
  /// each write is stamped with the profile active when it started.
  SyncIdentity identity;
  final HlcClock clock;

  /// Called after each committed write (the sync scheduler debounces it).
  final void Function()? onWrite;

  final SyncStateStore _state;
  final DateTime Function() _now;
  static const _uuid = Uuid();

  /// Inserts a record and returns its new UUIDv7 id.
  Future<String> insert(String entity, Map<String, Object?> fields, {String? id}) async {
    final spec = specFor(entity);
    _checkFields(spec, fields.keys);
    final entityId = id ?? _uuid.v7();

    await _write(entity, entityId, (table, hlc, now, who) async {
      await SyncCodec.insert(db, table, {
        ...fields,
        'id': entityId,
        'household_id': who.householdId,
        'created_at': now,
        ..._stamp(hlc, now, who),
      });
      await _enqueue(who, spec, entityId, 'insert', fields, hlc, null);
      await _setClocks(entity, entityId, fields.keys.where((f) => !spec.counters.contains(f)), hlc);
    });
    return entityId;
  }

  Future<void> update(String entity, String id, Map<String, Object?> fields) async {
    final spec = specFor(entity);
    _checkFields(spec, fields.keys);
    for (final f in fields.keys) {
      if (spec.counters.contains(f)) {
        throw ArgumentError('$entity.$f is a counter: use increment()');
      }
      if (!spec.canUpdate(f)) {
        throw ArgumentError('$entity is append-only: $f cannot change');
      }
    }
    if (fields.isEmpty) return;

    await _write(entity, id, (table, hlc, now, who) async {
      final base = await _serverVersion(table, id);
      await _updateRow(table, id, {...fields, ..._stamp(hlc, now, who)});
      await _enqueue(who, spec, id, 'update', fields, hlc, base);
      await _setClocks(entity, id, fields.keys, hlc);
    });
  }

  /// Adds signed [deltas] to counter fields, e.g. `{'quantity': -1}`.
  Future<void> increment(String entity, String id, Map<String, num> deltas) async {
    final spec = specFor(entity);
    for (final f in deltas.keys) {
      if (!spec.counters.contains(f)) throw ArgumentError('$entity.$f is not a counter');
    }
    if (deltas.isEmpty) return;

    await _write(entity, id, (table, hlc, now, who) async {
      final base = await _serverVersion(table, id);
      final sets = deltas.keys.map((f) => '"$f" = "$f" + ?').join(', ');
      await db.customUpdate(
        'UPDATE "${table.actualTableName}" SET $sets WHERE id = ?',
        variables: [...deltas.values.map((d) => Variable<double>(d.toDouble())), Variable<String>(id)],
        updates: {table},
      );
      await _updateRow(table, id, _stamp(hlc, now, who));
      await _enqueue(who, spec, id, 'increment', deltas, hlc, base);
    });
  }

  /// Soft delete (tombstone).
  Future<void> delete(String entity, String id) async {
    final spec = specFor(entity);
    await _write(entity, id, (table, hlc, now, who) async {
      final base = await _serverVersion(table, id);
      await _updateRow(table, id, {'deleted_at': now, ..._stamp(hlc, now, who)});
      await _enqueue(who, spec, id, 'delete', {'deleted_at': now}, hlc, base);
      await _setClocks(entity, id, const ['deleted_at'], hlc);
    });
  }

  // ------------------------------------------------------------- internals

  Future<void> _write(
    String entity,
    String id,
    Future<void> Function(TableInfo<Table, dynamic> table, Hlc hlc, DateTime now, SyncIdentity who) body,
  ) async {
    final table = db.syncedTable(entity)!;
    final who = identity;
    await db.transaction(() async {
      final hlc = clock.tick();
      await body(table, hlc, _now().toUtc(), who);
      await _state.saveClock(clock);
    });
    onWrite?.call();
  }

  Map<String, Object?> _stamp(Hlc hlc, DateTime now, SyncIdentity who) => {
    'updated_at': now,
    'hlc': hlc.toString(),
    'updated_by': who.memberId,
    'device_id': who.deviceId,
  };

  void _checkFields(EntitySpec spec, Iterable<String> fields) {
    for (final f in fields) {
      if (!spec.fields.contains(f)) {
        throw ArgumentError('${spec.name}.$f is not a writable field');
      }
    }
  }

  Future<int?> _serverVersion(TableInfo<Table, dynamic> table, String id) async {
    final row = await db
        .customSelect(
          'SELECT server_version FROM "${table.actualTableName}" WHERE id = ?',
          variables: [Variable<String>(id)],
          readsFrom: {table},
        )
        .getSingleOrNull();
    if (row == null) throw StateError('${table.actualTableName}/$id not found');
    return row.read<int?>('server_version');
  }

  Future<void> _updateRow(TableInfo<Table, dynamic> table, String id, Map<String, Object?> values) async {
    await SyncCodec.update(db, table, id, values);
  }

  Future<void> _setClocks(String entity, String id, Iterable<String> fields, Hlc hlc) async {
    for (final f in fields) {
      await db.into(db.fieldClocks).insertOnConflictUpdate(
        FieldClocksCompanion.insert(entity: entity, entityId: id, field: f, hlc: hlc.toString()),
      );
    }
  }

  Future<void> _enqueue(
    SyncIdentity who,
    EntitySpec spec,
    String entityId,
    String op,
    Map<String, Object?> fields,
    Hlc hlc,
    int? baseVersion,
  ) async {
    final wire = fields.map((k, v) => MapEntry(k, SyncCodec.toWire(v)));
    final latest = await (db.select(db.outbox)
          ..where((o) => o.entity.equals(spec.name) & o.entityId.equals(entityId))
          ..orderBy([(o) => OrderingTerm.desc(o.seq)])
          ..limit(1))
        .getSingleOrNull();

    if (latest != null && !latest.sending && latest.deviceId == who.deviceId) {
      final merged = mergeOps(
        latest.op,
        (jsonDecode(latest.fields) as Map).cast<String, Object?>(),
        op,
        wire,
      );
      if (merged != null) {
        await (db.update(db.outbox)..where((o) => o.seq.equals(latest.seq))).write(
          OutboxCompanion(
            op: Value(merged.op),
            fields: Value(jsonEncode(merged.fields)),
            hlc: Value(hlc.toString()),
          ),
        );
        return;
      }
    }

    await db.into(db.outbox).insert(
      OutboxCompanion.insert(
        opId: _uuid.v7(),
        entity: spec.name,
        entityId: entityId,
        op: op,
        fields: jsonEncode(wire),
        hlc: hlc.toString(),
        baseVersion: Value(baseVersion),
        memberId: who.memberId,
        deviceId: who.deviceId,
      ),
    );
  }
}

/// Folds a new op into the newest pending op for the same record, or returns
/// null when they must stay separate. Exposed for tests.
({String op, Map<String, Object?> fields})? mergeOps(
  String oldOp,
  Map<String, Object?> oldFields,
  String newOp,
  Map<String, Object?> newFields,
) {
  switch ((oldOp, newOp)) {
    case ('insert', 'update'):
    case ('update', 'update'):
      return (op: oldOp, fields: {...oldFields, ...newFields});
    case ('insert', 'increment'):
      final out = {...oldFields};
      newFields.forEach((f, d) => out[f] = ((out[f] as num?) ?? 0) + (d as num));
      return (op: 'insert', fields: out);
    case ('increment', 'increment'):
      final out = {...oldFields};
      newFields.forEach((f, d) => out[f] = ((out[f] as num?) ?? 0) + (d as num));
      return (op: 'increment', fields: out);
    default:
      return null;
  }
}
