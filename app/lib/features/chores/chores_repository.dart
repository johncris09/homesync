import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';

/// How far back completions are loaded (once-chores are always loaded).
const completionWindowDays = 60;

/// Whether [c] is due on [day] (overdue once-chores are handled by the board).
bool isDueOn(Chore c, DateTime day) => switch (c.repeat) {
  'weekly' => c.weekday == day.weekday,
  'once' => c.dueOn == isoDate(day),
  _ => true,
};

/// A chore on the Today list with who did it today.
class ChoreToday {
  ChoreToday(this.chore, this.done, {this.overdueSince});

  final Chore chore;
  final List<ChoreCompletion> done;

  /// For a once-chore not done by its date.
  final DateTime? overdueSince;

  bool get isDone => done.isNotEmpty;
}

/// Today's chores and what's coming in the next days.
class ChoreBoard {
  ChoreBoard(List<Chore> chores, List<ChoreCompletion> completions, DateTime day, {String? me}) {
    final todayKey = isoDate(day);
    final byChore = <String, List<ChoreCompletion>>{};
    for (final c in completions) {
      byChore.putIfAbsent(c.choreId, () => []).add(c);
    }

    for (final c in chores) {
      final all = byChore[c.id] ?? const <ChoreCompletion>[];
      final doneToday = all.where((x) => x.doneOn == todayKey).toList();
      if (c.repeat == 'once') {
        final due = parseIsoDate(c.dueOn);
        if (due == null) continue;
        final days = daysUntil(due, day);
        if (days == 0 || (days < 0 && all.isEmpty) || doneToday.isNotEmpty) {
          today.add(ChoreToday(c, doneToday, overdueSince: days < 0 && all.isEmpty ? due : null));
        } else if (days > 0) {
          upcoming.add((chore: c, on: due));
        }
      } else if (isDueOn(c, day)) {
        today.add(ChoreToday(c, doneToday));
      }
      if (c.repeat == 'weekly' && c.weekday != null && c.weekday != day.weekday) {
        final ahead = (c.weekday! - day.weekday + 7) % 7;
        upcoming.add((chore: c, on: DateTime(day.year, day.month, day.day + ahead)));
      }
    }

    int mineFirst(Chore a, Chore b) {
      final am = me != null && a.assignedTo == me ? 0 : 1;
      final bm = me != null && b.assignedTo == me ? 0 : 1;
      return am != bm ? am - bm : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }

    today.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return mineFirst(a.chore, b.chore);
    });
    upcoming.sort((a, b) {
      final d = a.on.compareTo(b.on);
      return d != 0 ? d : mineFirst(a.chore, b.chore);
    });
    left = today.where((t) => !t.isDone).length;
    doneCount = today.length - left;
    mineLeft = me == null ? 0 : today.where((t) => !t.isDone && t.chore.assignedTo == me).length;
  }

  final List<ChoreToday> today = [];
  final List<({Chore chore, DateTime on})> upcoming = [];
  int left = 0;
  int doneCount = 0;
  int mineLeft = 0;
}

/// Chores and their completions. Completions are append-only: undoing one
/// deletes it, and only the person who did it may.
class ChoresRepository {
  ChoresRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today => _now();
  String get _me => writer.identity.memberId;

  Stream<List<Chore>> watchChores() =>
      (db.select(db.chores)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .watch();

  /// Recent completions, plus every completion of a once-chore.
  Stream<List<ChoreCompletion>> watchCompletions() {
    final cutoff = isoDate(today.subtract(const Duration(days: completionWindowDays)));
    final onceIds = db.selectOnly(db.chores)
      ..addColumns([db.chores.id])
      ..where(db.chores.repeat.equals('once'));
    return (db.select(db.choreCompletions)
          ..where((x) => x.deletedAt.isNull() & (x.doneOn.isBiggerOrEqualValue(cutoff) | x.choreId.isInQuery(onceIds))))
        .watch();
  }

  Future<String> addChore({
    required String name,
    String? assignedTo,
    String repeat = 'daily',
    int? weekday,
    DateTime? dueOn,
  }) => writer.insert('chores', _fields(name, assignedTo, repeat, weekday, dueOn));

  Future<void> editChore(
    Chore c, {
    required String name,
    String? assignedTo,
    required String repeat,
    int? weekday,
    DateTime? dueOn,
  }) {
    final next = _fields(name, assignedTo, repeat, weekday, dueOn);
    final current = {
      'name': c.name,
      'assigned_to': c.assignedTo,
      'repeat': c.repeat,
      'weekday': c.weekday,
      'due_on': c.dueOn,
    };
    return writer.update('chores', c.id, {
      for (final e in next.entries)
        if (current[e.key] != e.value) e.key: e.value,
    });
  }

  Map<String, Object?> _fields(String name, String? assignedTo, String repeat, int? weekday, DateTime? dueOn) => {
    'name': name.trim(),
    'assigned_to': assignedTo,
    'repeat': repeat,
    'weekday': repeat == 'weekly' ? (weekday ?? today.weekday) : null,
    'due_on': repeat == 'once' ? isoDate(dueOn ?? today) : null,
  };

  Future<void> removeChore(String id) => writer.delete('chores', id);

  /// Records that the active profile did [c] today.
  Future<String> markDone(Chore c) =>
      writer.insert('chore_completions', {'chore_id': c.id, 'member_id': _me, 'done_on': isoDate(today)});

  bool canUndo(ChoreCompletion x) => x.memberId == _me;

  Future<void> undo(ChoreCompletion x) {
    if (!canUndo(x)) throw StateError('only the person who did it can undo it');
    return writer.delete('chore_completions', x.id);
  }
}
