import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../budget/budget_repository.dart' show derivedIdNamespace;

/// Default budget categories for new bills and subscriptions.
const defaultBillCategory = 'utilities';
const defaultSubscriptionCategory = 'personal';

/// Days ahead that count as "due soon".
const dueSoonDays = 7;

enum DueStatus { overdue, soon, later, none }

DueStatus dueStatus(String? dueOn, DateTime today) {
  final on = parseIsoDate(dueOn);
  if (on == null) return DueStatus.none;
  final days = daysUntil(on, today);
  if (days < 0) return DueStatus.overdue;
  return days <= dueSoonDays ? DueStatus.soon : DueStatus.later;
}

/// Ledger `source_type` of bill and subscription payments.
const billSource = 'bill';
const subscriptionSource = 'subscription';

String _derived(String name) => const Uuid().v5(derivedIdNamespace, name);

/// Next occurrence of a monthly bill (sync-protocol §2.1).
String nextBillId(String householdId, String seriesId, String dueOn) => _derived('bills/$householdId/$seriesId/$dueOn');

/// The ledger entry of a bill payment, the same on every device.
String billPaymentId(String householdId, String billId) => _derived('transactions/$householdId/bill/$billId');

/// The ledger entry of one subscription payment.
String subscriptionPaymentId(String householdId, String subscriptionId, String dueOn) =>
    _derived('transactions/$householdId/subscription/$subscriptionId/$dueOn');

/// What a subscription costs per month (yearly ones spread over 12).
int monthlyCost(Iterable<Subscription> subs) =>
    subs.fold(0, (sum, s) => sum + (s.cycle == 'yearly' ? (s.priceMinor / 12).round() : s.priceMinor));

/// What is left to pay up to the end of [today]'s month.
class BillsSummary {
  BillsSummary(List<Bill> unpaid, List<Subscription> subs, DateTime today) {
    final monthEnd = DateTime(today.year, today.month + 1, 0);
    for (final b in unpaid) {
      final on = parseIsoDate(b.dueOn);
      if (on != null && !on.isAfter(monthEnd)) {
        due += b.amountMinor;
        count++;
        if (daysUntil(on, today) < 0) overdue++;
      }
    }
    for (final s in subs) {
      final on = parseIsoDate(s.nextDueOn);
      if (on != null && !on.isAfter(monthEnd)) {
        due += s.priceMinor;
        count++;
        if (daysUntil(on, today) < 0) overdue++;
      }
    }
    final dated = [
      for (final b in unpaid)
        if (b.dueOn != null) (name: b.name, dueOn: b.dueOn!),
      for (final s in subs)
        if (s.nextDueOn != null) (name: s.name, dueOn: s.nextDueOn!),
    ]..sort((a, b) => a.dueOn.compareTo(b.dueOn));
    next = dated.isEmpty ? null : dated.first;
  }

  /// Amount still to pay this month, overdue included.
  int due = 0;
  int count = 0;
  int overdue = 0;

  /// The earliest unpaid bill or subscription.
  ({String name, String dueOn})? next;
}

/// Bills and subscriptions. Paying posts an expense to the ledger with
/// `source_type`/`source_id`; ids of payments and of the next monthly bill
/// are derived so two devices paying offline record it once.
class BillsRepository {
  BillsRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today => _now();
  String get _household => writer.identity.householdId;

  // ---------------------------------------------------------------- bills

  /// Unpaid bills, soonest due first (no due date last).
  Stream<List<Bill>> watchUnpaid() =>
      (db.select(db.bills)
            ..where((b) => b.deletedAt.isNull() & b.isPaid.equals(false))
            ..orderBy([
              (b) => OrderingTerm(expression: b.dueOn.isNull()),
              (b) => OrderingTerm.asc(b.dueOn),
              (b) => OrderingTerm.asc(b.name),
            ]))
          .watch();

  /// Bills paid in the last [days] days, latest first.
  Stream<List<Bill>> watchPaid({int days = 45}) {
    final since = today.subtract(Duration(days: days)).toUtc();
    return (db.select(db.bills)
          ..where((b) => b.deletedAt.isNull() & b.isPaid.equals(true) & b.paidAt.isBiggerOrEqualValue(since))
          ..orderBy([(b) => OrderingTerm.desc(b.paidAt)]))
        .watch();
  }

  Future<String> addBill({
    required String name,
    required int amountMinor,
    required DateTime dueOn,
    String category = defaultBillCategory,
    bool monthly = false,
    String? provider,
  }) async {
    final id = const Uuid().v7();
    return writer.insert('bills', {
      'name': name.trim(),
      'provider': _blankToNull(provider),
      'amount_minor': amountMinor,
      'currency': 'PHP',
      'due_on': isoDate(dueOn),
      'category': category,
      'repeat': monthly ? 'monthly' : null,
      'series_id': monthly ? id : null,
    }, id: id);
  }

  /// Saves only what changed.
  Future<void> editBill(
    Bill b, {
    required String name,
    required int amountMinor,
    required DateTime dueOn,
    required String category,
    required bool monthly,
    String? provider,
  }) async {
    final fields = <String, Object?>{
      if (name.trim() != b.name) 'name': name.trim(),
      if (_blankToNull(provider) != b.provider) 'provider': _blankToNull(provider),
      if (amountMinor != b.amountMinor) 'amount_minor': amountMinor,
      if (isoDate(dueOn) != b.dueOn) 'due_on': isoDate(dueOn),
      if (category != b.category) 'category': category,
      if (monthly != (b.repeat == 'monthly')) 'repeat': monthly ? 'monthly' : null,
      if (monthly && b.seriesId == null) 'series_id': b.id,
    };
    await writer.update('bills', b.id, fields);
  }

  Future<void> removeBill(String id) => writer.delete('bills', id);

  /// Marks [b] paid with [amountMinor] (default: the bill's amount), records
  /// the expense, and for a monthly bill adds next month's.
  Future<void> payBill(Bill b, {int? amountMinor}) async {
    final paid = amountMinor ?? b.amountMinor;
    final now = today;
    if (paid != b.amountMinor) await writer.update('bills', b.id, {'amount_minor': paid});
    await writer.update('bills', b.id, {'is_paid': true, 'paid_at': now.toUtc()});

    final derived = billPaymentId(_household, b.id);
    // Re-paying after an undo: the derived entry exists (removed), so use a new id.
    final reused = await _exists(db.transactions, derived);
    await writer.insert('transactions', {
      'amount_minor': -paid,
      'category': b.category ?? defaultBillCategory,
      'currency': b.currency,
      'occurred_at': now.toUtc(),
      'member_id': writer.identity.memberId,
      'source_type': billSource,
      'source_id': b.id,
      'note': b.name,
    }, id: reused ? null : derived);

    if (b.repeat == 'monthly') await _addNext(b, paid);
  }

  Future<void> _addNext(Bill b, int amountMinor) async {
    final due = parseIsoDate(b.dueOn);
    if (due == null) return;
    final seriesId = b.seriesId ?? b.id;
    // Keep the series' day of month (31st -> Feb 28 -> Mar 31).
    final first = await (db.select(db.bills)..where((x) => x.id.equals(seriesId))).getSingleOrNull();
    final anchor = parseIsoDate(first?.dueOn)?.day ?? due.day;
    final nextDue = isoDate(addMonths(due, 1, day: anchor));
    final id = nextBillId(_household, seriesId, nextDue);
    if (await _exists(db.bills, id)) return;
    await writer.insert('bills', {
      'name': b.name,
      'provider': b.provider,
      'amount_minor': amountMinor,
      'currency': b.currency,
      'due_on': nextDue,
      'category': b.category,
      'repeat': 'monthly',
      'series_id': seriesId,
    }, id: id);
  }

  /// The ledger entry recording [b]'s payment, if any.
  Future<LedgerEntry?> paymentOf(Bill b) =>
      (db.select(db.transactions)
            ..where((t) => t.deletedAt.isNull() & t.sourceType.equals(billSource) & t.sourceId.equals(b.id))
            ..limit(1))
          .getSingleOrNull();

  /// Only the person who recorded a payment can undo it (forward-only
  /// status, sync-protocol §6).
  Future<bool> canUndo(Bill b) async {
    final p = await paymentOf(b);
    return p != null && p.memberId == writer.identity.memberId;
  }

  /// Back to unpaid and the expense removed. Next month's bill stays.
  Future<void> undoPaid(Bill b) async {
    final p = await paymentOf(b);
    await writer.update('bills', b.id, {'is_paid': false, 'paid_at': null});
    if (p != null) await writer.delete('transactions', p.id);
  }

  // -------------------------------------------------------- subscriptions

  /// Subscriptions, next due first.
  Stream<List<Subscription>> watchSubscriptions() =>
      (db.select(db.subscriptions)
            ..where((s) => s.deletedAt.isNull())
            ..orderBy([
              (s) => OrderingTerm(expression: s.nextDueOn.isNull()),
              (s) => OrderingTerm.asc(s.nextDueOn),
              (s) => OrderingTerm.asc(s.name),
            ]))
          .watch();

  Future<String> addSubscription({
    required String name,
    required int priceMinor,
    required DateTime nextDueOn,
    String cycle = 'monthly',
    String category = defaultSubscriptionCategory,
  }) => writer.insert('subscriptions', {
    'name': name.trim(),
    'price_minor': priceMinor,
    'currency': 'PHP',
    'cycle': cycle,
    'next_due_on': isoDate(nextDueOn),
    'category': category,
  });

  Future<void> editSubscription(
    Subscription s, {
    required String name,
    required int priceMinor,
    required DateTime nextDueOn,
    required String cycle,
    required String category,
  }) => writer.update('subscriptions', s.id, {
    if (name.trim() != s.name) 'name': name.trim(),
    if (priceMinor != s.priceMinor) 'price_minor': priceMinor,
    if (isoDate(nextDueOn) != s.nextDueOn) 'next_due_on': isoDate(nextDueOn),
    if (cycle != s.cycle) 'cycle': cycle,
    if (category != s.category) 'category': category,
  });

  Future<void> removeSubscription(String id) => writer.delete('subscriptions', id);

  /// Records this cycle's payment and moves the due date one cycle on.
  Future<void> paySubscription(Subscription s) async {
    final now = today;
    final due = parseIsoDate(s.nextDueOn) ?? DateTime(now.year, now.month, now.day);
    final dueKey = isoDate(due);
    final derived = subscriptionPaymentId(_household, s.id, dueKey);
    final existing = await (db.select(db.transactions)..where((t) => t.id.equals(derived))).getSingleOrNull();
    // Already recorded for this due date (e.g. pulled from another device): just move on.
    if (existing == null || existing.deletedAt != null) {
      await writer.insert('transactions', {
        'amount_minor': -s.priceMinor,
        'category': s.category ?? defaultSubscriptionCategory,
        'currency': s.currency,
        'occurred_at': now.toUtc(),
        'member_id': writer.identity.memberId,
        'source_type': subscriptionSource,
        'source_id': s.id,
        'note': s.name,
      }, id: existing == null ? derived : null);
    }
    await writer.update('subscriptions', s.id, {
      'next_due_on': isoDate(addMonths(due, s.cycle == 'yearly' ? 12 : 1)),
    });
  }

  // ------------------------------------------------------------- helpers

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

  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}
