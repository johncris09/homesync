import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/outbox.dart';

import '../../support/test_db.dart';

const memberId = '01900000-0000-7000-8000-0000000000aa';
const deviceId = '0193a1f2-7c4e-7b2a-9d11-3f6c2a9e8b10';

void main() {
  late AppDatabase db;
  late LocalWriter w;
  var writes = 0;

  setUp(() {
    db = memoryDb();
    writes = 0;
    w = LocalWriter(
      db: db,
      identity: identity(memberId: memberId, deviceId: deviceId),
      clock: writer(db, identity(memberId: memberId, deviceId: deviceId)).clock,
      onWrite: () => writes++,
    );
  });
  tearDown(() => db.close());

  Future<List<OutboxOp>> ops() =>
      (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
  Map<String, Object?> fieldsOf(OutboxOp op) => (jsonDecode(op.fields) as Map).cast();

  test('insert writes the row and one op in the same transaction', () async {
    final id = await w.insert('grocery_items', {'name': 'Rice', 'quantity_text': '5 kg'});

    final row = (await db.select(db.groceryItems).get()).single;
    expect(row.id, id);
    expect(row.name, 'Rice');
    expect(row.householdId, householdId);
    expect(row.updatedBy, memberId);
    expect(row.deviceId, deviceId);
    expect(row.hlc, matches(RegExp(r'^\d{13}-[0-9a-f]{4}-0193a1f2$')));

    final op = (await ops()).single;
    expect(op.op, 'insert');
    expect(op.entity, 'grocery_items');
    expect(op.entityId, id);
    expect(op.hlc, row.hlc);
    expect(fieldsOf(op), {'name': 'Rice', 'quantity_text': '5 kg'});
    expect(writes, 1);
  });

  test('ids are UUIDv7', () async {
    final id = await w.insert('grocery_items', {'name': 'Eggs'});
    expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
  });

  test('repeated edits before a push fold into the insert op', () async {
    final id = await w.insert('grocery_items', {'name': 'Rice'});
    await w.update('grocery_items', id, {'name': 'Brown rice'});
    await w.update('grocery_items', id, {'is_bought': true, 'bought_at': DateTime.utc(2026, 11, 25, 6, 31)});

    final op = (await ops()).single;
    expect(op.op, 'insert');
    expect(fieldsOf(op), {
      'name': 'Brown rice',
      'is_bought': true,
      'bought_at': '2026-11-25T06:31:00.000Z',
    });
    final row = await (db.select(db.groceryItems)..where((g) => g.id.equals(id))).getSingle();
    expect(op.hlc, row.hlc, reason: 'merged op carries the newest clock');
    expect(row.isBought, isTrue);
  });

  test('updates to a synced record fold into one update op', () async {
    final id = await w.insert('bills', {'name': 'Meralco', 'amount_minor': 250000});
    await db.delete(db.outbox).go(); // pretend it was pushed
    await db.customStatement("UPDATE bills SET server_version = 41 WHERE id = '$id'");

    await w.update('bills', id, {'amount_minor': 260000});
    await w.update('bills', id, {'provider': 'Meralco', 'amount_minor': 270000});

    final op = (await ops()).single;
    expect(op.op, 'update');
    expect(op.baseVersion, 41);
    expect(fieldsOf(op), {'amount_minor': 270000, 'provider': 'Meralco'});
  });

  test('counters: increments are summed and applied to the row', () async {
    final id = await w.insert('pantry_items', {'name': 'Sardines', 'quantity': 6});
    await db.delete(db.outbox).go();

    await w.increment('pantry_items', id, {'quantity': -1});
    await w.increment('pantry_items', id, {'quantity': -2});

    final op = (await ops()).single;
    expect(op.op, 'increment');
    expect(fieldsOf(op), {'quantity': -3});
    final row = (await db.select(db.pantryItems).get()).single;
    expect(row.quantity, 3);
  });

  test('increment before the first push folds into the insert', () async {
    final id = await w.insert('pantry_items', {'name': 'Sardines', 'quantity': 6});
    await w.increment('pantry_items', id, {'quantity': -1});
    final op = (await ops()).single;
    expect(op.op, 'insert');
    expect(fieldsOf(op)['quantity'], 5);
  });

  test('absolute update of a counter is refused', () async {
    final id = await w.insert('pantry_items', {'name': 'Sardines', 'quantity': 6});
    expect(() => w.update('pantry_items', id, {'quantity': 2}), throwsArgumentError);
    expect(() => w.increment('pantry_items', id, {'name': 1}), throwsArgumentError);
  });

  test('append-only ledger allows only note changes', () async {
    final id = await w.insert('transactions', {
      'amount_minor': -15000,
      'occurred_at': DateTime.utc(2026, 11, 25),
      'category': 'food',
    });
    await w.update('transactions', id, {'note': 'jollibee'});
    expect(() => w.update('transactions', id, {'amount_minor': 1}), throwsArgumentError);
  });

  test('unknown fields are refused', () async {
    expect(() => w.insert('grocery_items', {'name': 'x', 'server_version': 3}), throwsArgumentError);
    expect(() => w.insert('grocery_items', {'nope': 1}), throwsArgumentError);
  });

  test('different kinds of change stay separate ops, in order', () async {
    final id = await w.insert('pantry_items', {'name': 'Rice', 'quantity': 10});
    await db.delete(db.outbox).go();
    await w.update('pantry_items', id, {'location': 'Cabinet'});
    await w.increment('pantry_items', id, {'quantity': -1});
    await w.update('pantry_items', id, {'location': 'Ref'});
    await w.delete('pantry_items', id);

    expect((await ops()).map((o) => o.op), ['update', 'increment', 'update', 'delete']);
    final row = (await db.select(db.pantryItems).get()).single;
    expect(row.deletedAt, isNotNull);
  });

  test('an op already being sent is never merged into', () async {
    final id = await w.insert('grocery_items', {'name': 'Rice'});
    await db.update(db.outbox).write(const OutboxCompanion(sending: Value(true)));
    await w.update('grocery_items', id, {'name': 'Brown rice'});

    final all = await ops();
    expect(all.map((o) => o.op), ['insert', 'update']);
    expect(fieldsOf(all.first), {'name': 'Rice'});
  });

  test('each write stores field clocks and persists the HLC', () async {
    final id = await w.insert('grocery_items', {'name': 'Rice', 'store': 'SM'});
    final clocks = await db.select(db.fieldClocks).get();
    expect(clocks.map((c) => c.field).toSet(), {'name', 'store'});
    expect(clocks.every((c) => c.entityId == id), isTrue);
    final saved = await (db.select(db.syncState)..where((s) => s.key.equals('hlc_last'))).getSingle();
    expect(saved.value, w.clock.last.toString());
  });

  test('mergeOps keeps delete separate', () {
    expect(mergeOps('update', {'a': 1}, 'delete', {'deleted_at': 'x'}), isNull);
    expect(mergeOps('increment', {'q': 1}, 'update', {'a': 1}), isNull);
  });
}
