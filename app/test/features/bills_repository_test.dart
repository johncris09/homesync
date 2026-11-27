import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/bills/bills_repository.dart';
import 'package:homesync/shared/dates.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  test('addMonths keeps the day, clamped to the month', () {
    expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(addMonths(DateTime(2026, 2, 28), 1, day: 31), DateTime(2026, 3, 31));
    expect(addMonths(DateTime(2026, 12, 5), 1), DateTime(2027, 1, 5));
    expect(addMonths(DateTime(2028, 2, 29), 12), DateTime(2029, 2, 28));
  });

  test('due status', () {
    final today = DateTime(2026, 11, 26, 18);
    expect(dueStatus('2026-11-25', today), DueStatus.overdue);
    expect(dueStatus('2026-11-26', today), DueStatus.soon);
    expect(dueStatus('2026-12-03', today), DueStatus.soon);
    expect(dueStatus('2026-12-04', today), DueStatus.later);
    expect(dueStatus(null, today), DueStatus.none);
  });

  group('repository', () {
    late AppDatabase db;
    late BillsRepository repo;
    var now = DateTime(2026, 11, 26, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 11, 26, 9);
      repo = BillsRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    Future<Bill> bill(String id) => (db.select(db.bills)..where((b) => b.id.equals(id))).getSingle();
    Future<List<LedgerEntry>> ledger() => (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get();

    test('paying records the expense and adds next month\'s bill', () async {
      final id = await repo.addBill(name: 'Meralco', amountMinor: 300000, dueOn: DateTime(2026, 12, 5), monthly: true);
      expect((await bill(id)).seriesId, id);

      await repo.payBill(await bill(id), amountMinor: 324050);

      final paid = await bill(id);
      expect(paid.isPaid, isTrue);
      expect(paid.amountMinor, 324050, reason: 'the actual amount replaces the guess');
      final tx = (await ledger()).single;
      expect(tx.id, billPaymentId(householdId, id));
      expect(tx.amountMinor, -324050);
      expect(tx.category, 'utilities');
      expect(tx.sourceType, 'bill');
      expect(tx.sourceId, id);
      expect(tx.note, 'Meralco');
      expect(tx.memberId, memberA);

      final next = (await repo.watchUnpaid().first).single;
      expect(next.id, nextBillId(householdId, id, '2027-01-05'));
      expect(next.dueOn, '2027-01-05');
      expect(next.amountMinor, 324050);
      expect(next.seriesId, id);
      expect(next.isPaid, isFalse);
      expect((await repo.watchPaid().first).single.id, id);
    });

    test('a bill due on the 31st comes back to the 31st after February', () async {
      final id = await repo.addBill(name: 'Rent', amountMinor: 1, dueOn: DateTime(2027, 1, 31), monthly: true);
      await repo.payBill(await bill(id));
      final feb = (await repo.watchUnpaid().first).single;
      expect(feb.dueOn, '2027-02-28');
      await repo.payBill(feb);
      expect((await repo.watchUnpaid().first).single.dueOn, '2027-03-31');
    });

    test('a one-off bill adds nothing after it is paid', () async {
      final id = await repo.addBill(name: 'Plumber', amountMinor: 150000, dueOn: DateTime(2026, 11, 28));
      await repo.payBill(await bill(id));
      expect(await repo.watchUnpaid().first, isEmpty);
    });

    test('only the payer can undo; undo removes the expense; paying again records it once', () async {
      final id = await repo.addBill(name: 'Water', amountMinor: 45000, dueOn: DateTime(2026, 11, 30), monthly: true);
      await repo.payBill(await bill(id));
      final other = BillsRepository(
        db,
        writer(db, identity(memberId: memberB, deviceId: deviceB)),
        now: () => now,
      );
      expect(await other.canUndo(await bill(id)), isFalse);
      expect(await repo.canUndo(await bill(id)), isTrue);

      await repo.undoPaid(await bill(id));
      expect((await bill(id)).isPaid, isFalse);
      expect(await ledger(), isEmpty);

      await repo.payBill(await bill(id));
      final tx = (await ledger()).single;
      expect(tx.id, isNot(billPaymentId(householdId, id)), reason: 'the derived entry was removed');
      final unpaid = await repo.watchUnpaid().first;
      expect(unpaid, hasLength(1), reason: 'next month\'s bill is not added twice');
    });

    test('paying a subscription records it and moves the date one cycle on', () async {
      final id = await repo.addSubscription(name: 'Netflix', priceMinor: 54900, nextDueOn: DateTime(2026, 12, 1));
      final yearly = await repo.addSubscription(
        name: 'iCloud',
        priceMinor: 600000,
        nextDueOn: DateTime(2026, 11, 20),
        cycle: 'yearly',
      );
      var subs = await repo.watchSubscriptions().first;
      expect(subs.map((s) => s.name), ['iCloud', 'Netflix'], reason: 'next due first');
      expect(monthlyCost(subs), 54900 + 50000);

      await repo.paySubscription(subs.firstWhere((s) => s.id == id));
      await repo.paySubscription(subs.firstWhere((s) => s.id == yearly));
      subs = await repo.watchSubscriptions().first;
      expect(subs.firstWhere((s) => s.id == id).nextDueOn, '2027-01-01');
      expect(subs.firstWhere((s) => s.id == yearly).nextDueOn, '2027-11-20');
      final txs = await ledger();
      expect(txs, hasLength(2));
      final netflix = txs.firstWhere((t) => t.sourceId == id);
      expect(netflix.id, subscriptionPaymentId(householdId, id, '2026-12-01'));
      expect(netflix.amountMinor, -54900);
      expect(netflix.category, 'personal');
      expect(netflix.sourceType, 'subscription');
    });

    test('editing saves only what changed', () async {
      final id = await repo.addBill(name: 'PLDT', amountMinor: 169900, dueOn: DateTime(2026, 12, 10));
      final b = await bill(id);
      await db.delete(db.outbox).go();
      await repo.editBill(
        b,
        name: 'PLDT',
        amountMinor: 179900,
        dueOn: DateTime(2026, 12, 10),
        category: 'load',
        monthly: true,
      );
      final op = (await db.select(db.outbox).get()).single;
      expect(op.fields, contains('amount_minor'));
      expect(op.fields, contains('"repeat":"monthly"'));
      expect(op.fields, contains('series_id'));
      expect(op.fields, isNot(contains('name')));
    });
  });

  test('summary: what is left this month, overdue and next', () {
    final today = DateTime(2026, 11, 26);
    Bill b(String name, int amount, String due) => Bill(
      id: name,
      householdId: householdId,
      createdAt: today,
      updatedAt: today,
      name: name,
      amountMinor: amount,
      currency: 'PHP',
      dueOn: due,
      isPaid: false,
    );
    Subscription s(String name, int price, String due) => Subscription(
      id: name,
      householdId: householdId,
      createdAt: today,
      updatedAt: today,
      name: name,
      priceMinor: price,
      currency: 'PHP',
      cycle: 'monthly',
      nextDueOn: due,
    );
    final sum = BillsSummary(
      [b('Water', 45000, '2026-11-20'), b('Meralco', 300000, '2026-11-30'), b('Rent', 1500000, '2026-12-01')],
      [s('Netflix', 54900, '2026-11-28'), s('Spotify', 19400, '2026-12-03')],
      today,
    );
    expect(sum.due, 45000 + 300000 + 54900);
    expect(sum.count, 3);
    expect(sum.overdue, 1);
    expect(sum.next?.name, 'Water');
    expect(BillsSummary(const [], const [], today).next, isNull);
  });

  test('two adults pay the same bill offline: one expense, one next bill', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final a = BillsRepository(dbA, wA);
    final b = BillsRepository(dbB, wB);
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

    await a.addBill(name: 'Meralco', amountMinor: 300000, dueOn: DateTime(2026, 12, 5), monthly: true);
    await syncA.sync();
    await syncB.sync();

    // Both offline: each pays it.
    await a.payBill((await a.watchUnpaid().first).single);
    await b.payBill((await b.watchUnpaid().first).single, amountMinor: 310000);
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final db in [dbA, dbB]) {
      final txs = await (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get();
      expect(txs, hasLength(1));
      expect(txs.single.amountMinor, -300000, reason: 'the first payment to reach the hub stays');
      final bills = await db.select(db.bills).get();
      expect(bills, hasLength(2));
      expect(bills.where((x) => x.isPaid), hasLength(1));
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 2 database adds subscriptions and the bill repeat columns', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v3 = AppDatabase(NativeDatabase(file));
    await v3.customStatement('SELECT 1'); // creates the schema
    await v3.customStatement('DROP TABLE subscriptions');
    for (final c in ['category', 'repeat', 'series_id']) {
      await v3.customStatement('ALTER TABLE bills DROP COLUMN "$c"');
    }
    await v3.customStatement('ALTER TABLE grocery_items DROP COLUMN cleared_at'); // added in v7
    await v3.customStatement('ALTER TABLE grocery_items DROP COLUMN planned_on'); // added in v8
    // Also undo version 9 (multi-day events).
    await v3.customStatement('ALTER TABLE events DROP COLUMN "ends_on"');
    await v3.customStatement('ALTER TABLE events DROP COLUMN "color"');
    for (final t in ['vault_keys', 'vault_items', 'vault_files', 'vault_blobs']) {
      await v3.customStatement('DROP TABLE "$t"'); // added in v11
    }
    await v3.customStatement('PRAGMA user_version = 2');
    await v3.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = BillsRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.addBill(name: 'Water', amountMinor: 1, dueOn: DateTime(2026, 12, 1), monthly: true);
    await repo.addSubscription(name: 'Netflix', priceMinor: 1, nextDueOn: DateTime(2026, 12, 1));
    expect((await repo.watchUnpaid().first).single.repeat, 'monthly');
    expect(await repo.watchSubscriptions().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
