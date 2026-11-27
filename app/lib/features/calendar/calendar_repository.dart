import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../rent/rent_repository.dart' show UnitRow;

/// The default event colour (`events.color` null).
const eventColorDefault = 'ube';

/// How far ahead "coming up" looks.
const comingUpDays = 30;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// The most days one occurrence of a [repeat] may last, so it never runs into
/// the next one; null = no limit.
int? maxSpanDays(String repeat) => switch (repeat) {
  'weekly' => 7,
  'monthly' => 28,
  'yearly' => 365,
  _ => null,
};

/// Extra days after the first that each occurrence of [e] lasts (0 = one day).
int spanDays(CalendarEvent e) {
  final start = parseIsoDate(e.startsOn);
  final end = parseIsoDate(e.endsOn);
  if (start == null || end == null) return 0;
  final days = daysUntil(end, start);
  return days < 0 ? 0 : days;
}

/// The days [e] starts on from [from] to [to] (both inclusive). Monthly and
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

enum CalendarKind { event, bill, subscription, vehicle, checkup, rent, warranty }

/// One thing on one day: an event occurrence, a bill or subscription due, or
/// a vehicle's registration, insurance or PMS date.
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
    this.dueKind,
    DateTime? spanStart,
    DateTime? spanEnd,
  }) : spanStart = spanStart ?? day,
       spanEnd = spanEnd ?? day;

  final DateTime day;
  final CalendarKind kind;
  final String title;
  final CalendarEvent? event;

  /// Local `HH:MM` on this [day]. Both null = all day; on a multi-day event
  /// the first day has only the start ("Starts 6 PM"), the last day only the
  /// end ("Until 3 PM").
  final String? startTime;
  final String? endTime;
  final String? memberId;
  final int? amountMinor;

  /// For a vehicle: `registration`, `insurance` or `pms`; for a checkup:
  /// `checkup` or `vaccine`.
  final String? dueKind;

  /// First and last day of this occurrence (both [day] for a one-day item).
  final DateTime spanStart;
  final DateTime spanEnd;

  bool get allDay => startTime == null && endTime == null;
  bool get multiDay => daysUntil(spanEnd, spanStart) > 0;

  /// A later day of a multi-day occurrence (not where it starts).
  bool get continues => daysUntil(day, spanStart) > 0;
}

/// Everything on the calendar from [from] to [to], by day. Bills,
/// subscriptions and vehicles are passed only for adults.
class Agenda {
  Agenda(
    List<CalendarEvent> events,
    DateTime from,
    DateTime to, {
    List<Bill> bills = const [],
    List<Subscription> subscriptions = const [],
    List<Vehicle> vehicles = const [],
    List<Checkup> checkups = const [],
    List<UnitRow> rent = const [],
    List<InventoryItem> warranties = const [],
  }) {
    final a = _day(from);
    final b = _day(to);
    bool inRange(DateTime d) => !d.isBefore(a) && !d.isAfter(b);
    void add(CalendarItem i) => _byDay.putIfAbsent(isoDate(i.day), () => []).add(i);

    for (final e in events) {
      final span = spanDays(e);
      // Look back far enough to catch occurrences that started before [a].
      for (final first in occurrences(e, DateTime(a.year, a.month, a.day - span), b)) {
        final last = DateTime(first.year, first.month, first.day + span);
        for (var k = 0; k <= span; k++) {
          final d = DateTime(first.year, first.month, first.day + k);
          if (!inRange(d)) continue;
          add(
            CalendarItem(
              day: d,
              kind: CalendarKind.event,
              title: e.title,
              event: e,
              startTime: k == 0 ? e.startTime : null,
              endTime: e.startTime == null ? null : (k == span ? e.endTime : null),
              memberId: e.memberId,
              spanStart: first,
              spanEnd: last,
            ),
          );
        }
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
    for (final r in rent) {
      final s = r.status;
      if (s == null) continue;
      for (final (d, left) in s.unpaidBetween(a, b)) {
        add(
          CalendarItem(
            day: d,
            kind: CalendarKind.rent,
            title: '${r.unit.name} · ${s.lease.tenantName}',
            amountMinor: left,
          ),
        );
      }
    }
    for (final i in warranties) {
      final d = parseIsoDate(i.warrantyUntil);
      if (d == null || !inRange(d)) continue;
      add(CalendarItem(day: d, kind: CalendarKind.warranty, title: i.name));
    }
    for (final v in vehicles) {
      for (final (kind, due) in [
        ('registration', v.registrationDueOn),
        ('insurance', v.insuranceDueOn),
        ('pms', v.pmsDueOn),
      ]) {
        final d = parseIsoDate(due);
        if (d == null || !inRange(d)) continue;
        add(CalendarItem(day: d, kind: CalendarKind.vehicle, title: v.name, dueKind: kind));
      }
    }
    for (final c in checkups) {
      final d = parseIsoDate(c.dueOn);
      if (c.doneAt != null || d == null || !inRange(d)) continue;
      add(
        CalendarItem(
          day: d,
          kind: CalendarKind.checkup,
          title: c.title,
          dueKind: c.kind,
          startTime: c.dueTime,
          memberId: c.memberId,
        ),
      );
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

  /// Days that have something starting, in order, from [after] (exclusive).
  /// A multi-day event is listed once, on its first day.
  List<(DateTime, List<CalendarItem>)> daysAfter(DateTime after) {
    final key = isoDate(after);
    final keys = _byDay.keys.where((k) => k.compareTo(key) > 0).toList()..sort();
    return [
      for (final k in keys)
        if (_byDay[k]!.where((i) => !i.continues).toList() case final starting when starting.isNotEmpty)
          (parseIsoDate(k)!, starting),
    ];
  }
}

/// Multi-day items from [first] to [last] laid out in lanes, so overlapping
/// ranges are drawn as stacked bands and each occurrence keeps its lane on
/// every day it covers. At most [maxLanes] are drawn; the rest are counted.
class BandLayout {
  BandLayout(Agenda agenda, DateTime first, DateTime last, {this.maxLanes = 3}) {
    final seen = <String, CalendarItem>{};
    for (var d = _day(first); !d.isAfter(_day(last)); d = DateTime(d.year, d.month, d.day + 1)) {
      final items = [
        for (final i in agenda.on(d))
          if (i.multiDay) i,
      ];
      if (items.isNotEmpty) _byDay[isoDate(d)] = items;
      for (final i in items) {
        seen.putIfAbsent(_key(i), () => i);
      }
    }
    // Earlier first, then longer first, so a long range sits on top.
    final order = seen.values.toList()
      ..sort((x, y) {
        final s = x.spanStart.compareTo(y.spanStart);
        if (s != 0) return s;
        final l = y.spanEnd.compareTo(x.spanEnd);
        return l != 0 ? l : x.title.toLowerCase().compareTo(y.title.toLowerCase());
      });
    final laneEnds = <DateTime>[];
    for (final i in order) {
      var lane = laneEnds.indexWhere((end) => end.isBefore(i.spanStart));
      if (lane < 0) {
        lane = laneEnds.length;
        laneEnds.add(i.spanEnd);
      } else {
        laneEnds[lane] = i.spanEnd;
      }
      _lane[_key(i)] = lane;
    }
    lanes = laneEnds.length < maxLanes ? laneEnds.length : maxLanes;
  }

  final int maxLanes;

  /// Lanes drawn in each day cell (0 when nothing spans several days).
  late final int lanes;

  final _byDay = <String, List<CalendarItem>>{};
  final _lane = <String, int>{};

  static String _key(CalendarItem i) => '${i.event?.id}|${isoDate(i.spanStart)}';

  /// The item in each drawn lane on [day] (null = free), [lanes] long.
  List<CalendarItem?> on(DateTime day) {
    final out = List<CalendarItem?>.filled(lanes, null);
    for (final i in _byDay[isoDate(day)] ?? const <CalendarItem>[]) {
      final lane = _lane[_key(i)]!;
      if (lane < lanes) out[lane] = i;
    }
    return out;
  }

  /// Multi-day items on [day] that did not get a lane.
  int hiddenOn(DateTime day) =>
      (_byDay[isoDate(day)] ?? const <CalendarItem>[]).where((i) => _lane[_key(i)]! >= lanes).length;

  /// Whether [a] and [b] are the same occurrence (to join bands across days).
  static bool same(CalendarItem? a, CalendarItem? b) => a != null && b != null && _key(a) == _key(b);
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
    DateTime? endsOn,
    String? startTime,
    String? endTime,
    String repeat = 'none',
    String? color,
    String? memberId,
    String? location,
    String? note,
  }) => writer.insert('events', {
    ..._fields(title, startsOn, endsOn, startTime, endTime, repeat, color, memberId, location, note),
    'created_by': writer.identity.memberId,
  });

  Future<void> editEvent(
    CalendarEvent e, {
    required String title,
    required DateTime startsOn,
    DateTime? endsOn,
    String? startTime,
    String? endTime,
    required String repeat,
    String? color,
    String? memberId,
    String? location,
    String? note,
  }) {
    final next = _fields(title, startsOn, endsOn, startTime, endTime, repeat, color, memberId, location, note);
    final current = {
      'title': e.title,
      'starts_on': e.startsOn,
      'ends_on': e.endsOn,
      'start_time': e.startTime,
      'end_time': e.endTime,
      'repeat': e.repeat,
      'color': e.color,
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
    DateTime? endsOn,
    String? startTime,
    String? endTime,
    String repeat,
    String? color,
    String? memberId,
    String? location,
    String? note,
  ) {
    String? blank(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
    return {
      'title': title.trim(),
      'starts_on': isoDate(startsOn),
      // A one-day event has no end date; the span is kept within the repeat.
      'ends_on': endsOn == null || !_day(endsOn).isAfter(_day(startsOn))
          ? null
          : isoDate(_clampEnd(startsOn, endsOn, repeat)),
      'start_time': startTime,
      'end_time': startTime == null ? null : endTime,
      'repeat': repeat,
      // The first colour is the default look, stored as null.
      'color': color == null || color == eventColorDefault ? null : color,
      'member_id': memberId,
      'location': blank(location),
      'note': blank(note),
    };
  }

  DateTime _clampEnd(DateTime startsOn, DateTime endsOn, String repeat) {
    final max = maxSpanDays(repeat);
    if (max == null || daysUntil(endsOn, startsOn) < max) return endsOn;
    return DateTime(startsOn.year, startsOn.month, startsOn.day + max - 1);
  }

  Future<void> removeEvent(String id) => writer.delete('events', id);
}
