/// Wire types and transport interface for docs/sync-protocol.md §5.
library;

const syncProtocolVersion = 1;

class PushResult {
  const PushResult({
    required this.opId,
    required this.status,
    this.serverVersion,
    this.conflictId,
    this.error,
    this.details,
  });

  factory PushResult.fromJson(Map<String, Object?> j) => PushResult(
    opId: j['op_id'] as String,
    status: j['status'] as String,
    serverVersion: (j['server_version'] as num?)?.toInt(),
    conflictId: j['conflict_id'] as String?,
    error: j['error'] as String?,
    details: j['details'],
  );

  final String opId;

  /// applied, duplicate, merged or rejected.
  final String status;
  final int? serverVersion;
  final String? conflictId;
  final String? error;
  final Object? details;
}

class PushResponse {
  const PushResponse({required this.serverTimeMs, required this.results});

  factory PushResponse.fromJson(Map<String, Object?> j) => PushResponse(
    serverTimeMs: (j['server_time_ms'] as num).toInt(),
    results: [
      for (final r in j['results'] as List) PushResult.fromJson((r as Map).cast()),
    ],
  );

  final int serverTimeMs;
  final List<PushResult> results;
}

class PulledChange {
  const PulledChange({
    required this.seq,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.row,
  });

  factory PulledChange.fromJson(Map<String, Object?> j) => PulledChange(
    seq: (j['seq'] as num).toInt(),
    entity: j['entity'] as String,
    entityId: j['entity_id'] as String,
    op: j['op'] as String,
    row: (j['row'] as Map).cast(),
  );

  final int seq;
  final String entity;
  final String entityId;
  final String op;

  /// Full merged row, tombstones included.
  final Map<String, Object?> row;
}

class PullResponse {
  const PullResponse({
    required this.serverTimeMs,
    required this.changes,
    required this.cursor,
    required this.hasMore,
  });

  factory PullResponse.fromJson(Map<String, Object?> j) => PullResponse(
    serverTimeMs: (j['server_time_ms'] as num).toInt(),
    changes: [
      for (final c in j['changes'] as List) PulledChange.fromJson((c as Map).cast()),
    ],
    cursor: (j['cursor'] as num).toInt(),
    hasMore: j['has_more'] as bool,
  );

  final int serverTimeMs;
  final List<PulledChange> changes;
  final int cursor;
  final bool hasMore;
}

/// Snapshot of every row the member may read (sync-protocol §5.3), valid
/// from [cursor].
class BootstrapResponse {
  const BootstrapResponse({required this.serverTimeMs, required this.entities, required this.cursor});

  factory BootstrapResponse.fromJson(Map<String, Object?> j) {
    final raw = j['entities'];
    return BootstrapResponse(
      serverTimeMs: (j['server_time_ms'] as num).toInt(),
      entities: {
        // PHP encodes an empty object as [].
        if (raw is Map)
          for (final e in raw.entries)
            e.key as String: [for (final r in e.value as List) (r as Map).cast<String, Object?>()],
      },
      cursor: (j['cursor'] as num?)?.toInt() ?? 0,
    );
  }

  final int serverTimeMs;
  final Map<String, List<Map<String, Object?>>> entities;
  final int cursor;
}

/// Transport for sync. [DioSyncApi] talks to the real hub; tests use a fake.
abstract interface class SyncApi {
  Future<PushResponse> push(String deviceId, List<Map<String, Object?>> ops);
  Future<PullResponse> pull(int cursor, int limit);
  Future<BootstrapResponse> bootstrap();
}

/// Server answered 426: this app is too old. Sync pauses; local data is kept.
class UpgradeRequired implements Exception {
  const UpgradeRequired(this.minProtocol);
  final int minProtocol;
  @override
  String toString() => 'UpgradeRequired(min_protocol: $minProtocol)';
}

/// Server answered 401: the device token is gone or revoked.
class SignedOut implements Exception {
  const SignedOut();
}

/// No token for the profile that made these ops (a PIN profile used offline
/// that hasn't signed in online yet). Its ops wait; pulling continues.
class ProfileTokenMissing implements Exception {
  const ProfileTokenMissing(this.deviceId);
  final String deviceId;
  @override
  String toString() => 'ProfileTokenMissing($deviceId)';
}

/// No connection, timeout or a 5xx: try again later.
class SyncUnavailable implements Exception {
  const SyncUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'SyncUnavailable($reason)';
}
