import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../budget/budget_repository.dart' show derivedIdNamespace, incomeCategory;

/// [RentPayments.kind]: money received, or rent forgiven (no money).
const rentPaymentKind = 'payment';
const rentWaivedKind = 'waived';

/// How a payment came in (optional), in the order the app offers them.
const rentMethods = ['cash', 'gcash', 'bank'];

/// Ledger `source_type` of rent received (category [incomeCategory]).
const rentSource = 'rent';

/// Rent due this close counts as due soon.
const rentSoonDays = 7;

/// The ledger entry of a rent payment, the same on every device.
String rentPaymentLedgerId(String householdId, String paymentId) =>
    const Uuid().v5(derivedIdNamespace, 'transactions/$householdId/rent/$paymentId');

/// The first day of [d]'s month.
DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

/// The due date of [lease] in [month]: its due day, or the month's last day.
DateTime rentDueIn(Lease lease, DateTime month) {
  final last = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(month.year, month.month, lease.dueDay > last ? last : lease.dueDay);
}

/// The rent of [lease] for [month] (before [Lease.rentSince], the old rent).
int rentFor(Lease lease, DateTime month) {
  final since = parseIsoDate(lease.rentSince);
  if (since != null && month.isBefore(monthOf(since))) return lease.prevRentMinor ?? lease.rentMinor;
  return lease.rentMinor;
}

/// Whether [lease] is still running on [today].
bool leaseActive(Lease lease, DateTime today) {
  final ends = parseIsoDate(lease.endsOn);
  return ends == null || daysUntil(ends, today) >= 0;
}

enum RentDue { overdue, soon, later, paid }

/// Where one lease stands: the rent due up to this month, what was paid, and
/// the oldest month not fully paid. Payments cover the oldest month first.
class LeaseStatus {
  factory LeaseStatus.of(Lease lease, Iterable<RentPayment> payments, DateTime today) {
    var received = 0;
    RentPayment? last;
    for (final p in payments) {
      if (p.leaseId != lease.id) continue;
      received += p.amountMinor;
      if (p.kind == rentPaymentKind && (last == null || p.paidOn.compareTo(last.paidOn) > 0)) last = p;
    }
    final start = parseIsoDate(lease.startsOn) ?? today;
    final ends = parseIsoDate(lease.endsOn);
    var until = monthOf(today);
    if (ends != null && monthOf(ends).isBefore(until)) until = monthOf(ends);

    var dueSoFar = 0;
    var left = received;
    DateTime? oldest;
    int? oldestLeft;
    for (var m = monthOf(start); !m.isAfter(until); m = DateTime(m.year, m.month + 1)) {
      final rent = rentFor(lease, m);
      dueSoFar += rent;
      if (oldest != null) continue;
      if (left >= rent) {
        left -= rent;
      } else {
        oldest = rentDueIn(lease, m);
        oldestLeft = rent - left;
        left = 0;
      }
    }
    return LeaseStatus._(lease, dueSoFar, received, oldest, oldestLeft, last, today);
  }

  LeaseStatus._(this.lease, this.dueSoFar, this.received, this.oldestDue, this.oldestLeft, this.lastPayment, DateTime today)
    : daysLate = oldestDue == null ? 0 : -daysUntil(oldestDue, today);

  final Lease lease;

  /// Rent due from move-in through this month (or the move-out month).
  final int dueSoFar;

  /// Everything paid or waived.
  final int received;

  /// Due date of the oldest month not fully paid, and what is left of it.
  final DateTime? oldestDue;
  final int? oldestLeft;
  final RentPayment? lastPayment;

  /// Days past [oldestDue] (negative while it is still ahead).
  final int daysLate;

  int get owed => dueSoFar > received ? dueSoFar - received : 0;

  /// Paid ahead of this month.
  int get credit => received > dueSoFar ? received - dueSoFar : 0;

  /// Part of the oldest month already paid.
  bool get partlyPaid => oldestLeft != null && oldestLeft! < rentFor(lease, monthOf(oldestDue!));

  RentDue get due {
    if (owed == 0) return RentDue.paid;
    if (daysLate > 0) return RentDue.overdue;
    return -daysLate <= rentSoonDays ? RentDue.soon : RentDue.later;
  }
}

/// A unit with its current tenant (null = vacant).
class UnitRow {
  const UnitRow(this.unit, this.status);
  final RentalUnit unit;
  final LeaseStatus? status;
}

/// Everything the Rent screen shows.
class RentSummary {
  RentSummary(List<RentalUnit> units, List<Lease> leases, List<RentPayment> payments, DateTime today) {
    final liveUnits = {for (final u in units) u.id: u};
    for (final l in leases) {
      final unit = liveUnits[l.unitId];
      if (unit == null) continue;
      final s = LeaseStatus.of(l, payments, today);
      final active = leaseActive(l, today);
      if (active) {
        current[unit.id] = s;
        activeCount++;
        if (s.owed == 0) paid.add(UnitRow(unit, s));
      }
      if (s.owed > 0) {
        toCollect.add(UnitRow(unit, s));
        totalOwed += s.owed;
        if (s.due == RentDue.overdue) overdueCount++;
      }
    }
    for (final u in units) {
      if (!current.containsKey(u.id)) vacant.add(u);
    }
    toCollect.sort((a, b) {
      final d = a.status!.oldestDue!.compareTo(b.status!.oldestDue!);
      return d != 0 ? d : a.unit.name.toLowerCase().compareTo(b.unit.name.toLowerCase());
    });
    paid.sort((a, b) => a.unit.name.toLowerCase().compareTo(b.unit.name.toLowerCase()));
  }

  /// Leases with something owed (moved-out tenants too), oldest due first.
  final toCollect = <UnitRow>[];

  /// Current tenants paid up through this month.
  final paid = <UnitRow>[];
  final vacant = <RentalUnit>[];

  /// The current lease of each occupied unit.
  final current = <String, LeaseStatus>{};
  int totalOwed = 0;
  int activeCount = 0;
  int overdueCount = 0;

  bool get isEmpty => current.isEmpty && vacant.isEmpty && toCollect.isEmpty;
}

/// Rent the household collects. Units stay while vacant; a lease is one
/// tenant; payments are append-only [RentPayment] rows, and money received
/// also posts income to the ledger with an id derived from the payment.
class RentRepository {
  RentRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today => _now();
  String get _household => writer.identity.householdId;
  String get _me => writer.identity.memberId;

  Stream<List<RentalUnit>> watchUnits() =>
      (db.select(db.rentalUnits)
            ..where((u) => u.deletedAt.isNull())
            ..orderBy([(u) => OrderingTerm.asc(u.name)]))
          .watch();

  Stream<List<Lease>> watchLeases() => (db.select(db.leases)..where((l) => l.deletedAt.isNull())).watch();

  Stream<List<RentPayment>> watchPayments() =>
      (db.select(db.rentPayments)..where((p) => p.deletedAt.isNull())).watch();

  /// One lease's payments, latest first.
  Stream<List<RentPayment>> watchHistory(String leaseId) =>
      (db.select(db.rentPayments)
            ..where((p) => p.deletedAt.isNull() & p.leaseId.equals(leaseId))
            ..orderBy([(p) => OrderingTerm.desc(p.paidOn), (p) => OrderingTerm.desc(p.createdAt)]))
          .watch();

  Future<String> addUnit(String name, {String? note}) =>
      writer.insert('rental_units', {'name': name.trim(), 'note': _blankToNull(note)});

  Future<void> editUnit(RentalUnit u, {required String name, String? note}) => writer.update('rental_units', u.id, {
    if (name.trim() != u.name) 'name': name.trim(),
    if (_blankToNull(note) != u.note) 'note': _blankToNull(note),
  });

  Future<void> removeUnit(String id) => writer.delete('rental_units', id);

  /// Moves a tenant into [unitId].
  Future<String> addLease({
    required String unitId,
    required String tenantName,
    String? phone,
    required int rentMinor,
    required int dueDay,
    required DateTime startsOn,
    int? depositMinor,
    String? note,
  }) => writer.insert('leases', {
    'unit_id': unitId,
    'tenant_name': tenantName.trim(),
    'phone': _blankToNull(phone),
    'rent_minor': rentMinor,
    'currency': 'PHP',
    'due_day': dueDay,
    'starts_on': isoDate(startsOn),
    'deposit_minor': depositMinor,
    'note': _blankToNull(note),
  });

  /// Saves only what changed. A new rent applies from this month; earlier
  /// months keep the old one.
  Future<void> editLease(
    Lease l, {
    required String tenantName,
    String? phone,
    required int rentMinor,
    required int dueDay,
    required DateTime startsOn,
    int? depositMinor,
    String? note,
  }) {
    final changes = <String, Object?>{
      if (tenantName.trim() != l.tenantName) 'tenant_name': tenantName.trim(),
      if (_blankToNull(phone) != l.phone) 'phone': _blankToNull(phone),
      if (dueDay != l.dueDay) 'due_day': dueDay,
      if (isoDate(startsOn) != l.startsOn) 'starts_on': isoDate(startsOn),
      if (depositMinor != l.depositMinor) 'deposit_minor': depositMinor,
      if (_blankToNull(note) != l.note) 'note': _blankToNull(note),
    };
    if (rentMinor != l.rentMinor) {
      changes['rent_minor'] = rentMinor;
      final thisMonth = monthOf(today);
      final start = monthOf(parseIsoDate(isoDate(startsOn)) ?? thisMonth);
      if (start.isBefore(thisMonth)) {
        // Months before this one keep the rent they had.
        changes['prev_rent_minor'] = rentFor(l, DateTime(thisMonth.year, thisMonth.month - 1));
        changes['rent_since'] = isoDate(thisMonth);
      } else if (l.rentSince != null) {
        changes['prev_rent_minor'] = null;
        changes['rent_since'] = null;
      }
    }
    return writer.update('leases', l.id, changes);
  }

  /// The tenant leaves on [endsOn]; [depositReturnedMinor] (may be less than
  /// the deposit, or 0) is recorded when given.
  Future<void> moveOut(Lease l, DateTime endsOn, {int? depositReturnedMinor}) =>
      writer.update('leases', l.id, {
        'ends_on': isoDate(endsOn),
        if (depositReturnedMinor != null) 'deposit_returned_minor': depositReturnedMinor,
        if (depositReturnedMinor != null) 'deposit_returned_on': isoDate(today),
      });

  /// Undoes a move-out recorded by mistake.
  Future<void> undoMoveOut(Lease l) => writer.update('leases', l.id, {
    'ends_on': null,
    'deposit_returned_minor': null,
    'deposit_returned_on': null,
  });

  Future<void> removeLease(String id) => writer.delete('leases', id);

  /// Records money received and posts it to the ledger as income.
  Future<String> recordPayment(
    Lease l,
    String unitName,
    int amountMinor, {
    DateTime? paidOn,
    String? method,
    String? note,
  }) async {
    final on = paidOn ?? today;
    final id = await writer.insert('rent_payments', {
      'lease_id': l.id,
      'kind': rentPaymentKind,
      'amount_minor': amountMinor,
      'currency': 'PHP',
      'paid_on': isoDate(on),
      'method': method,
      'member_id': _me,
      'note': _blankToNull(note),
    });
    final sameDay = daysUntil(on, today) == 0;
    await writer.insert('transactions', {
      'amount_minor': amountMinor,
      'category': incomeCategory,
      'currency': 'PHP',
      'occurred_at': (sameDay ? today : DateTime(on.year, on.month, on.day, 12)).toUtc(),
      'member_id': _me,
      'source_type': rentSource,
      'source_id': l.id,
      'note': '$unitName · ${l.tenantName}',
    }, id: rentPaymentLedgerId(_household, id));
    return id;
  }

  /// Forgives [amountMinor] of what [l] owes (no money, no ledger entry).
  Future<String> waive(Lease l, int amountMinor, {String? note}) => writer.insert('rent_payments', {
    'lease_id': l.id,
    'kind': rentWaivedKind,
    'amount_minor': amountMinor,
    'currency': 'PHP',
    'paid_on': isoDate(today),
    'member_id': _me,
    'note': _blankToNull(note),
  });

  /// Only the person who recorded a payment removes it (with its ledger entry).
  bool canRemove(RentPayment p) => p.memberId == _me;

  Future<void> removePayment(RentPayment p) async {
    await writer.delete('rent_payments', p.id);
    final ledgerId = rentPaymentLedgerId(_household, p.id);
    final entry = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(ledgerId) & t.deletedAt.isNull())).getSingleOrNull();
    if (entry != null) await writer.delete('transactions', ledgerId);
  }

  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}
