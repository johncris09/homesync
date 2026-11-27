import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../budget/budget_repository.dart' show derivedIdNamespace;

const vehicleKinds = ['car', 'motorcycle'];

/// Kinds of [VehicleLog] that cost money (in the order the app offers them).
const costKinds = ['fuel', 'pms', 'repair', 'registration', 'insurance'];

/// A [VehicleLog] that is only an odometer reading.
const odometerKind = 'odometer';

/// What can be due on a vehicle.
const dueKinds = ['registration', 'insurance', 'pms'];

/// Ledger category and `source_type` of vehicle costs.
const vehicleCategory = 'transport';
const vehicleSource = 'vehicle';

/// A date this close (or a PMS this many km away) counts as due soon.
const vehicleSoonDays = 14;
const pmsSoonKm = 500;

/// Registration or insurance paid this close to the due date (or later)
/// moves it one year on; paid earlier, it was for something else.
const renewWindowDays = 60;

/// The ledger entry of a vehicle cost, the same on every device.
String vehicleLogLedgerId(String householdId, String logId) =>
    const Uuid().v5(derivedIdNamespace, 'transactions/$householdId/vehicle/$logId');

/// The highest odometer reading in [logs] for [vehicleId], or null.
int? odometerOf(String vehicleId, Iterable<VehicleLog> logs) {
  int? best;
  for (final l in logs) {
    if (l.vehicleId != vehicleId || l.odometerKm == null) continue;
    if (best == null || l.odometerKm! > best) best = l.odometerKm;
  }
  return best;
}

enum VehicleDue { overdue, soon, later }

/// One thing due on one vehicle: registration, insurance or PMS.
class DueItem {
  const DueItem({
    required this.vehicle,
    required this.kind,
    required this.status,
    this.on,
    this.km,
    this.kmLeft,
  });

  final Vehicle vehicle;

  /// `registration`, `insurance` or `pms`.
  final String kind;
  final VehicleDue status;
  final DateTime? on;

  /// PMS odometer reading, and how far away it is (negative = past it).
  final int? km;
  final int? kmLeft;
}

/// The due items of [v]; PMS is due at its date or reading, whichever first.
List<DueItem> dueItemsOf(Vehicle v, int? odometer, DateTime today) {
  VehicleDue byDate(DateTime on) {
    final days = daysUntil(on, today);
    if (days < 0) return VehicleDue.overdue;
    return days <= vehicleSoonDays ? VehicleDue.soon : VehicleDue.later;
  }

  final out = <DueItem>[];
  for (final (kind, due) in [('registration', v.registrationDueOn), ('insurance', v.insuranceDueOn)]) {
    final on = parseIsoDate(due);
    if (on != null) out.add(DueItem(vehicle: v, kind: kind, status: byDate(on), on: on));
  }
  final pmsOn = parseIsoDate(v.pmsDueOn);
  final kmLeft = v.pmsDueKm == null || odometer == null ? null : v.pmsDueKm! - odometer;
  if (pmsOn != null || v.pmsDueKm != null) {
    final byKm = kmLeft == null
        ? VehicleDue.later
        : kmLeft <= 0
        ? VehicleDue.overdue
        : kmLeft <= pmsSoonKm
        ? VehicleDue.soon
        : VehicleDue.later;
    final dated = pmsOn == null ? VehicleDue.later : byDate(pmsOn);
    final status = byKm.index < dated.index ? byKm : dated;
    out.add(DueItem(vehicle: v, kind: 'pms', status: status, on: pmsOn, km: v.pmsDueKm, kmLeft: kmLeft));
  }
  return out;
}

/// Every vehicle's due items, most urgent first, plus odometers and what was
/// spent this month.
class VehiclesSummary {
  VehiclesSummary(List<Vehicle> vehicles, List<VehicleLog> logs, DateTime today) {
    for (final v in vehicles) {
      final odo = odometerOf(v.id, logs);
      if (odo != null) odometers[v.id] = odo;
      due.addAll(dueItemsOf(v, odo, today));
    }
    due.sort((a, b) {
      final s = a.status.index - b.status.index;
      if (s != 0) return s;
      if (a.on != null && b.on != null) {
        final d = a.on!.compareTo(b.on!);
        if (d != 0) return d;
      } else if (a.on != b.on) {
        // Within a status, dated items first; a km-only PMS sorts by km left.
        return a.on == null ? 1 : -1;
      } else if (a.kmLeft != null && b.kmLeft != null && a.kmLeft != b.kmLeft) {
        return a.kmLeft!.compareTo(b.kmLeft!);
      }
      return a.vehicle.name.toLowerCase().compareTo(b.vehicle.name.toLowerCase());
    });
    final month = isoDate(DateTime(today.year, today.month)).substring(0, 7);
    final live = {for (final v in vehicles) v.id};
    for (final l in logs) {
      if (l.amountMinor != null && live.contains(l.vehicleId) && l.loggedOn.startsWith(month)) {
        monthSpent += l.amountMinor!;
      }
    }
  }

  final due = <DueItem>[];
  final odometers = <String, int>{};
  int monthSpent = 0;

  int get overdue => due.where((d) => d.status == VehicleDue.overdue).length;

  /// The most urgent thing due, if any.
  DueItem? get next => due.isEmpty ? null : due.first;
}

/// Vehicles. Costs and odometer readings are append-only [VehicleLog] rows;
/// every cost also posts an expense to the ledger (category `transport`) with
/// an id derived from the log, so removing the log can find it.
class VehiclesRepository {
  VehiclesRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today => _now();
  String get _household => writer.identity.householdId;
  String get _me => writer.identity.memberId;

  Stream<List<Vehicle>> watchVehicles() =>
      (db.select(db.vehicles)
            ..where((v) => v.deletedAt.isNull())
            ..orderBy([(v) => OrderingTerm.asc(v.name)]))
          .watch();

  Stream<Vehicle?> watchVehicle(String id) =>
      (db.select(db.vehicles)..where((v) => v.id.equals(id) & v.deletedAt.isNull())).watchSingleOrNull();

  /// Every live log (for odometers and this month's spending).
  Stream<List<VehicleLog>> watchLogs() => (db.select(db.vehicleLogs)..where((l) => l.deletedAt.isNull())).watch();

  /// One vehicle's history, latest first.
  Stream<List<VehicleLog>> watchHistory(String vehicleId) =>
      (db.select(db.vehicleLogs)
            ..where((l) => l.deletedAt.isNull() & l.vehicleId.equals(vehicleId))
            ..orderBy([(l) => OrderingTerm.desc(l.loggedOn), (l) => OrderingTerm.desc(l.createdAt)]))
          .watch();

  /// Adds a vehicle; [odometerKm] is recorded as its first reading.
  Future<String> addVehicle({
    required String kind,
    required String name,
    String? plate,
    String? color,
    DateTime? registrationDueOn,
    DateTime? insuranceDueOn,
    DateTime? pmsDueOn,
    int? pmsDueKm,
    int? pmsEveryMonths,
    int? pmsEveryKm,
    int? odometerKm,
    String? note,
  }) async {
    final id = await writer.insert('vehicles', {
      'kind': kind,
      'name': name.trim(),
      'plate': _blankToNull(plate),
      'color': _blankToNull(color),
      'registration_due_on': _iso(registrationDueOn),
      'insurance_due_on': _iso(insuranceDueOn),
      'pms_due_on': _iso(pmsDueOn),
      'pms_due_km': pmsDueKm,
      'pms_every_months': pmsEveryMonths,
      'pms_every_km': pmsEveryKm,
      'note': _blankToNull(note),
    });
    if (odometerKm != null) await _reading(id, odometerKm);
    return id;
  }

  /// Saves only what changed.
  Future<void> editVehicle(
    Vehicle v, {
    required String name,
    String? plate,
    String? color,
    DateTime? registrationDueOn,
    DateTime? insuranceDueOn,
    DateTime? pmsDueOn,
    int? pmsDueKm,
    int? pmsEveryMonths,
    int? pmsEveryKm,
    String? note,
  }) => writer.update('vehicles', v.id, {
    if (name.trim() != v.name) 'name': name.trim(),
    if (_blankToNull(plate) != v.plate) 'plate': _blankToNull(plate),
    if (_blankToNull(color) != v.color) 'color': _blankToNull(color),
    if (_iso(registrationDueOn) != v.registrationDueOn) 'registration_due_on': _iso(registrationDueOn),
    if (_iso(insuranceDueOn) != v.insuranceDueOn) 'insurance_due_on': _iso(insuranceDueOn),
    if (_iso(pmsDueOn) != v.pmsDueOn) 'pms_due_on': _iso(pmsDueOn),
    if (pmsDueKm != v.pmsDueKm) 'pms_due_km': pmsDueKm,
    if (pmsEveryMonths != v.pmsEveryMonths) 'pms_every_months': pmsEveryMonths,
    if (pmsEveryKm != v.pmsEveryKm) 'pms_every_km': pmsEveryKm,
    if (_blankToNull(note) != v.note) 'note': _blankToNull(note),
  });

  Future<void> removeVehicle(String id) => writer.delete('vehicles', id);

  /// Records a cost ([kind] one of [costKinds]) and posts it to the ledger.
  ///
  /// Registration or insurance moves that due date one year on when it was
  /// due within [renewWindowDays], overdue, or not set. A PMS sets the next
  /// date and reading from the vehicle's PMS interval.
  Future<String> logCost(
    Vehicle v,
    String kind,
    int amountMinor, {
    int? odometerKm,
    double? litres,
    String? note,
  }) async {
    assert(costKinds.contains(kind));
    final logId = await writer.insert('vehicle_logs', {
      'vehicle_id': v.id,
      'kind': kind,
      'amount_minor': amountMinor,
      'currency': 'PHP',
      'logged_on': isoDate(today),
      'odometer_km': odometerKm,
      'litres': kind == 'fuel' ? litres : null,
      'member_id': _me,
      'note': _blankToNull(note),
    });
    await writer.insert('transactions', {
      'amount_minor': -amountMinor,
      'category': vehicleCategory,
      'currency': 'PHP',
      'occurred_at': today.toUtc(),
      'member_id': _me,
      'source_type': vehicleSource,
      'source_id': v.id,
      'note': v.name,
    }, id: vehicleLogLedgerId(_household, logId));

    final day = DateTime(today.year, today.month, today.day);
    final changes = <String, Object?>{};
    String? renewed(String? due) {
      final on = parseIsoDate(due);
      if (on == null) return isoDate(addMonths(day, 12));
      if (daysUntil(on, today) > renewWindowDays) return due; // paid early: leave it
      var next = addMonths(on, 12);
      while (next.isBefore(day)) {
        next = addMonths(next, 12); // years overdue: keep the same day of the year
      }
      return isoDate(next);
    }

    if (kind == 'registration') {
      final next = renewed(v.registrationDueOn);
      if (next != v.registrationDueOn) changes['registration_due_on'] = next;
    } else if (kind == 'insurance') {
      final next = renewed(v.insuranceDueOn);
      if (next != v.insuranceDueOn) changes['insurance_due_on'] = next;
    } else if (kind == 'pms') {
      if (v.pmsEveryMonths != null) {
        changes['pms_due_on'] = isoDate(addMonths(day, v.pmsEveryMonths!));
      }
      final reading = odometerKm ?? await odometer(v.id);
      if (v.pmsEveryKm != null && reading != null) changes['pms_due_km'] = reading + v.pmsEveryKm!;
    }
    if (changes.isNotEmpty) await writer.update('vehicles', v.id, changes);
    return logId;
  }

  /// Records an odometer reading with no cost.
  Future<String> logOdometer(Vehicle v, int km) => _reading(v.id, km);

  Future<String> _reading(String vehicleId, int km) => writer.insert('vehicle_logs', {
    'vehicle_id': vehicleId,
    'kind': odometerKind,
    'logged_on': isoDate(today),
    'odometer_km': km,
    'member_id': _me,
  });

  /// Only the person who recorded an entry removes it (with its ledger entry).
  bool canRemove(VehicleLog l) => l.memberId == _me;

  Future<void> removeLog(VehicleLog l) async {
    await writer.delete('vehicle_logs', l.id);
    final ledgerId = vehicleLogLedgerId(_household, l.id);
    final entry = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(ledgerId) & t.deletedAt.isNull())).getSingleOrNull();
    if (entry != null) await writer.delete('transactions', ledgerId);
  }

  Future<int?> odometer(String vehicleId) async {
    final logs = await (db.select(
      db.vehicleLogs,
    )..where((l) => l.deletedAt.isNull() & l.vehicleId.equals(vehicleId))).get();
    return odometerOf(vehicleId, logs);
  }

  static String? _iso(DateTime? d) => d == null ? null : isoDate(d);
  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}
