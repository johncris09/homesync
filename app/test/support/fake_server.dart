import 'package:homesync/core/sync/entities.dart';
import 'package:homesync/core/sync/sync_api.dart';

/// In-memory stand-in for the Laravel hub. Follows the same rules as
/// `api/app/Sync/SyncService.php` (sync-protocol §6) closely enough to test
/// that devices converge.
class FakeSyncServer {
  FakeSyncServer({this.householdId = '01900000-0000-7000-8000-000000000001'});

  final String householdId;
  int timeMs = 1795586690000;

  final Map<String, Map<String, Map<String, Object?>>> rows = {};
  final Map<String, ({String hlc, String by})> _clocks = {};
  final Map<String, int> _processed = {};
  final List<PulledChange> log = [];
  int _conflictSeq = 0;
  int pushCalls = 0;

  FakeSyncApi apiFor({required String memberId, required String deviceId}) =>
      FakeSyncApi(this, memberId, deviceId);

  String _key(String entity, String id, String field) => '$entity/$id/$field';

  PushResponse push(String memberId, String deviceId, List<Map<String, Object?>> ops) {
    pushCalls++;
    final results = <PushResult>[];
    for (final op in ops) {
      final opId = op['op_id'] as String;
      final done = _processed[opId];
      if (done != null) {
        results.add(PushResult(opId: opId, status: 'duplicate', serverVersion: done));
        continue;
      }
      try {
        final (status, seq, conflictId) = _apply(memberId, deviceId, op);
        _processed[opId] = seq;
        results.add(PushResult(opId: opId, status: status, serverVersion: seq, conflictId: conflictId));
      } on _Rejected catch (e) {
        results.add(PushResult(opId: opId, status: 'rejected', error: e.error));
      }
    }
    return PushResponse(serverTimeMs: timeMs, results: results);
  }

  BootstrapResponse bootstrap() => BootstrapResponse(
    serverTimeMs: timeMs,
    entities: {
      for (final e in rows.entries) e.key: [for (final r in e.value.values) Map.of(r)],
    },
    cursor: log.length,
  );

  PullResponse pull(int cursor, int limit) {
    final page = log.where((c) => c.seq > cursor).take(limit + 1).toList();
    final hasMore = page.length > limit;
    final changes = page.take(limit).toList();
    return PullResponse(
      serverTimeMs: timeMs,
      changes: [
        for (final c in changes)
          PulledChange(seq: c.seq, entity: c.entity, entityId: c.entityId, op: c.op, row: Map.of(c.row)),
      ],
      cursor: changes.isEmpty ? cursor : changes.last.seq,
      hasMore: hasMore,
    );
  }

  (String, int, String?) _apply(String memberId, String deviceId, Map<String, Object?> op) {
    final entity = op['entity'] as String;
    final spec = syncedEntities[entity];
    if (spec == null) throw _Rejected('unknown_entity');
    if (spec.serverCreated && op['op'] == 'insert') throw _Rejected('forbidden');
    final id = op['entity_id'] as String;
    final hlc = op['hlc'] as String;
    final fields = (op['fields'] as Map? ?? const {}).cast<String, Object?>();
    final table = rows.putIfAbsent(entity, () => {});
    final row = table[id];

    // An insert onto an existing row (derived ids, §2.1) comes from a device
    // that never saw the row: base version 0, so reviewed values are kept.
    final base = op['op'] == 'insert' && row != null ? 0 : op['base_version'] as int?;
    final ctx = _Ctx(spec, id, hlc, memberId, deviceId, base);
    final (String status, String? conflictId) = switch (op['op']) {
      'insert' => row != null ? _update(ctx, row, fields) : _insert(ctx, table, fields),
      'update' => _update(ctx, _exists(row), fields),
      'delete' => _delete(ctx, _exists(row)),
      'increment' => _increment(ctx, _exists(row), fields),
      _ => throw _Rejected('validation'),
    };

    final seq = log.length + 1;
    table[id]!['server_version'] = seq;
    log.add(PulledChange(seq: seq, entity: entity, entityId: id, op: op['op'] as String, row: Map.of(table[id]!)));
    return (status, seq, conflictId);
  }

  Map<String, Object?> _exists(Map<String, Object?>? row) => row ?? (throw _Rejected('validation'));

  void _checkFields(EntitySpec spec, Iterable<String> fields) {
    for (final f in fields) {
      if (!spec.fields.contains(f)) throw _Rejected('validation');
    }
  }

  (String, String?) _insert(_Ctx ctx, Map<String, Map<String, Object?>> table, Map<String, Object?> fields) {
    _checkFields(ctx.spec, fields.keys);
    final now = _iso();
    table[ctx.id] = {
      for (final f in ctx.spec.fields) f: null,
      for (final f in ctx.spec.counters) f: 0,
      ...fields,
      'id': ctx.id,
      'household_id': householdId,
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
      'hlc': ctx.hlc,
      'server_version': null,
      'updated_by': ctx.member,
      'device_id': ctx.device,
    };
    for (final f in fields.keys) {
      if (!ctx.spec.counters.contains(f)) _setClock(ctx, f);
    }
    return ('applied', null);
  }

  (String, String?) _update(_Ctx ctx, Map<String, Object?> row, Map<String, Object?> fields) {
    _checkFields(ctx.spec, fields.keys);
    for (final f in fields.keys) {
      if (ctx.spec.counters.contains(f)) throw _Rejected('not_counter');
      if (ctx.spec.appendOnly && !ctx.spec.mutable.contains(f)) throw _Rejected('validation');
    }
    final changes = <String, Object?>{};
    var merged = false;
    String? conflictId;

    if (row['deleted_at'] != null) {
      if (_newer(ctx.hlc, _clock(ctx, 'deleted_at')?.hlc)) {
        changes['deleted_at'] = null;
        _setClock(ctx, 'deleted_at');
      } else {
        return ('merged', null);
      }
    }

    fields.forEach((field, value) {
      final clock = _clock(ctx, field);
      final current = row[field];
      if (ctx.spec.forwardOnly.contains(field)) {
        final isDone = current == true;
        final wantsDone = value == true;
        if (isDone && !wantsDone) {
          final same = clock != null && clock.by == ctx.member;
          if (!(same && _newer(ctx.hlc, clock.hlc))) {
            merged = true;
            return;
          }
        } else if (isDone == wantsDone) {
          return;
        }
        changes[field] = value;
        _setClock(ctx, field);
        return;
      }
      final differs = '$current' != '$value';
      final reviewed = ctx.spec.reviewed.contains(field);
      if (_newer(ctx.hlc, clock?.hlc)) {
        if (differs && reviewed && clock != null && clock.by != ctx.member &&
            ctx.baseVersion != null && ctx.baseVersion! < (row['server_version'] as int? ?? 0)) {
          conflictId = _recordConflict(ctx, field, value, ctx.member, current, clock.by);
        }
        if (differs) changes[field] = value;
        _setClock(ctx, field);
      } else {
        merged = true;
        if (differs && reviewed) {
          conflictId = _recordConflict(ctx, field, current, clock?.by, value, ctx.member);
        }
      }
    });

    if (changes.isNotEmpty) {
      row.addAll(changes);
      _touch(ctx, row);
    }
    return (merged ? 'merged' : 'applied', conflictId);
  }

  /// Same as SyncService::recordConflict: a server-created `conflicts` row,
  /// logged so it arrives on pull.
  String _recordConflict(_Ctx ctx, String field, Object? kept, String? keptBy, Object? lost, String? lostBy) {
    final id = '01990000-0000-7000-8000-${(++_conflictSeq).toRadixString(16).padLeft(12, '0')}';
    final now = _iso();
    final row = <String, Object?>{
      'id': id,
      'household_id': householdId,
      'entity': ctx.spec.name,
      'entity_id': ctx.id,
      'field': field,
      'kept_value': kept,
      'kept_by': keptBy,
      'lost_value': lost,
      'lost_by': lostBy,
      'resolved_at': null,
      'resolved_by': null,
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
      'hlc': ctx.hlc,
      'server_version': log.length + 1,
      'updated_by': ctx.member,
      'device_id': ctx.device,
    };
    rows.putIfAbsent('conflicts', () => {})[id] = row;
    log.add(PulledChange(seq: log.length + 1, entity: 'conflicts', entityId: id, op: 'insert', row: Map.of(row)));
    return id;
  }

  (String, String?) _delete(_Ctx ctx, Map<String, Object?> row) {
    String? newestEdit;
    _clocks.forEach((k, v) {
      if (k.startsWith('${ctx.spec.name}/${ctx.id}/') && _newer(v.hlc, newestEdit)) newestEdit = v.hlc;
    });
    if (newestEdit != null && ctx.hlc.compareTo(newestEdit!) < 0) return ('merged', null);
    if (row['deleted_at'] == null) {
      row['deleted_at'] = _iso();
      _touch(ctx, row);
    }
    _setClock(ctx, 'deleted_at');
    return ('applied', null);
  }

  (String, String?) _increment(_Ctx ctx, Map<String, Object?> row, Map<String, Object?> fields) {
    for (final entry in fields.entries) {
      if (!ctx.spec.counters.contains(entry.key)) throw _Rejected('not_counter');
      row[entry.key] = ((row[entry.key] as num?) ?? 0) + (entry.value as num);
    }
    _touch(ctx, row);
    return ('applied', null);
  }

  ({String hlc, String by})? _clock(_Ctx ctx, String field) => _clocks[_key(ctx.spec.name, ctx.id, field)];

  void _setClock(_Ctx ctx, String field) =>
      _clocks[_key(ctx.spec.name, ctx.id, field)] = (hlc: ctx.hlc, by: ctx.member);

  void _touch(_Ctx ctx, Map<String, Object?> row) {
    row['updated_at'] = _iso();
    if (_newer(ctx.hlc, row['hlc'] as String?)) row['hlc'] = ctx.hlc;
    row['updated_by'] = ctx.member;
    row['device_id'] = ctx.device;
  }

  bool _newer(String a, String? b) => b == null || a.compareTo(b) > 0;

  String _iso() => DateTime.fromMillisecondsSinceEpoch(timeMs, isUtc: true).toIso8601String();
}

class _Ctx {
  _Ctx(this.spec, this.id, this.hlc, this.member, this.device, this.baseVersion);
  final EntitySpec spec;
  final String id;
  final String hlc;
  final String member;
  final String device;
  final int? baseVersion;
}

class _Rejected implements Exception {
  _Rejected(this.error);
  final String error;
}

/// One device's connection to the fake hub. Flip [offline] or
/// [upgradeRequired] to simulate failures.
class FakeSyncApi implements SyncApi {
  FakeSyncApi(this.server, this.memberId, this.deviceId) : profiles = {deviceId: memberId};

  final FakeSyncServer server;
  final String memberId;
  final String deviceId;

  /// Device id -> member for every token this install holds (the main
  /// sign-in plus PIN profiles that signed in online).
  final Map<String, String> profiles;
  bool offline = false;
  bool upgradeRequired = false;

  /// Simulates a lost response: the server applies the push, the device
  /// never hears back.
  bool dropNextPushResponse = false;

  void _check() {
    if (upgradeRequired) throw const UpgradeRequired(2);
    if (offline) throw const SyncUnavailable('offline');
  }

  @override
  Future<PushResponse> push(String deviceId, List<Map<String, Object?>> ops) async {
    _check();
    final member = profiles[deviceId];
    if (member == null) throw ProfileTokenMissing(deviceId);
    final res = server.push(member, deviceId, ops);
    if (dropNextPushResponse) {
      dropNextPushResponse = false;
      throw const SyncUnavailable('connection dropped');
    }
    return res;
  }

  @override
  Future<PullResponse> pull(int cursor, int limit) async {
    _check();
    return server.pull(cursor, limit);
  }

  int bootstrapCalls = 0;

  @override
  Future<BootstrapResponse> bootstrap() async {
    _check();
    bootstrapCalls++;
    return server.bootstrap();
  }
}
