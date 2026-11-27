import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/debts/debts_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  group('repository', () {
    late AppDatabase db;
    late DebtsRepository repo;
    var now = DateTime(2026, 11, 26, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 11, 26, 9);
      repo = DebtsRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    Future<Debt> debt(String id) => (db.select(db.debts)..where((d) => d.id.equals(id))).getSingle();
    Future<List<LedgerEntry>> ledger() => (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get();

    test('a loan payment lowers the balance, posts an expense and moves the due date', () async {
      final id = await repo.addDebt(
        kind: 'loan',
        name: 'Pag-IBIG salary loan',
        principalMinor: 6000000,
        installmentMinor: 280000,
        nextDueOn: DateTime(2026, 11, 30),
        monthly: true,
      );
      await repo.pay(await debt(id), 280000);

      expect(await repo.balance(id), 6000000 - 280000);
      final d = await debt(id);
      expect(d.nextDueOn, '2026-12-30', reason: 'it was due within a week');
      expect(d.startedOn, '2026-11-26');
      final tx = (await ledger()).single;
      final p = (await repo.watchHistory(id).first).single;
      expect(tx.id, debtPaymentLedgerId(householdId, p.id));
      expect(tx.amountMinor, -280000);
      expect(tx.category, 'debt');
      expect(tx.sourceType, 'debt');
      expect(tx.sourceId, id);
      expect(tx.note, 'Pag-IBIG salary loan');
      expect(p.kind, 'payment');
      expect(p.memberId, memberA);
    });

    test('an early payment leaves a far-off due date alone', () async {
      final id = await repo.addDebt(
        kind: 'card',
        name: 'BPI card',
        principalMinor: 2500000,
        nextDueOn: DateTime(2026, 12, 20),
        monthly: true,
      );
      await repo.pay(await debt(id), 500000);
      expect((await debt(id)).nextDueOn, '2026-12-20');
    });

    test('renewing a pawn ticket: interest paid, balance and ticket stay, maturity moves', () async {
      final id = await repo.addDebt(
        kind: 'pawn',
        name: 'Gold ring',
        counterparty: 'Cebuana',
        reference: 'A-102938',
        principalMinor: 500000,
        nextDueOn: DateTime(2026, 11, 28),
        monthly: true,
      );
      await repo.pay(await debt(id), 20000, interestOnly: true);
      expect(await repo.balance(id), 500000);
      final d = await debt(id);
      expect(d.isClosed, isFalse);
      expect(d.nextDueOn, '2026-12-28');
      expect((await ledger()).single.amountMinor, -20000, reason: 'interest is still money spent');
    });

    test('charges raise the balance; paying it all closes the debt', () async {
      final id = await repo.addDebt(kind: 'card', name: 'BPI card', principalMinor: 100000);
      await repo.addCharge(await debt(id), 50000);
      expect(await repo.balance(id), 150000);
      expect(await ledger(), isEmpty, reason: 'a charge is not a payment');

      await repo.pay(await debt(id), 150000);
      final d = await debt(id);
      expect(d.isClosed, isTrue);
      expect(d.closedBy, memberA);
      expect(await repo.watchOpen().first, isEmpty);
      expect((await repo.watchClosed().first).single.id, id);
    });

    test('money lent coming back is not an expense', () async {
      final id = await repo.addDebt(kind: 'lent', name: 'Tito Ben', principalMinor: 300000);
      await repo.pay(await debt(id), 100000);
      expect(await repo.balance(id), 200000);
      expect(await ledger(), isEmpty);
    });

    test('only the recorder removes a payment, and its expense goes with it', () async {
      final id = await repo.addDebt(kind: 'loan', name: 'SSS loan', principalMinor: 2000000);
      await repo.pay(await debt(id), 100000);
      final p = (await repo.watchHistory(id).first).single;
      final other = DebtsRepository(
        db,
        writer(db, identity(memberId: memberB, deviceId: deviceB)),
        now: () => now,
      );
      expect(other.canRemove(p), isFalse);
      expect(repo.canRemove(p), isTrue);

      await repo.removePayment(p);
      expect(await repo.balance(id), 2000000);
      expect(await ledger(), isEmpty);
    });

    test('only the closer reopens', () async {
      final id = await repo.addDebt(kind: 'lent', name: 'Kumare', principalMinor: 100000);
      await repo.close(await debt(id));
      final other = DebtsRepository(
        db,
        writer(db, identity(memberId: memberB, deviceId: deviceB)),
        now: () => now,
      );
      expect(other.canReopen(await debt(id)), isFalse);
      expect(repo.canReopen(await debt(id)), isTrue);
      await repo.reopen(await debt(id));
      expect((await debt(id)).isClosed, isFalse);
    });

    test('editing saves only what changed', () async {
      final id = await repo.addDebt(kind: 'loan', name: 'SSS loan', principalMinor: 2000000);
      final d = await debt(id);
      await db.delete(db.outbox).go();
      await repo.editDebt(d, name: 'SSS loan', principalMinor: 2100000, counterparty: 'SSS', monthly: false);
      final op = (await db.select(db.outbox).get()).single;
      expect(op.fields, contains('principal_minor'));
      expect(op.fields, contains('counterparty'));
      expect(op.fields, isNot(contains('name')));
    });
  });

  test('summary: owed, owed to us, overdue and next', () {
    final today = DateTime(2026, 11, 26);
    Debt d(String id, String kind, int principal, String? due) => Debt(
      id: id,
      householdId: householdId,
      createdAt: today,
      updatedAt: today,
      kind: kind,
      name: id,
      principalMinor: principal,
      currency: 'PHP',
      nextDueOn: due,
      isClosed: false,
    );
    DebtPayment p(String debtId, String kind, int amount) => DebtPayment(
      id: '$debtId-$kind-$amount',
      householdId: householdId,
      createdAt: today,
      updatedAt: today,
      debtId: debtId,
      kind: kind,
      amountMinor: amount,
      currency: 'PHP',
      paidOn: '2026-11-01',
    );
    final sum = DebtsSummary(
      [
        d('Loan', 'loan', 1000000, '2026-12-10'),
        d('Ring', 'pawn', 500000, '2026-11-20'),
        d('Ben', 'lent', 300000, '2026-11-01'),
      ],
      [
        p('Loan', 'payment', 200000),
        p('Loan', 'interest', 5000),
        p('Ring', 'charge', 10000),
        p('Ben', 'payment', 100000),
      ],
      today,
    );
    expect(sum.owed, 800000 + 510000);
    expect(sum.owedToUs, 200000);
    expect(sum.overdue, 1, reason: 'money lent being late is not our overdue');
    expect(sum.next?.name, 'Ring');
    expect(sum.balances['Loan'], 800000);
  });

  test('two adults record payments offline: both count', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final now = DateTime(2026, 11, 26, 9);
    final a = DebtsRepository(dbA, wA, now: () => now);
    final b = DebtsRepository(dbB, wB, now: () => now);
    final syncA = SyncEngine(
      db: dbA,
      api: server.apiFor(memberId: memberA, deviceId: deviceA),
      clock: wA.clock,
    );
    final syncB = SyncEngine(
      db: dbB,
      api: server.apiFor(memberId: memberB, deviceId: deviceB),
      clock: wB.clock,
    );

    final id = await a.addDebt(kind: 'card', name: 'BPI card', principalMinor: 1000000);
    await syncA.sync();
    await syncB.sync();
    await a.pay((await a.watchOpen().first).single, 200000);
    await b.pay((await b.watchOpen().first).single, 300000);
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final repo in [a, b]) {
      expect(await repo.balance(id), 500000);
    }
    expect(await (dbA.select(dbA.transactions)).get(), hasLength(2));
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 5 database adds the debt tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v5 = AppDatabase(NativeDatabase(file));
    await v5.customStatement('SELECT 1');
    await v5.customStatement('DROP TABLE debts');
    await v5.customStatement('DROP TABLE debt_payments');
    await v5.customStatement('ALTER TABLE grocery_items DROP COLUMN cleared_at'); // added in v7
    await v5.customStatement('ALTER TABLE grocery_items DROP COLUMN planned_on'); // added in v8
    // Also undo version 9 (multi-day events).
    await v5.customStatement('ALTER TABLE events DROP COLUMN "ends_on"');
    await v5.customStatement('ALTER TABLE events DROP COLUMN "color"');
    await v5.customStatement('DROP TABLE vehicles'); // added in v11
    await v5.customStatement('DROP TABLE vehicle_logs');
    await v5.customStatement('PRAGMA user_version = 5');
    await v5.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = DebtsRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    final id = await repo.addDebt(kind: 'loan', name: 'SSS loan', principalMinor: 100000);
    await repo.addCharge((await repo.watchOpen().first).single, 1000);
    expect(await repo.balance(id), 101000);
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
