import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../shared/dates.dart';
import '../bills/bills_repository.dart' show dueSoonDays;
import '../budget/budget_repository.dart' show derivedIdNamespace;

/// Kinds of debt. Money the household owes, except [lentKind].
const debtKinds = ['loan', 'card', 'pawn', 'lent'];
const lentKind = 'lent';

/// Kinds of [DebtPayment].
const paymentKind = 'payment';
const interestKind = 'interest';
const chargeKind = 'charge';

/// Ledger category and `source_type` of debt payments.
const debtCategory = 'debt';
const debtSource = 'debt';

/// The ledger entry of a debt payment, the same on every device.
String debtPaymentLedgerId(String householdId, String paymentId) =>
    const Uuid().v5(derivedIdNamespace, 'transactions/$householdId/debt/$paymentId');

/// What is left: principal plus charges minus payments (interest-only
/// payments leave it alone).
int balanceOf(Debt d, Iterable<DebtPayment> payments) {
  var balance = d.principalMinor;
  for (final p in payments) {
    if (p.debtId != d.id) continue;
    if (p.kind == paymentKind) balance -= p.amountMinor;
    if (p.kind == chargeKind) balance += p.amountMinor;
  }
  return balance;
}

/// Open debts with their balances, split into what the household owes and
/// what is owed to it.
class DebtsSummary {
  DebtsSummary(List<Debt> open, List<DebtPayment> payments, DateTime today) {
    final byDebt = <String, List<DebtPayment>>{};
    for (final p in payments) {
      (byDebt[p.debtId] ??= []).add(p);
    }
    for (final d in open) {
      final balance = balanceOf(d, byDebt[d.id] ?? const []);
      balances[d.id] = balance;
      if (d.kind == lentKind) {
        owedToUs += balance;
      } else {
        owed += balance;
        final on = parseIsoDate(d.nextDueOn);
        if (on != null) {
          if (daysUntil(on, today) < 0) overdue++;
          if (next == null || d.nextDueOn!.compareTo(next!.dueOn) < 0) next = (name: d.name, dueOn: d.nextDueOn!);
        }
      }
    }
  }

  final balances = <String, int>{};
  int owed = 0;
  int owedToUs = 0;
  int overdue = 0;

  /// The household's debt due soonest.
  ({String name, String dueOn})? next;
}

/// Debts & Loans. Payments, interest and charges are append-only
/// [DebtPayment] rows; a payment the household makes on a loan, card or pawn
/// ticket also posts an expense to the ledger (category `debt`) with an id
/// derived from the payment, so removing the payment can find it.
class DebtsRepository {
  DebtsRepository(this.db, this.writer, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final DateTime Function() _now;

  DateTime get today => _now();
  String get _household => writer.identity.householdId;
  String get _me => writer.identity.memberId;

  Stream<List<Debt>> watchOpen() =>
      (db.select(db.debts)
            ..where((d) => d.deletedAt.isNull() & d.isClosed.equals(false))
            ..orderBy([
              (d) => OrderingTerm(expression: d.nextDueOn.isNull()),
              (d) => OrderingTerm.asc(d.nextDueOn),
              (d) => OrderingTerm.asc(d.name),
            ]))
          .watch();

  /// Paid off, redeemed or repaid; latest first.
  Stream<List<Debt>> watchClosed({int limit = 20}) =>
      (db.select(db.debts)
            ..where((d) => d.deletedAt.isNull() & d.isClosed.equals(true))
            ..orderBy([(d) => OrderingTerm.desc(d.closedAt)])
            ..limit(limit))
          .watch();

  Stream<Debt?> watchDebt(String id) =>
      (db.select(db.debts)..where((d) => d.id.equals(id) & d.deletedAt.isNull())).watchSingleOrNull();

  /// Every live payment, interest and charge (for balances).
  Stream<List<DebtPayment>> watchPayments() =>
      (db.select(db.debtPayments)..where((p) => p.deletedAt.isNull())).watch();

  /// One debt's history, latest first.
  Stream<List<DebtPayment>> watchHistory(String debtId) =>
      (db.select(db.debtPayments)
            ..where((p) => p.deletedAt.isNull() & p.debtId.equals(debtId))
            ..orderBy([(p) => OrderingTerm.desc(p.paidOn), (p) => OrderingTerm.desc(p.createdAt)]))
          .watch();

  Future<String> addDebt({
    required String kind,
    required String name,
    required int principalMinor,
    String? counterparty,
    String? reference,
    int? installmentMinor,
    DateTime? nextDueOn,
    bool monthly = false,
    String? note,
  }) => writer.insert('debts', {
    'kind': kind,
    'name': name.trim(),
    'counterparty': _blankToNull(counterparty),
    'reference': _blankToNull(reference),
    'principal_minor': principalMinor,
    'currency': 'PHP',
    'installment_minor': installmentMinor,
    'next_due_on': nextDueOn == null ? null : isoDate(nextDueOn),
    'repeat': monthly ? 'monthly' : null,
    'started_on': isoDate(today),
    'note': _blankToNull(note),
  });

  /// Saves only what changed.
  Future<void> editDebt(
    Debt d, {
    required String name,
    required int principalMinor,
    String? counterparty,
    String? reference,
    int? installmentMinor,
    DateTime? nextDueOn,
    required bool monthly,
    String? note,
  }) {
    final due = nextDueOn == null ? null : isoDate(nextDueOn);
    return writer.update('debts', d.id, {
      if (name.trim() != d.name) 'name': name.trim(),
      if (principalMinor != d.principalMinor) 'principal_minor': principalMinor,
      if (_blankToNull(counterparty) != d.counterparty) 'counterparty': _blankToNull(counterparty),
      if (_blankToNull(reference) != d.reference) 'reference': _blankToNull(reference),
      if (installmentMinor != d.installmentMinor) 'installment_minor': installmentMinor,
      if (due != d.nextDueOn) 'next_due_on': due,
      if (monthly != (d.repeat == 'monthly')) 'repeat': monthly ? 'monthly' : null,
      if (_blankToNull(note) != d.note) 'note': _blankToNull(note),
    });
  }

  Future<void> removeDebt(String id) => writer.delete('debts', id);

  /// Records a payment ([interestOnly]: interest, balance unchanged).
  ///
  /// On a loan, card or pawn ticket it is also an expense in the ledger. When
  /// a monthly debt is due (within [dueSoonDays] or overdue) the due date
  /// moves one month on. A payment that clears the balance closes the debt.
  Future<void> pay(Debt d, int amountMinor, {bool interestOnly = false}) async {
    final paymentId = await writer.insert('debt_payments', {
      'debt_id': d.id,
      'kind': interestOnly ? interestKind : paymentKind,
      'amount_minor': amountMinor,
      'currency': d.currency,
      'paid_on': isoDate(today),
      'member_id': _me,
    });

    if (d.kind != lentKind) {
      await writer.insert('transactions', {
        'amount_minor': -amountMinor,
        'category': debtCategory,
        'currency': d.currency,
        'occurred_at': today.toUtc(),
        'member_id': _me,
        'source_type': debtSource,
        'source_id': d.id,
        'note': d.name,
      }, id: debtPaymentLedgerId(_household, paymentId));
    }

    final due = parseIsoDate(d.nextDueOn);
    if (d.repeat == 'monthly' && due != null && daysUntil(due, today) <= dueSoonDays) {
      await writer.update('debts', d.id, {'next_due_on': isoDate(addMonths(due, 1))});
    }

    if (!interestOnly && await balance(d.id) <= 0) await close(d);
  }

  /// Raises the balance: new card charges, penalties, more money lent.
  Future<void> addCharge(Debt d, int amountMinor) => writer.insert('debt_payments', {
    'debt_id': d.id,
    'kind': chargeKind,
    'amount_minor': amountMinor,
    'currency': d.currency,
    'paid_on': isoDate(today),
    'member_id': _me,
  });

  /// Only the person who recorded a payment removes it (with its ledger entry).
  bool canRemove(DebtPayment p) => p.memberId == _me;

  Future<void> removePayment(DebtPayment p) async {
    await writer.delete('debt_payments', p.id);
    final ledgerId = debtPaymentLedgerId(_household, p.id);
    final entry = await (db.select(db.transactions)..where((t) => t.id.equals(ledgerId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (entry != null) await writer.delete('transactions', ledgerId);
  }

  Future<int> balance(String debtId) async {
    final d = await (db.select(db.debts)..where((x) => x.id.equals(debtId))).getSingle();
    final ps = await (db.select(db.debtPayments)..where((p) => p.deletedAt.isNull() & p.debtId.equals(debtId))).get();
    return balanceOf(d, ps);
  }

  /// Paid off, redeemed or repaid.
  Future<void> close(Debt d) =>
      writer.update('debts', d.id, {'is_closed': true, 'closed_at': today.toUtc(), 'closed_by': _me});

  /// Only the person who closed it can reopen it (forward-only, sync-protocol §6).
  bool canReopen(Debt d) => d.isClosed && d.closedBy == _me;

  Future<void> reopen(Debt d) => writer.update('debts', d.id, {'is_closed': false, 'closed_at': null, 'closed_by': null});

  static String? _blankToNull(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}
