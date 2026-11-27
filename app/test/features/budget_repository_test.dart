import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/budget/budget_repository.dart';
import 'package:homesync/shared/money.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  group('money', () {
    test('formats pesos, optionally without zero centavos', () {
      expect(formatPeso(124050), '₱1,240.50');
      expect(formatPeso(1155000, whole: true), '₱11,550');
      expect(formatPeso(1155050, whole: true), '₱11,550.50');
      expect(formatPeso(0), '₱0.00');
    });

    test('parses what people type', () {
      expect(parsePeso('1,240.50'), 124050);
      expect(parsePeso('₱ 85'), 8500);
      expect(parsePeso('12.5'), 1250);
      expect(parsePeso(' 300 '), 30000);
      expect(parsePeso('0'), isNull);
      expect(parsePeso('-5'), isNull);
      expect(parsePeso('1.234'), isNull);
      expect(parsePeso('abc'), isNull);
      expect(parsePeso(''), isNull);
    });
  });

  group('repository', () {
    late AppDatabase db;
    late BudgetRepository repo;
    var now = DateTime(2026, 11, 26, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 11, 26, 9);
      repo = BudgetRepository(db, writer(db, identity(memberId: memberA, deviceId: deviceA)), now: () => now);
    });
    tearDown(() => db.close());

    test('expenses are stored negative with the member; income positive', () async {
      await repo.addEntry(amountMinor: 12000, category: 'food', occurredAt: now, note: ' palengke ');
      await repo.addEntry(amountMinor: 2500000, category: 'food', occurredAt: now, income: true);
      final rows = await repo.watchMonth(now).first;
      final out = rows.firstWhere((e) => e.amountMinor < 0);
      final into = rows.firstWhere((e) => e.amountMinor > 0);
      expect(out.amountMinor, -12000);
      expect(out.category, 'food');
      expect(out.note, 'palengke');
      expect(out.memberId, memberA);
      expect(out.sourceType, 'manual');
      expect(into.category, incomeCategory, reason: 'income is one category');
      expect(() => repo.addEntry(amountMinor: 0, category: 'food', occurredAt: now), throwsArgumentError);
    });

    test('a month is the local calendar month', () async {
      await repo.addEntry(amountMinor: 100, category: 'food', occurredAt: DateTime(2026, 10, 31, 23, 59));
      await repo.addEntry(amountMinor: 200, category: 'food', occurredAt: DateTime(2026, 11, 1, 0, 0));
      await repo.addEntry(amountMinor: 300, category: 'food', occurredAt: DateTime(2026, 11, 30, 23, 59));
      await repo.addEntry(amountMinor: 400, category: 'food', occurredAt: DateTime(2026, 12, 1));
      final nov = await repo.watchMonth(DateTime(2026, 11)).first;
      expect(nov.map((e) => -e.amountMinor), [300, 200], reason: 'newest first');
    });

    test('member filter shows only that member\'s entries', () async {
      final other = BudgetRepository(db, writer(db, identity(memberId: memberB, deviceId: deviceB)), now: () => now);
      await repo.addEntry(amountMinor: 100, category: 'food', occurredAt: now);
      await other.addEntry(amountMinor: 200, category: 'food', occurredAt: now);
      expect((await repo.watchMonth(now, memberId: memberB).first).single.amountMinor, -200);
      expect(await repo.watchMonth(now, memberId: '').first, isEmpty);
      expect(await repo.watchMonth(now).first, hasLength(2));
    });

    test('only the note can change; removing tombstones the entry', () async {
      final id = await repo.addEntry(amountMinor: 100, category: 'food', occurredAt: now);
      await repo.setNote(id, 'rice');
      expect((await repo.watchMonth(now).first).single.note, 'rice');
      await repo.removeEntry(id);
      expect(await repo.watchMonth(now).first, isEmpty);
      expect((await rawRow(db, 'transactions', id))!['deleted_at'], isNotNull);
    });

    test('budgets use one derived id per category; 0 means no budget', () async {
      await repo.setBudget('food', 800000);
      await repo.setBudget('food', 900000);
      await repo.setBudget('load', 50000);
      final budgets = await repo.watchBudgets().first;
      expect(budgets, hasLength(2));
      final food = budgets.firstWhere((b) => b.category == 'food');
      expect(food.id, budgetId(householdId, 'food'));
      expect(food.limitMinor, 900000);
      final ops = await db.select(db.outbox).get();
      expect(ops.where((o) => o.entityId == food.id), hasLength(1), reason: 'insert + update fold');
      expect(jsonDecode(ops.firstWhere((o) => o.entityId == food.id).fields)['limit_minor'], 900000);

      await repo.setBudget('load', 0);
      final summary = MonthSummary(const [], await repo.watchBudgets().first);
      expect(summary.limits.keys, ['food']);
    });

    test('derived ids are stable UUIDs and differ by household and category', () {
      final a = budgetId(householdId, 'food');
      expect(a, budgetId(householdId, 'food'));
      expect(a, isNot(budgetId(householdId, 'load')));
      expect(a, isNot(budgetId('01900000-0000-7000-8000-000000000002', 'food')));
      expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(a), isTrue);
    });
  });

  group('month summary', () {
    LedgerEntry e(int amount, String? cat) => LedgerEntry(
      id: '$amount$cat',
      householdId: householdId,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      amountMinor: amount,
      currency: 'PHP',
      occurredAt: DateTime(2026, 11, 2),
      category: cat,
    );
    Budget b(String cat, int limit) => Budget(
      id: cat,
      householdId: householdId,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      category: cat,
      limitMinor: limit,
      currency: 'PHP',
    );

    test('spent, income, budgeted and left', () {
      final s = MonthSummary(
        [e(-30000, 'food'), e(-20000, 'food'), e(-5000, 'load'), e(-1000, null), e(2500000, 'income')],
        [b('food', 100000), b('utilities', 300000), b('giving', 0)],
      );
      expect(s.spent, 56000);
      expect(s.income, 2500000);
      expect(s.budgeted, 400000);
      expect(s.left, 344000);
      expect(s.spentByCategory, {'food': 50000, 'load': 5000, 'other': 1000});
      expect(s.categories, ['food', 'utilities', 'load', 'other'], reason: 'fixed order, budgeted or spent');
    });

    test('over budget goes negative', () {
      final s = MonthSummary([e(-150000, 'food')], [b('food', 100000)]);
      expect(s.left, -50000);
    });
  });

  test('two adults set the same category budget offline: one row, the other value goes to review', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final a = BudgetRepository(dbA, wA);
    final b = BudgetRepository(dbB, wB);
    final syncA = SyncEngine(db: dbA, api: server.apiFor(memberId: memberA, deviceId: deviceA), clock: wA.clock);
    final syncB = SyncEngine(db: dbB, api: server.apiFor(memberId: memberB, deviceId: deviceB), clock: wB.clock);

    await b.setBudget('food', 650000);
    await a.setBudget('food', 800000); // later HLC wins
    await syncB.sync();
    await syncA.sync();
    await syncB.sync();

    for (final db in [dbA, dbB]) {
      final budgets = await (db.select(db.budgets)).get();
      expect(budgets.single.limitMinor, 800000);
    }
    final conflicts = await dbB.select(dbB.conflicts).get();
    expect(conflicts.single.entity, 'budgets');
    expect(jsonDecode(conflicts.single.lostValue!), 650000);
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 1 database adds the budgets table', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v2 = AppDatabase(NativeDatabase(file));
    await v2.customStatement('SELECT 1'); // creates the schema
    await v2.customStatement('DROP TABLE budgets');
    // Also undo version 3 (Bills & Subscriptions).
    await v2.customStatement('DROP TABLE subscriptions');
    for (final c in ['category', 'repeat', 'series_id']) {
      await v2.customStatement('ALTER TABLE bills DROP COLUMN "$c"');
    }
    await v2.customStatement('ALTER TABLE grocery_items DROP COLUMN cleared_at'); // added in v7
    await v2.customStatement('ALTER TABLE grocery_items DROP COLUMN planned_on'); // added in v8
    // Also undo version 9 (multi-day events).
    await v2.customStatement('ALTER TABLE events DROP COLUMN "ends_on"');
    await v2.customStatement('ALTER TABLE events DROP COLUMN "color"');
    await v2.customStatement('DROP TABLE vehicles'); // added in v11
    await v2.customStatement('DROP TABLE vehicle_logs');
    await v2.customStatement('PRAGMA user_version = 1');
    await v2.close();

    final reopened = AppDatabase(NativeDatabase(file));
    await reopened.into(reopened.budgets).insert(
      BudgetsCompanion.insert(id: 'x', householdId: householdId, category: 'food'),
    );
    expect(await reopened.select(reopened.budgets).get(), hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
