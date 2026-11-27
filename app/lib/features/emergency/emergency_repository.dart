import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../budget/budget_repository.dart' show derivedIdNamespace;

/// [EmergencyContacts.kind], in the order the app offers them.
const emergencyContactKinds = ['family', 'barangay', 'hospital', 'doctor', 'other'];

/// National hotlines built into the app (not rows): key and number.
const nationalHotlines = [('emergency', '911'), ('redCross', '143')];

/// [SafetyCheckins.status].
const safeStatus = 'safe';
const helpStatus = 'help';

/// A check-in older than this no longer counts.
const checkinFreshHours = 24;

/// A go-bag item expiring this close needs replacing.
const goBagExpirySoonDays = 30;

/// Built-in hazard checklists: hazard → item keys (labels are in the ARB).
const hazardChecklists = {
  'typhoon': ['charge', 'water', 'food', 'secure', 'drains', 'bags', 'center', 'updates'],
  'flood': ['upHigh', 'power', 'documents', 'noWading', 'highGround', 'bags'],
  'earthquake': ['furniture', 'safeSpots', 'drill', 'shutOff', 'bedside', 'meet'],
};

/// Keys of the go-bag starter list (names are in the ARB, saved as text).
const goBagStarterKeys = [
  'water',
  'food',
  'flashlight',
  'batteries',
  'whistle',
  'firstAid',
  'medicines',
  'ids',
  'cash',
  'powerBank',
  'clothes',
  'raincoat',
];

String _derived(String name) => const Uuid().v5(derivedIdNamespace, name);

/// The household's one plan row, the same id on every device.
String emergencyPlanId(String householdId) => _derived('emergency_plans/$householdId/household');

/// A hazard checklist tick, the same id on every device.
String emergencyCheckId(String householdId, String hazard, String item) =>
    _derived('emergency_checks/$householdId/$hazard/$item');

/// Who has checked in within [checkinFreshHours]: the latest check-in of each
/// member, and who needs help.
class CheckinBoard {
  CheckinBoard(List<Member> members, List<SafetyCheckin> checkins, this.now)
    : members = [...members]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())) {
    for (final c in checkins) {
      final prev = latest[c.memberId];
      if (prev == null || c.checkedAt.isAfter(prev.checkedAt)) latest[c.memberId] = c;
    }
  }

  final List<Member> members;
  final DateTime now;

  /// Each member's latest check-in, however old.
  final latest = <String, SafetyCheckin>{};

  bool isFresh(SafetyCheckin c) => now.difference(c.checkedAt.toLocal()).inHours < checkinFreshHours;

  /// The member's check-in if it still counts.
  SafetyCheckin? current(String memberId) {
    final c = latest[memberId];
    return c != null && isFresh(c) ? c : null;
  }

  int get safeCount => members.where((m) => current(m.id)?.status == safeStatus).length;

  /// Members whose current check-in asks for help (latest first).
  List<Member> get needHelp =>
      members.where((m) => current(m.id)?.status == helpStatus).toList()
        ..sort((a, b) => current(b.id)!.checkedAt.compareTo(current(a.id)!.checkedAt));

  /// Anyone checked in recently: the screen then shows the round.
  bool get active => members.any((m) => current(m.id) != null);
}

/// One go-bag: a member's (or the household's when [memberId] is null).
class GoBag {
  GoBag(this.memberId, List<GoBagItem> items) : items = [...items]..sort(_order);

  final String? memberId;
  final List<GoBagItem> items;

  int get packed => items.where((i) => i.packed).length;
  bool get ready => items.isNotEmpty && packed == items.length;

  /// Items expired or expiring within [goBagExpirySoonDays].
  List<GoBagItem> expiring(DateTime today) => [
    for (final i in items)
      if (parseIsoDate(i.expiresOn) case final d? when daysUntil(d, today) <= goBagExpirySoonDays) i,
  ];

  static int _order(GoBagItem a, GoBagItem b) {
    final p = a.position.compareTo(b.position);
    return p != 0 ? p : a.createdAt.compareTo(b.createdAt);
  }
}

/// Go-bags for the household bag and every member, household first.
List<GoBag> goBags(List<Member> members, List<GoBagItem> items) {
  final byMember = <String?, List<GoBagItem>>{};
  for (final i in items) {
    (byMember[i.memberId] ??= []).add(i);
  }
  final sorted = [...members]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return [GoBag(null, byMember[null] ?? const []), for (final m in sorted) GoBag(m.id, byMember[m.id] ?? const [])];
}

/// Emergency & Disaster Preparedness, all on the device so it works offline.
class EmergencyRepository {
  EmergencyRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get now => _now();
  String get me => writer.identity.memberId;
  String get _household => writer.identity.householdId;

  // ------------------------------------------------------------- contacts

  Stream<List<EmergencyContact>> watchContacts() =>
      (db.select(db.emergencyContacts)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.position), (c) => OrderingTerm.asc(c.name)]))
          .watch();

  Future<String> addContact({required String name, required String kind, required String phone, String? note}) async {
    final count = (await (db.select(db.emergencyContacts)..where((c) => c.deletedAt.isNull())).get()).length;
    return writer.insert('emergency_contacts', {
      'name': name.trim(),
      'kind': kind,
      'phone': phone.trim(),
      'note': _blankToNull(note),
      'position': count,
    });
  }

  Future<void> editContact(
    EmergencyContact c, {
    required String name,
    required String kind,
    required String phone,
    String? note,
  }) => _update('emergency_contacts', c.id, {
    'name': (c.name, name.trim()),
    'kind': (c.kind, kind),
    'phone': (c.phone, phone.trim()),
    'note': (c.note, _blankToNull(note)),
  });

  Future<void> removeContact(String id) => writer.delete('emergency_contacts', id);

  // ----------------------------------------------------------------- plan

  Stream<EmergencyPlan?> watchPlan() => (db.select(
    db.emergencyPlans,
  )..where((p) => p.id.equals(emergencyPlanId(_household)) & p.deletedAt.isNull())).watchSingleOrNull();

  Future<void> savePlan({String? meetingPoint, String? meetingPointFar, String? evacuationCenter, String? note}) async {
    final id = emergencyPlanId(_household);
    final p = await (db.select(db.emergencyPlans)..where((p) => p.id.equals(id))).getSingleOrNull();
    if (p == null) {
      // Only what is filled in: another phone may have made this row offline,
      // and sending blanks would clear what it set.
      final fields = {
        'meeting_point': _blankToNull(meetingPoint),
        'meeting_point_far': _blankToNull(meetingPointFar),
        'evacuation_center': _blankToNull(evacuationCenter),
        'note': _blankToNull(note),
      }..removeWhere((_, v) => v == null);
      await writer.insert('emergency_plans', fields, id: id);
      return;
    }
    await _update('emergency_plans', id, {
      'meeting_point': (p.meetingPoint, _blankToNull(meetingPoint)),
      'meeting_point_far': (p.meetingPointFar, _blankToNull(meetingPointFar)),
      'evacuation_center': (p.evacuationCenter, _blankToNull(evacuationCenter)),
      'note': (p.note, _blankToNull(note)),
    });
  }

  // -------------------------------------------------------------- go-bags

  Stream<List<GoBagItem>> watchBagItems() => (db.select(db.goBagItems)..where((i) => i.deletedAt.isNull())).watch();

  Future<String> addBagItem(String? memberId, String name, {DateTime? expiresOn}) async {
    final count = (await _bag(memberId)).length;
    return writer.insert('go_bag_items', {
      'member_id': memberId,
      'name': name.trim(),
      'packed': false,
      'expires_on': expiresOn == null ? null : isoDate(expiresOn),
      'position': count,
    });
  }

  /// Adds the starter list to a bag, skipping names already in it.
  Future<int> addStarter(String? memberId, List<String> names) async {
    final have = {for (final i in await _bag(memberId)) i.name.trim().toLowerCase()};
    var added = 0;
    for (final n in names) {
      if (have.contains(n.trim().toLowerCase())) continue;
      await addBagItem(memberId, n);
      added++;
    }
    return added;
  }

  Future<void> setPacked(GoBagItem i, bool packed) async {
    if (i.packed == packed) return;
    await writer.update('go_bag_items', i.id, {'packed': packed});
  }

  Future<void> editBagItem(GoBagItem i, {required String name, DateTime? expiresOn}) => _update('go_bag_items', i.id, {
    'name': (i.name, name.trim()),
    'expires_on': (i.expiresOn, expiresOn == null ? null : isoDate(expiresOn)),
  });

  Future<void> removeBagItem(String id) => writer.delete('go_bag_items', id);

  Future<List<GoBagItem>> _bag(String? memberId) => (db.select(
    db.goBagItems,
  )..where((i) => i.deletedAt.isNull() & (memberId == null ? i.memberId.isNull() : i.memberId.equals(memberId)))).get();

  // --------------------------------------------------- hazard checklists

  Stream<List<EmergencyCheck>> watchChecks() =>
      (db.select(db.emergencyChecks)..where((c) => c.deletedAt.isNull())).watch();

  Future<void> setCheck(String hazard, String item, bool done) async {
    final id = emergencyCheckId(_household, hazard, item);
    final c = await (db.select(db.emergencyChecks)..where((c) => c.id.equals(id))).getSingleOrNull();
    final fields = {'done': done, 'done_by': done ? me : null, 'done_at': done ? now.toUtc() : null};
    if (c == null) {
      if (!done) return;
      await writer.insert('emergency_checks', {'hazard': hazard, 'item': item, ...fields}, id: id);
    } else if (c.done != done) {
      await writer.update('emergency_checks', id, fields);
    }
  }

  /// Unticks every item of [hazard] (e.g. before the next typhoon season).
  Future<void> clearChecks(String hazard) async {
    final ticked = await (db.select(
      db.emergencyChecks,
    )..where((c) => c.hazard.equals(hazard) & c.done.equals(true) & c.deletedAt.isNull())).get();
    for (final c in ticked) {
      await writer.update('emergency_checks', c.id, {'done': false, 'done_by': null, 'done_at': null});
    }
  }

  // ------------------------------------------------------------ check-ins

  Stream<List<SafetyCheckin>> watchCheckins() =>
      (db.select(db.safetyCheckins)..where((c) => c.deletedAt.isNull())).watch();

  /// Checks in the person using the app.
  Future<String> checkIn(String status, {String? note}) => writer.insert('safety_checkins', {
    'member_id': me,
    'status': status,
    'note': _blankToNull(note),
    'checked_at': now.toUtc(),
  });

  // ---------------------------------------------------------------------

  /// Sends only the fields whose (before, after) differ.
  Future<void> _update(String entity, String id, Map<String, (Object?, Object?)> fields) async {
    final changed = {
      for (final e in fields.entries)
        if (e.value.$1 != e.value.$2) e.key: e.value.$2,
    };
    if (changed.isNotEmpty) await writer.update(entity, id, changed);
  }
}

String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
