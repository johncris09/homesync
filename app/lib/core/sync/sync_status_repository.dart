import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'outbox.dart';

/// Read side of sync for the UI: what's pending, what failed, what needs a
/// decision. Per-record markers use [watchPendingIds] / [watchConflictIds].
class SyncStatusRepository {
  SyncStatusRepository(this.db);

  final AppDatabase db;

  Stream<int> watchPendingCount() {
    final count = db.outbox.seq.count();
    return (db.selectOnly(db.outbox)..addColumns([count])).map((r) => r.read(count) ?? 0).watchSingle();
  }

  /// Ids of [entity] records with local changes not yet on the hub.
  Stream<Set<String>> watchPendingIds(String entity) =>
      (db.selectOnly(db.outbox, distinct: true)
            ..addColumns([db.outbox.entityId])
            ..where(db.outbox.entity.equals(entity)))
          .map((r) => r.read(db.outbox.entityId)!)
          .watch()
          .map((ids) => ids.toSet());

  /// Ids of [entity] records with an open conflict.
  Stream<Set<String>> watchConflictIds(String entity) =>
      (db.select(db.conflicts)..where((c) => c.entity.equals(entity) & _open(c)))
          .watch()
          .map((rows) => {for (final r in rows) r.entityId});

  Stream<List<ConflictRecord>> watchOpenConflicts() =>
      (db.select(db.conflicts)
            ..where(_open)
            ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
          .watch();

  Stream<List<SyncError>> watchErrors() =>
      (db.select(db.syncErrors)
            ..where((e) => e.dismissed.equals(false))
            ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
          .watch();

  Future<void> dismissError(int id) =>
      (db.update(db.syncErrors)..where((e) => e.id.equals(id))).write(const SyncErrorsCompanion(dismissed: Value(true)));

  static Expression<bool> _open($ConflictsTable c) => c.resolvedAt.isNull() & c.deletedAt.isNull();
}

/// Decisions on values kept for review (sync-protocol §6.1).
class ConflictInbox {
  ConflictInbox(this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final LocalWriter writer;
  final DateTime Function() _now;

  /// Keep the live value.
  Future<void> keep(ConflictRecord c) => _resolve(c);

  /// Put the overwritten value back, then close the conflict.
  Future<void> revert(ConflictRecord c) async {
    final lost = c.lostValue == null ? null : jsonDecode(c.lostValue!);
    await writer.update(c.entity, c.entityId, {c.field: lost});
    await _resolve(c);
  }

  Future<void> _resolve(ConflictRecord c) => writer.update('conflicts', c.id, {
    'resolved_at': _now().toUtc(),
    'resolved_by': writer.identity.memberId,
  });
}
