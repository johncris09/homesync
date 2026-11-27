import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../core/vault/vault_crypto.dart';
import '../../core/vault/vault_session.dart';
import '../budget/budget_repository.dart' show derivedIdNamespace;
import '../pantry/pantry_repository.dart';

const checkupKinds = ['checkup', 'vaccine'];

/// Ledger category and `source_type`s of health costs.
const healthCategory = 'health';
const medicineSource = 'medicine';
const checkupSource = 'checkup';

/// A medicine expiring this close counts as expiring soon.
const expirySoonDays = 30;

String _derived(String name) => const Uuid().v5(derivedIdNamespace, name);

/// The one profile row of [memberId], the same on every device.
String healthProfileId(String householdId, String memberId) => _derived('health_profiles/$householdId/$memberId');

/// A scheduled dose, the same on every device (sync-protocol §2.1).
String scheduledDoseId(String householdId, String medicineId, String day, String slot) =>
    _derived('med_doses/$householdId/$medicineId/$day/$slot');

/// The ledger entry of a checkup's cost.
String checkupLedgerId(String householdId, String checkupId) =>
    _derived('transactions/$householdId/checkup/$checkupId');

String _profileAad(String id) => 'homesync/health_profiles/$id/sealed';

/// `HH:MM` dose times of [times] ("08:00,20:00"), sorted; empty = as needed.
List<String> parseTimes(String? times) {
  if (times == null) return const [];
  final out = <String>[];
  for (final t in times.split(',')) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t.trim());
    if (m == null) continue;
    final h = int.parse(m[1]!), min = int.parse(m[2]!);
    if (h > 23 || min > 59) continue;
    out.add('${h.toString().padLeft(2, '0')}:${m[2]}');
  }
  return out.toSet().toList()..sort();
}

bool isLowMedicine(Medicine m) => m.minStock != null && m.stock <= m.minStock!;

bool expiresSoon(Medicine m, DateTime today) {
  final on = parseIsoDate(m.expiresOn);
  return on != null && daysUntil(on, today) <= expirySoonDays;
}

/// Whether [m] is still being taken on [day].
bool isActive(Medicine m, DateTime day) {
  final end = parseIsoDate(m.endsOn);
  return end == null || daysUntil(end, day) >= 0;
}

/// The sealed part of a health profile.
class HealthFields {
  const HealthFields({
    this.bloodType,
    this.allergies,
    this.conditions,
    this.maintenance,
    this.philhealth,
    this.hmo,
    this.doctor,
    this.note,
  });

  factory HealthFields.fromJson(Map<String, Object?> j) => HealthFields(
    bloodType: j['blood_type'] as String?,
    allergies: j['allergies'] as String?,
    conditions: j['conditions'] as String?,
    maintenance: j['maintenance'] as String?,
    philhealth: j['philhealth'] as String?,
    hmo: j['hmo'] as String?,
    doctor: j['doctor'] as String?,
    note: j['note'] as String?,
  );

  final String? bloodType;
  final String? allergies;
  final String? conditions;
  final String? maintenance;
  final String? philhealth;
  final String? hmo;
  final String? doctor;
  final String? note;

  Map<String, Object?> toJson() => {
    'blood_type': ?_blank(bloodType),
    'allergies': ?_blank(allergies),
    'conditions': ?_blank(conditions),
    'maintenance': ?_blank(maintenance),
    'philhealth': ?_blank(philhealth),
    'hmo': ?_blank(hmo),
    'doctor': ?_blank(doctor),
    'note': ?_blank(note),
  };

  bool get isEmpty => toJson().isEmpty;

  static String? _blank(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}

/// One scheduled dose today and, once given, its record.
class DoseSlot {
  const DoseSlot(this.medicine, this.slot, this.dose);

  final Medicine medicine;
  final String slot;
  final MedDose? dose;

  bool get taken => dose != null;
}

/// Today's doses, what is running low or expiring, and checkups coming up.
class HealthSummary {
  HealthSummary({
    required List<Medicine> medicines,
    required List<MedDose> doses,
    required List<Checkup> checkups,
    required DateTime today,
  }) {
    final day = isoDate(today);
    final given = {
      for (final d in doses)
        if (d.takenOn == day && d.slot != null) '${d.medicineId}/${d.slot}': d,
    };
    for (final m in medicines) {
      if (isLowMedicine(m)) low.add(m);
      if (expiresSoon(m, today)) expiring.add(m);
      if (!isActive(m, today)) continue;
      for (final s in parseTimes(m.times)) {
        slots.add(DoseSlot(m, s, given['${m.id}/$s']));
      }
    }
    slots.sort((a, b) {
      final t = a.slot.compareTo(b.slot);
      return t != 0 ? t : a.medicine.name.toLowerCase().compareTo(b.medicine.name.toLowerCase());
    });
    upcoming.addAll(checkups.where((c) => c.doneAt == null && c.dueOn != null));
    upcoming.sort((a, b) => a.dueOn!.compareTo(b.dueOn!));
  }

  final slots = <DoseSlot>[];
  final low = <Medicine>[];
  final expiring = <Medicine>[];
  final upcoming = <Checkup>[];

  int get left => slots.where((s) => !s.taken).length;

  /// The first dose today not yet given.
  DoseSlot? get next => slots.where((s) => !s.taken).firstOrNull;
}

/// Health: medicines and their doses, checkups and vaccines, and each
/// member's profile, sealed with the vault key (docs/vault.md).
class HealthRepository {
  HealthRepository(this.db, this.writer, {required this.session, required this.crypto, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final VaultSession session;
  final VaultCrypto crypto;
  final DateTime Function() _now;

  DateTime get now => _now();
  DateTime get today {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  String get _household => writer.identity.householdId;
  String get _me => writer.identity.memberId;

  // -------------------------------------------------------------- medicines

  Stream<List<Medicine>> watchMedicines() =>
      (db.select(db.medicines)
            ..where((m) => m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm.asc(m.name)]))
          .watch();

  Stream<Medicine?> watchMedicine(String id) =>
      (db.select(db.medicines)..where((m) => m.id.equals(id) & m.deletedAt.isNull())).watchSingleOrNull();

  /// Doses given today and yesterday (enough for today's list).
  Stream<List<MedDose>> watchRecentDoses() {
    final since = isoDate(today.subtract(const Duration(days: 1)));
    return (db.select(db.medDoses)..where((d) => d.deletedAt.isNull() & d.takenOn.isBiggerOrEqualValue(since))).watch();
  }

  /// One medicine's doses, latest first.
  Stream<List<MedDose>> watchDoses(String medicineId, {int limit = 30}) =>
      (db.select(db.medDoses)
            ..where((d) => d.deletedAt.isNull() & d.medicineId.equals(medicineId))
            ..orderBy([(d) => OrderingTerm.desc(d.takenOn), (d) => OrderingTerm.desc(d.slot)])
            ..limit(limit))
          .watch();

  Future<String> addMedicine({
    required String name,
    String? strength,
    String? memberId,
    String? times,
    double doseQty = 1,
    DateTime? endsOn,
    double stock = 0,
    double? minStock,
    String? unit,
    DateTime? expiresOn,
    String? note,
  }) => writer.insert('medicines', {
    'name': name.trim(),
    'strength': _blankToNull(strength),
    'member_id': memberId,
    'times': _times(times),
    'dose_qty': doseQty,
    'ends_on': _iso(endsOn),
    'stock': stock,
    'min_stock': minStock,
    'unit': _blankToNull(unit),
    'expires_on': _iso(expiresOn),
    'note': _blankToNull(note),
  });

  /// Saves only what changed. Stock changes through [restock] and [stockTake].
  Future<void> editMedicine(
    Medicine m, {
    required String name,
    String? strength,
    String? memberId,
    String? times,
    double doseQty = 1,
    DateTime? endsOn,
    double? minStock,
    String? unit,
    DateTime? expiresOn,
    String? note,
  }) => writer.update('medicines', m.id, {
    if (name.trim() != m.name) 'name': name.trim(),
    if (_blankToNull(strength) != m.strength) 'strength': _blankToNull(strength),
    if (memberId != m.memberId) 'member_id': memberId,
    if (_times(times) != m.times) 'times': _times(times),
    if (doseQty != m.doseQty) 'dose_qty': doseQty,
    if (_iso(endsOn) != m.endsOn) 'ends_on': _iso(endsOn),
    if (minStock != m.minStock) 'min_stock': minStock,
    if (_blankToNull(unit) != m.unit) 'unit': _blankToNull(unit),
    if (_iso(expiresOn) != m.expiresOn) 'expires_on': _iso(expiresOn),
    if (_blankToNull(note) != m.note) 'note': _blankToNull(note),
  });

  Future<void> removeMedicine(String id) => writer.delete('medicines', id);

  /// Records a dose of [m] given by this profile and takes it from stock. A
  /// scheduled dose ([slot]) already given today is left alone.
  Future<void> giveDose(Medicine m, {String? slot}) async {
    final day = isoDate(today);
    final id = slot == null ? null : scheduledDoseId(_household, m.id, day, slot);
    if (id != null) {
      final existing = await (db.select(db.medDoses)..where((d) => d.id.equals(id))).getSingleOrNull();
      if (existing != null && existing.deletedAt == null) return;
      if (existing != null) {
        // Given, undone, now given again: a fresh id (the hub keeps the first insert).
        return _dose(m, day, slot, null);
      }
    }
    await _dose(m, day, slot, id);
  }

  Future<void> _dose(Medicine m, String day, String? slot, String? id) async {
    await writer.insert('med_doses', {
      'medicine_id': m.id,
      'member_id': m.memberId,
      'given_by': _me,
      'taken_on': day,
      'slot': slot,
      'taken_at': now.toUtc(),
    }, id: id);
    await writer.increment('medicines', m.id, {'stock': -m.doseQty});
  }

  /// Only the person who gave a dose undoes it.
  bool canUndo(MedDose d) => d.givenBy == _me;

  Future<void> undoDose(MedDose d) async {
    await writer.delete('med_doses', d.id);
    final m = await (db.select(db.medicines)..where((x) => x.id.equals(d.medicineId))).getSingleOrNull();
    if (m != null) await writer.increment('medicines', m.id, {'stock': m.doseQty});
  }

  /// Adds [qty] to stock; a [costMinor] is a health expense in the ledger.
  Future<void> restock(Medicine m, double qty, {int? costMinor}) async {
    await writer.increment('medicines', m.id, {'stock': qty});
    if (costMinor != null && costMinor > 0) {
      await writer.insert('transactions', {
        'amount_minor': -costMinor,
        'category': healthCategory,
        'currency': 'PHP',
        'occurred_at': now.toUtc(),
        'member_id': _me,
        'source_type': medicineSource,
        'source_id': m.id,
        'note': m.name,
      });
    }
  }

  /// Sets stock to what was counted by sending the difference, so doses given
  /// elsewhere meanwhile still count.
  Future<void> stockTake(Medicine m, double counted) async {
    final fresh = await (db.select(db.medicines)..where((x) => x.id.equals(m.id))).getSingle();
    final diff = counted - fresh.stock;
    if (diff != 0) await writer.increment('medicines', m.id, {'stock': diff});
  }

  /// Puts [m] on the grocery list unless it is already there; false if it was.
  Future<bool> addToGroceryList(Medicine m) {
    final name = [m.name, ?m.strength].join(' ');
    return PantryRepository(db, writer, now: _now).addToGroceryByName(name);
  }

  // --------------------------------------------------------------- checkups

  Stream<List<Checkup>> watchCheckups() =>
      (db.select(db.checkups)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm(expression: c.dueOn.isNull()), (c) => OrderingTerm.asc(c.dueOn)]))
          .watch();

  Future<String> addCheckup({
    required String kind,
    required String title,
    String? memberId,
    DateTime? dueOn,
    String? dueTime,
    String? place,
    String? note,
  }) => writer.insert('checkups', {
    'kind': kind,
    'title': title.trim(),
    'member_id': memberId,
    'due_on': _iso(dueOn),
    'due_time': _blankToNull(dueTime),
    'place': _blankToNull(place),
    'note': _blankToNull(note),
  });

  Future<void> editCheckup(
    Checkup c, {
    required String kind,
    required String title,
    String? memberId,
    DateTime? dueOn,
    String? dueTime,
    String? place,
    String? note,
  }) => writer.update('checkups', c.id, {
    if (kind != c.kind) 'kind': kind,
    if (title.trim() != c.title) 'title': title.trim(),
    if (memberId != c.memberId) 'member_id': memberId,
    if (_iso(dueOn) != c.dueOn) 'due_on': _iso(dueOn),
    if (_blankToNull(dueTime) != c.dueTime) 'due_time': _blankToNull(dueTime),
    if (_blankToNull(place) != c.place) 'place': _blankToNull(place),
    if (_blankToNull(note) != c.note) 'note': _blankToNull(note),
  });

  Future<void> removeCheckup(String id) => writer.delete('checkups', id);

  /// Marks it done; a [costMinor] is a health expense in the ledger.
  Future<void> markDone(Checkup c, {int? costMinor}) async {
    await writer.update('checkups', c.id, {'done_at': now.toUtc(), 'done_by': _me});
    if (costMinor != null && costMinor > 0) {
      await writer.insert('transactions', {
        'amount_minor': -costMinor,
        'category': healthCategory,
        'currency': 'PHP',
        'occurred_at': now.toUtc(),
        'member_id': _me,
        'source_type': checkupSource,
        'source_id': c.id,
        'note': c.title,
      }, id: checkupLedgerId(_household, c.id));
    }
  }

  bool canUndoDone(Checkup c) => c.doneAt != null && c.doneBy == _me;

  Future<void> undoDone(Checkup c) async {
    await writer.update('checkups', c.id, {'done_at': null, 'done_by': null});
    final ledgerId = checkupLedgerId(_household, c.id);
    final entry = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(ledgerId) & t.deletedAt.isNull())).getSingleOrNull();
    if (entry != null) await writer.delete('transactions', ledgerId);
  }

  // --------------------------------------------------------------- profiles

  Stream<List<HealthProfile>> watchProfiles() =>
      (db.select(db.healthProfiles)..where((p) => p.deletedAt.isNull())).watch();

  Uint8List get _key {
    final k = session.key;
    if (k == null) throw StateError('the vault is locked');
    return k;
  }

  /// The profile's fields, or null if the vault is locked or the key can't
  /// open it.
  Future<HealthFields?> openProfile(HealthProfile p) async {
    if (session.key == null) return null;
    try {
      final json = await crypto.openJson(_key, p.sealed, _profileAad(p.id));
      return json is Map ? HealthFields.fromJson(json.cast()) : null;
    } on VaultDecryptError {
      return null;
    }
  }

  /// Seals [fields] as [memberId]'s profile (the vault must be open).
  Future<void> saveProfile(String memberId, HealthFields fields) async {
    final id = healthProfileId(_household, memberId);
    final sealed = await crypto.sealJson(_key, fields.toJson(), _profileAad(id));
    final existing = await (db.select(db.healthProfiles)..where((p) => p.id.equals(id))).getSingleOrNull();
    if (existing == null) {
      await writer.insert('health_profiles', {'member_id': memberId, 'sealed': sealed}, id: id);
    } else {
      await writer.update('health_profiles', id, {'sealed': sealed});
    }
  }

  static String? _times(String? s) {
    final t = parseTimes(s);
    return t.isEmpty ? null : t.join(',');
  }

  static String? _iso(DateTime? d) => d == null ? null : isoDate(d);
  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}
