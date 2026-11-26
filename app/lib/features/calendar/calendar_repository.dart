import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';

/// How far ahead "coming up" looks.
const comingUpDays = 30;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// The days [e] falls on from [from] to [to] (both inclusive). Monthly and
/// yearly repeats keep the first date's day, clamped to short months (a
/// Feb 29 birthday is on Feb 28 in other years).
List<DateTime> occurrences(CalendarEvent e, DateTime from, DateTime to) {
  final start = parseIsoDate(e.startsOn);
  if (start == null) return const [];
  final a = _day(from);
  final b = _day(to);
  if (b.isBefore(start)) return const [];
  final out = <DateTime>[];

  void stepMonths(int every, int firstK) {
    for (var k = firstK; ; k++) {
      final d = addMonths(start, k * every, day: start.day);
      if (d.isAfter(b)) break;
      if (!d.isBefore(a)) out.add(d);
    }
  }

  switch (e.repeat) {
    case 'weekly':
      final behind = daysUntil(a, start);
      var d = DateTime(start.year, start.month, start.day + (behind <= 0 ? 0 : (behind + 6) ~/ 7) * 7);
      while (!d.isAfter(b)) {
        out.add(d);
        d = DateTime(d.year, d.month, d.day + 7);
      }
    case 'monthly':
      final behind = (a.year - start.year) * 12 + a.month - start.month - 1;
      stepMonths(1, behind > 0 ? behind : 0);
    case 'yearly':
      final behind = a.year - start.year - 1;
      stepMonths(12, behind > 0 ? behind : 0);
    default:
      if (!start.isBefore(a)) out.add(start);
  }
  return out;
}

enum CalendarKind { event, bill, subscription }

/// One thing on one day: an event occurrence, or a bill or subscription due.
class CalendarItem {
  const CalendarItem({
    required this.day,
    required this.kind,
    required this.title,
    this.event,
    this.startTime,
    this.endTime,
    this.memberId,
    this.amountMinor,
  });

  final DateTime day;
  final CalendarKind kind;
  final String title;
  final CalendarEvent? event;

  /// Local `HH:MM`; null = all day.
  final String? startTime;
  final String? endTime;
  final String? memberId;
  final int? amountMinor;

  bool get allDay => startTime == null;
}

/// Everything on the calendar from [from] to [to], by day. Bills and
/// subscriptions are passed only for adults.
class Agenda {
  Agenda(
    List<CalendarEvent> events,
    DateTime from,
    DateTime to, {
    List<Bill> bills = const [],
    List<Subscription> subscriptions = const [],
  }) {
    final a = _day(from);
    final b = _day(to);
    bool inRange(DateTime d) => !d.isBefore(a) && !d.isAfter(b);
    void add(CalendarItem i) => _byDay.putIfAbsent(isoDate(i.day), () => []).add(i);

    for (final e in events) {
      for (final d in occurrences(e, a, b)) {
        add(
          CalendarItem(
            day: d,
            kind: CalendarKind.event,
            title: e.title,
            event: e,
            startTime: e.startTime,
            endTime: e.endTime,
            memberId: e.memberId,
          ),
        );
      }
    }
    for (final bill in bills) {
      final d = parseIsoDate(bill.dueOn);
      if (bill.isPaid || d == null || !inRange(d)) continue;
      add(CalendarItem(day: d, kind: CalendarKind.bill, title: bill.name, amountMinor: bill.amountMinor));
    }
    for (final s in subscriptions) {
      final d = parseIsoDate(s.nextDueOn);
      if (d == null || !inRange(d)) continue;
      add(CalendarItem(day: d, kind: CalendarKind.subscription, title: s.name, amountMinor: s.priceMinor));
    }
    for (final list in _byDay.values) {
      list.sort((x, y) {
        if (x.allDay != y.allDay) return x.allDay ? -1 : 1;
        final t = (x.startTime ?? '').compareTo(y.startTime ?? '');
        return t != 0 ? t : x.title.toLowerCase().compareTo(y.title.toLowerCase());
      });
    }
  }

  final Map<String, List<CalendarItem>> _byDay = {};

  List<CalendarItem> on(DateTime day) => _byDay[isoDate(day)] ?? const [];

  /// Days that have something, in order, from [after] (exclusive).
  List<(DateTime, List<CalendarItem>)> daysAfter(DateTime after) {
    final key = isoDate(after);
    final keys = _byDay.keys.where((k) => k.compareTo(key) > 0).toList()..sort();
    return [for (final k in keys) (parseIsoDate(k)!, _byDay[k]!)];
  }
}

/// Calendar events. Anyone but viewers adds them; adults change any, others
/// only the ones they added (enforced in the app).
class CalendarRepository {
  CalendarRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today => _now();

  Stream<List<CalendarEvent>> watchEvents() =>
      (db.select(db.events)
            ..where((e) => e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm.asc(e.startsOn)]))
          .watch();

  Future<String> addEvent({
    required String title,
    required DateTime startsOn,
    String? startTime,
    String? endTime,
    String repeat = 'none',
    String? memberId,
    String? location,
    String? note,
  }) => writer.insert('events', {
    ..._fields(title, startsOn, startTime, endTime, repeat, memberId, location, note),
    'created_by': writer.identity.memberId,
  });

  Future<void> editEvent(
    CalendarEvent e, {
    required String title,
    required DateTime startsOn,
    String? startTime,
    String? endTime,
    required String repeat,
    String? memberId,
    String? location,
    String? note,
  }) {
    final next = _fields(title, startsOn, startTime, endTime, repeat, memberId, location, note);
    final current = {
      'title': e.title,
      'starts_on': e.startsOn,
      'start_time': e.startTime,
      'end_time': e.endTime,
      'repeat': e.repeat,
      'member_id': e.memberId,
      'location': e.location,
      'note': e.note,
    };
    final changed = {
      for (final f in next.entries)
        if (current[f.key] != f.value) f.key: f.value,
    };
    return changed.isEmpty ? Future.value() : writer.update('events', e.id, changed);
  }

  Map<String, Object?> _fields(
    String title,
    DateTime startsOn,
    String? startTime,
    String? endTime,
    String repeat,
    String? memberId,
    String? location,
    String? note,
  ) {
    String? blank(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
    return {
      'title': title.trim(),
      'starts_on': isoDate(startsOn),
      'start_time': startTime,
      'end_time': startTime == null ? null : endTime,
      'repeat': repeat,
      'member_id': memberId,
      'location': blank(location),
      'note': blank(note),
    };
  }

  Future<void> removeEvent(String id) => writer.delete('events', id);
}
