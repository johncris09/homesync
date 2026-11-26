import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'codec.dart';
import 'entities.dart';
import 'hlc.dart';
import 'sync_api.dart';
import 'sync_state_store.dart';

class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.rejected,
    required this.pulled,
    this.waitingForDevice,
  });

  final int pushed;
  final int rejected;
  final int pulled;

  /// Profile device whose ops are waiting for a token (see ProfileTokenMissing).
  final String? waitingForDevice;

  @override
  String toString() => 'SyncReport(pushed: $pushed, rejected: $rejected, pulled: $pulled)';
}

/// One sync round: push the whole outbox, then pull every page since the
/// cursor (sync-protocol §1.4). Errors from [SyncApi] propagate to the caller
/// (the scheduler decides about retries); nothing is lost on failure because
/// ops leave the outbox only after the server answered for them.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.api,
    required this.clock,
    this.pushBatchSize = 200,
    this.pullPageSize = 500,
    DateTime Function()? now,
  }) : _state = SyncStateStore(db),
       _now = now ?? DateTime.now;

  final AppDatabase db;
  final SyncApi api;
  final HlcClock clock;
  final int pushBatchSize;
  final int pullPageSize;

  final SyncStateStore _state;
  final DateTime Function() _now;
  Future<SyncReport>? _running;

  /// Runs a sync, or joins the one already running.
  Future<SyncReport> sync() => _running ??= _run().whenComplete(() => _running = null);

  Future<SyncReport> _run() async {
    final (pushed, rejected, waiting) = await _push();
    final pulled = await _pull();
    await _state.setLastSyncedAt(_now());
    return SyncReport(pushed: pushed, rejected: rejected, pulled: pulled, waitingForDevice: waiting);
  }

  // ------------------------------------------------------------------ push

  /// Pushes in outbox order. A batch holds consecutive ops of one profile,
  /// sent with that profile's token.
  Future<(int, int, String?)> _push() async {
    var pushed = 0;
    var rejected = 0;
    // Bounded so a device writing non-stop can't keep one sync alive forever.
    for (var round = 0; round < 50; round++) {
      final batch = await db.transaction(() async {
        final head = await (db.select(db.outbox)
              ..orderBy([(o) => OrderingTerm.asc(o.seq)])
              ..limit(pushBatchSize))
            .get();
        final ops = head.takeWhile((o) => o.deviceId == head.first.deviceId).toList();
        if (ops.isNotEmpty) {
          await (db.update(db.outbox)..where((o) => o.seq.isIn(ops.map((o) => o.seq))))
              .write(const OutboxCompanion(sending: Value(true)));
        }
        return ops;
      });
      if (batch.isEmpty) break;

      final PushResponse response;
      try {
        response = await api.push(batch.first.deviceId, [for (final op in batch) _opJson(op)]);
      } on ProfileTokenMissing catch (e) {
        return (pushed, rejected, e.deviceId);
      }
      final byId = {for (final op in batch) op.opId: op};
      var answered = 0;

      await db.transaction(() async {
        for (final r in response.results) {
          final op = byId[r.opId];
          if (op == null) continue;
          answered++;
          if (r.status == 'rejected') {
            rejected++;
            await db.into(db.syncErrors).insert(
              SyncErrorsCompanion.insert(
                opId: op.opId,
                entity: op.entity,
                entityId: op.entityId,
                op: op.op,
                fields: op.fields,
                error: r.error ?? 'unknown',
                details: Value(r.details == null ? null : jsonEncode(r.details)),
              ),
            );
          } else {
            pushed++;
          }
          // applied / duplicate / merged / rejected all leave the outbox.
          await (db.delete(db.outbox)..where((o) => o.seq.equals(op.seq))).go();
        }
        clock.observeServerTime(response.serverTimeMs);
        await _state.saveClock(clock);
      });

      // A server that answers for none of the ops would loop forever.
      if (answered == 0) throw const SyncUnavailable('push answered no ops');
    }
    return (pushed, rejected, null);
  }

  Map<String, Object?> _opJson(OutboxOp op) => {
    'op_id': op.opId,
    'entity': op.entity,
    'entity_id': op.entityId,
    'op': op.op,
    'fields': jsonDecode(op.fields),
    'hlc': op.hlc,
    if (op.baseVersion != null) 'base_version': op.baseVersion,
  };

  // ------------------------------------------------------------------ pull

  Future<int> _pull() async {
    var pulled = 0;
    var cursor = await _state.cursor();
    // Cursor 0: a new device, or a hub whose change log was empty last time.
    // Rows the hub made itself (the owner from `homesync:setup`) are not in
    // the change log, so start from a snapshot (§5.3).
    if (cursor == 0) {
      final snap = await api.bootstrap();
      await db.transaction(() async {
        for (final MapEntry(key: entity, value: rows) in snap.entities.entries) {
          for (final row in rows) {
            final id = row['id'];
            if (id is! String) continue;
            await _applyRemote(PulledChange(seq: 0, entity: entity, entityId: id, op: 'upsert', row: row));
            pulled++;
          }
        }
        clock.observeServerTime(snap.serverTimeMs);
        await _state.saveClock(clock);
        await _state.setCursor(snap.cursor);
      });
      cursor = snap.cursor;
    }
    while (true) {
      final page = await api.pull(cursor, pullPageSize);
      await db.transaction(() async {
        for (final change in page.changes) {
          await _applyRemote(change);
        }
        clock.observeServerTime(page.serverTimeMs);
        await _state.saveClock(clock);
        await _state.setCursor(page.cursor);
      });
      pulled += page.changes.length;
      cursor = page.cursor;
      if (!page.hasMore) break;
    }
    return pulled;
  }

  /// Upserts the server's merged row, then re-applies this device's ops for
  /// the record that the server hasn't seen yet, so local edits made during
  /// the sync stay visible until they are pushed.
  Future<void> _applyRemote(PulledChange change) async {
    final table = db.syncedTable(change.entity);
    final spec = syncedEntities[change.entity];
    if (table == null || spec == null) return; // entity from a newer server

    final row = Map<String, Object?>.of(change.row);
    for (final f in spec.jsonFields) {
      if (row.containsKey(f)) row[f] = row[f] == null ? null : jsonEncode(row[f]);
    }
    final pending = await (db.select(db.outbox)
          ..where((o) => o.entity.equals(change.entity) & o.entityId.equals(change.entityId))
          ..orderBy([(o) => OrderingTerm.asc(o.seq)]))
        .get();

    final pendingFields = <String>{};
    for (final op in pending) {
      final fields = (jsonDecode(op.fields) as Map).cast<String, Object?>();
      pendingFields.addAll(fields.keys);
      if (op.op == 'increment') {
        fields.forEach((f, d) => row[f] = ((row[f] as num?) ?? 0) + (d as num));
      } else {
        row.addAll(fields);
      }
      row['hlc'] = op.hlc;
    }

    await SyncCodec.insert(db, table, row, replace: true);

    final remote = Hlc.tryParse(change.row['hlc'] as String?);
    if (remote == null) return;
    clock.receive(remote);
    for (final field in [...spec.fields, 'deleted_at']) {
      if (pendingFields.contains(field) || spec.counters.contains(field)) continue;
      await db.into(db.fieldClocks).insertOnConflictUpdate(
        FieldClocksCompanion.insert(
          entity: change.entity,
          entityId: change.entityId,
          field: field,
          hlc: remote.toString(),
        ),
      );
    }
  }
}
