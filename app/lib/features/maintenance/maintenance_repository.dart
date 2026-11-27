import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../budget/budget_repository.dart' show derivedIdNamespace;

/// [MaintenanceTasks.area] and [MaintenanceLogs.area], in the order offered.
const maintenanceAreas = [
  'aircon',
  'water',
  'roof',
  'electrical',
  'plumbing',
  'septic',
  'pest',
  'appliance',
  'garden',
  'other',
];

/// [Contractors.trade], in the order offered.
const contractorTrades = ['electrician', 'plumber', 'aircon', 'carpenter', 'mason', 'pest', 'general', 'other'];

/// Common upkeep offered when adding a task: name key (label in the ARB),
/// area and how often in months.
const upkeepStarters = [
  ('aircon', 'aircon', 3),
  ('tank', 'water', 6),
  ('pest', 'pest', 6),
  ('roof', 'roof', 12),
  ('electrical', 'electrical', 12),
  ('septic', 'septic', 36),
];

/// [MaintenanceLogs.kind].
const upkeepKind = 'upkeep';
const repairKind = 'repair';

/// Ledger `source_type` and category of maintenance costs.
const maintenanceSource = 'maintenance';
const maintenanceCategory = 'household';

/// Upkeep due this close counts as "due soon".
const upkeepSoonDays = 14;

String _derived(String name) => const Uuid().v5(derivedIdNamespace, name);

/// The log entry for doing [taskId] when due on [dueOn], the same id on every
/// device, so marking it done on two phones is one entry.
String upkeepLogId(String householdId, String taskId, String? dueOn) =>
    _derived('maintenance_logs/$householdId/$taskId/${dueOn ?? 'once'}');

/// The ledger entry for a log entry's cost.
String maintenanceCostId(String householdId, String logId) => _derived('transactions/$householdId/maintenance/$logId');

enum Due { overdue, soon, later, none }

Due dueOf(MaintenanceTask t, DateTime today) {
  final d = parseIsoDate(t.nextDueOn);
  if (d == null) return Due.none;
  final days = daysUntil(d, today);
  if (days < 0) return Due.overdue;
  return days <= upkeepSoonDays ? Due.soon : Due.later;
}

/// The next due date after doing [t] on [doneOn]; null for a one-off task.
String? nextDueAfter(MaintenanceTask t, DateTime doneOn) =>
    t.everyMonths == null ? null : isoDate(addMonths(doneOn, t.everyMonths!));

/// What the screen and the home tile show.
class MaintenanceSummary {
  MaintenanceSummary(List<MaintenanceTask> tasks, this.logs, this.today) : tasks = [...tasks]..sort(_byDue);

  /// Tasks by next due date (no date last).
  final List<MaintenanceTask> tasks;
  final List<MaintenanceLog> logs;
  final DateTime today;

  bool get isEmpty => tasks.isEmpty && logs.isEmpty;

  List<MaintenanceTask> get overdue => tasks.where((t) => dueOf(t, today) == Due.overdue).toList();

  /// Not overdue, with a date: what's coming up.
  List<MaintenanceTask> get upcoming =>
      tasks.where((t) => const [Due.soon, Due.later].contains(dueOf(t, today))).toList();

  /// One-off tasks already done.
  List<MaintenanceTask> get done => tasks.where((t) => t.nextDueOn == null && t.lastDoneOn != null).toList();

  /// One-off tasks with no date yet.
  List<MaintenanceTask> get undated => tasks.where((t) => t.nextDueOn == null && t.lastDoneOn == null).toList();

  MaintenanceTask? get next => upcoming.firstOrNull;
  int get soonCount => tasks.where((t) => dueOf(t, today) == Due.soon).length;

  /// Costs logged this calendar year.
  int get spentThisYear =>
      logs.where((l) => l.doneOn.startsWith('${today.year}-')).fold(0, (s, l) => s + (l.costMinor ?? 0));

  static int _byDue(MaintenanceTask a, MaintenanceTask b) {
    final x = a.nextDueOn, y = b.nextDueOn;
    if (x == null || y == null) {
      if (x != y) return x == null ? 1 : -1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
    return x.compareTo(y);
  }
}

/// Home Maintenance: upkeep tasks, the log of upkeep and repairs, and
/// contractors. Costs post to the ledger (category `household`).
class MaintenanceRepository {
  MaintenanceRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  String get me => writer.identity.memberId;
  String get _household => writer.identity.householdId;

  // ---------------------------------------------------------------- tasks

  Stream<List<MaintenanceTask>> watchTasks() =>
      (db.select(db.maintenanceTasks)..where((t) => t.deletedAt.isNull())).watch();

  Future<String> addTask({
    required String name,
    required String area,
    int? everyMonths,
    DateTime? nextDueOn,
    String? inventoryItemId,
    String? contractorId,
    String? note,
  }) => writer.insert('maintenance_tasks', {
    'name': name.trim(),
    'area': area,
    'every_months': everyMonths,
    'next_due_on': nextDueOn == null ? null : isoDate(nextDueOn),
    'inventory_item_id': inventoryItemId,
    'contractor_id': contractorId,
    'note': _blankToNull(note),
  });

  Future<void> editTask(
    MaintenanceTask t, {
    required String name,
    required String area,
    int? everyMonths,
    DateTime? nextDueOn,
    String? inventoryItemId,
    String? contractorId,
    String? note,
  }) => _update('maintenance_tasks', t.id, {
    'name': (t.name, name.trim()),
    'area': (t.area, area),
    'every_months': (t.everyMonths, everyMonths),
    'next_due_on': (t.nextDueOn, nextDueOn == null ? null : isoDate(nextDueOn)),
    'inventory_item_id': (t.inventoryItemId, inventoryItemId),
    'contractor_id': (t.contractorId, contractorId),
    'note': (t.note, _blankToNull(note)),
  });

  /// Deletes the task; its log entries (and their costs) stay in the history.
  Future<void> removeTask(String id) => writer.delete('maintenance_tasks', id);

  /// Records doing [t] on [doneOn] (default today), with an optional cost
  /// posted to the ledger, and moves the task's next due date on.
  Future<void> markDone(
    MaintenanceTask t, {
    DateTime? doneOn,
    int? costMinor,
    String? contractorId,
    String? note,
  }) async {
    final day = doneOn ?? today;
    final derived = upkeepLogId(_household, t.id, t.nextDueOn);
    // Done again after an undo: the derived entry exists (removed), so use a new id.
    final logId = await writer.insert('maintenance_logs', {
      'kind': upkeepKind,
      'task_id': t.id,
      'area': t.area,
      'title': t.name,
      'done_on': isoDate(day),
      'due_on': t.nextDueOn,
      'cost_minor': _positive(costMinor),
      'member_id': me,
      'contractor_id': contractorId ?? t.contractorId,
      'inventory_item_id': t.inventoryItemId,
      'note': _blankToNull(note),
    }, id: await _exists(db.maintenanceLogs, derived) ? null : derived);
    await _postCost(logId, t.name, day, costMinor);
    await writer.update('maintenance_tasks', t.id, {'last_done_on': isoDate(day), 'next_due_on': nextDueAfter(t, day)});
  }

  /// The latest upkeep entry for [t].
  Future<MaintenanceLog?> lastDone(MaintenanceTask t) =>
      (db.select(db.maintenanceLogs)
            ..where((l) => l.deletedAt.isNull() & l.kind.equals(upkeepKind) & l.taskId.equals(t.id))
            ..orderBy([(l) => OrderingTerm.desc(l.doneOn), (l) => OrderingTerm.desc(l.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Only the person who marked it done can undo it.
  Future<bool> canUndo(MaintenanceTask t) async => (await lastDone(t))?.memberId == me;

  /// Removes the latest upkeep entry (and its cost) and puts the task back
  /// to the date it was due.
  Future<void> undoDone(MaintenanceTask t) async {
    final log = await lastDone(t);
    if (log == null) return;
    await removeLog(log);
    final previous = await lastDone(t);
    await writer.update('maintenance_tasks', t.id, {'next_due_on': log.dueOn, 'last_done_on': previous?.doneOn});
  }

  // ------------------------------------------------------------------ log

  /// Upkeep done and repairs, latest first.
  Stream<List<MaintenanceLog>> watchLogs() =>
      (db.select(db.maintenanceLogs)
            ..where((l) => l.deletedAt.isNull())
            ..orderBy([(l) => OrderingTerm.desc(l.doneOn), (l) => OrderingTerm.desc(l.createdAt)]))
          .watch();

  Future<String> addRepair({
    required String title,
    required String area,
    DateTime? doneOn,
    int? costMinor,
    String? contractorId,
    String? inventoryItemId,
    String? note,
  }) async {
    final day = doneOn ?? today;
    final id = await writer.insert('maintenance_logs', {
      'kind': repairKind,
      'area': area,
      'title': title.trim(),
      'done_on': isoDate(day),
      'cost_minor': _positive(costMinor),
      'member_id': me,
      'contractor_id': contractorId,
      'inventory_item_id': inventoryItemId,
      'note': _blankToNull(note),
    });
    await _postCost(id, title.trim(), day, costMinor);
    return id;
  }

  Future<void> setLogNote(MaintenanceLog l, String? note) async {
    if (l.note != _blankToNull(note)) await writer.update('maintenance_logs', l.id, {'note': _blankToNull(note)});
  }

  /// Deletes a log entry and its ledger entry. The task is not changed.
  Future<void> removeLog(MaintenanceLog l) async {
    final cost = await costOf(l);
    if (cost != null) await writer.delete('transactions', cost.id);
    await writer.delete('maintenance_logs', l.id);
  }

  /// The ledger entry for [l]'s cost, if any.
  Future<LedgerEntry?> costOf(MaintenanceLog l) =>
      (db.select(db.transactions)
            ..where((t) => t.deletedAt.isNull() & t.sourceType.equals(maintenanceSource) & t.sourceId.equals(l.id))
            ..limit(1))
          .getSingleOrNull();

  Future<void> _postCost(String logId, String title, DateTime day, int? costMinor) async {
    final cost = _positive(costMinor);
    if (cost == null) return;
    final derived = maintenanceCostId(_household, logId);
    await writer.insert('transactions', {
      'amount_minor': -cost,
      'category': maintenanceCategory,
      'currency': 'PHP',
      // Noon on the day it was done, so it lands in that day's month.
      'occurred_at': DateTime(day.year, day.month, day.day, 12).toUtc(),
      'member_id': me,
      'source_type': maintenanceSource,
      'source_id': logId,
      'note': title,
    }, id: await _exists(db.transactions, derived) ? null : derived);
  }

  // ---------------------------------------------------------- contractors

  Stream<List<Contractor>> watchContractors() =>
      (db.select(db.contractors)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.name.lower())]))
          .watch();

  Future<String> addContractor({required String name, required String trade, String? phone, String? note}) =>
      writer.insert('contractors', {
        'name': name.trim(),
        'trade': trade,
        'phone': _blankToNull(phone),
        'note': _blankToNull(note),
      });

  Future<void> editContractor(
    Contractor c, {
    required String name,
    required String trade,
    String? phone,
    String? note,
  }) => _update('contractors', c.id, {
    'name': (c.name, name.trim()),
    'trade': (c.trade, trade),
    'phone': (c.phone, _blankToNull(phone)),
    'note': (c.note, _blankToNull(note)),
  });

  Future<void> removeContractor(String id) => writer.delete('contractors', id);

  // ---------------------------------------------------------------------

  Future<bool> _exists(TableInfo<Table, dynamic> table, String id) async {
    final row = await db
        .customSelect(
          'SELECT 1 FROM "${table.actualTableName}" WHERE id = ?',
          variables: [Variable<String>(id)],
          readsFrom: {table},
        )
        .getSingleOrNull();
    return row != null;
  }

  /// Sends only the fields whose (before, after) differ.
  Future<void> _update(String entity, String id, Map<String, (Object?, Object?)> fields) async {
    final changed = {
      for (final e in fields.entries)
        if (e.value.$1 != e.value.$2) e.key: e.value.$2,
    };
    if (changed.isNotEmpty) await writer.update(entity, id, changed);
  }
}

int? _positive(int? v) => v == null || v <= 0 ? null : v;

String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
