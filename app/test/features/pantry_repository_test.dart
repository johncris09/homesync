import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/features/pantry/pantry_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

void main() {
  late AppDatabase db;
  late PantryRepository repo;
  var now = DateTime(2026, 11, 26, 9);

  setUp(() {
    db = memoryDb();
    now = DateTime(2026, 11, 26, 9);
    repo = PantryRepository(
      db,
      writer(db, identity(memberId: memberA, deviceId: deviceA)),
      now: () => now,
    );
  });
  tearDown(() => db.close());

  Future<List<Map<String, Object?>>> ops() async => [
    for (final o in await db.select(db.outbox).get()) {'op': o.op, 'entity': o.entity, 'fields': jsonDecode(o.fields)},
  ];

  group('grocery', () {
    test('adding records who asked and trims blanks to null', () async {
      final id = await repo.addGrocery('  Eggs ', quantityText: '1 tray', store: '  ', note: '');
      final g = (await repo.watchToBuy().first).single;
      expect(g.id, id);
      expect(g.name, 'Eggs');
      expect(g.quantityText, '1 tray');
      expect(g.store, isNull);
      expect(g.note, isNull);
      expect(g.requestedBy, memberA);
      expect(g.isBought, isFalse);
    });

    test('to-buy is grouped by store, items without a store last', () async {
      await repo.addGrocery('Rice');
      await repo.addGrocery('kangkong', store: 'Palengke');
      await repo.addGrocery('Bread', store: 'bakery');
      await repo.addGrocery('Ampalaya', store: 'Palengke');
      expect((await repo.watchToBuy().first).map((g) => g.name), ['Bread', 'Ampalaya', 'kangkong', 'Rice']);
    });

    test('ticking moves an item to bought with the time; unticking moves it back', () async {
      final id = await repo.addGrocery('Eggs');
      await repo.setBought(id, true);
      expect(await repo.watchToBuy().first, isEmpty);
      final b = (await repo.watchBought().first).single;
      expect(b.boughtAt, now.toUtc());

      await repo.setBought(id, false);
      expect((await repo.watchToBuy().first).single.boughtAt, isNull);
      expect(await repo.watchBought().first, isEmpty);
    });

    test('planned day: soonest first, no date last, and it can be changed or removed', () async {
      await repo.addGrocery('Soap');
      final rice = await repo.addGrocery('Rice', plannedOn: DateTime(2026, 11, 29));
      await repo.addGrocery('Kangkong', plannedOn: DateTime(2026, 12, 1));
      await repo.addGrocery('Eggs', plannedOn: DateTime(2026, 11, 29));

      var toBuy = await repo.watchToBuy().first;
      expect(toBuy.map((g) => g.name), ['Eggs', 'Rice', 'Kangkong', 'Soap']);
      expect(toBuy.firstWhere((g) => g.id == rice).plannedOn, '2026-11-29');
      expect(groupByPlannedDay(toBuy).map((d) => (d.day, d.items.length)), [
        ('2026-11-29', 2),
        ('2026-12-01', 1),
        (null, 1),
      ]);
      expect(nextShoppingDay(toBuy, now), DateTime(2026, 11, 29));

      await db.delete(db.outbox).go();
      await repo.setPlannedOn(rice, null);
      expect((await ops()).single['fields'], {'planned_on': null});
      toBuy = await repo.watchToBuy().first;
      expect(toBuy.map((g) => g.name), ['Eggs', 'Kangkong', 'Rice', 'Soap']);
    });

    test('next shopping day skips days already past', () async {
      await repo.addGrocery('Rice', plannedOn: DateTime(2026, 11, 20));
      await repo.addGrocery('Eggs', plannedOn: DateTime(2026, 11, 26));
      expect(nextShoppingDay(await repo.watchToBuy().first, now), DateTime(2026, 11, 26));
      now = DateTime(2026, 11, 27);
      expect(nextShoppingDay(await repo.watchToBuy().first, now), isNull);
    });

    test('editing sends only the fields that changed', () async {
      final id = await repo.addGrocery('Eggs', store: 'SM');
      await db.delete(db.outbox).go();
      final g = (await repo.watchToBuy().first).single;
      await repo.editGrocery(g, name: 'Eggs', quantityText: '2 trays', store: 'SM', note: '');
      final sent = await ops();
      expect(sent.single['fields'], {'quantity_text': '2 trays'});
      expect(sent.single['op'], 'update');
      expect((await repo.watchToBuy().first).single.id, id);
    });

    test('clear bought hides bought items but keeps them for history', () async {
      final a = await repo.addGrocery('Eggs');
      await repo.addGrocery('Rice');
      await repo.setBought(a, true);
      now = DateTime(2026, 11, 26, 18);
      await db.delete(db.outbox).go();
      expect(await repo.clearBought(), 1);
      expect(await repo.watchBought().first, isEmpty);
      expect((await repo.watchToBuy().first).single.name, 'Rice');
      final row = (await rawRow(db, 'grocery_items', a))!;
      expect(row['deleted_at'], isNull);
      expect(row['cleared_at'], isNotNull);
      expect((await repo.watchHistory().first).single.name, 'Eggs');
      final sent = await ops();
      expect(sent.single['op'], 'update', reason: 'clear sends an update, not a delete');
      expect((sent.single['fields'] as Map).keys, ['cleared_at']);
    });

    test('ticking a cleared item again puts it back on the bought list', () async {
      final id = await repo.addGrocery('Eggs');
      await repo.setBought(id, true);
      await repo.clearBought();
      await repo.setBought(id, false);
      expect((await repo.watchToBuy().first).single.clearedAt, isNull);
      await repo.setBought(id, true);
      expect((await repo.watchBought().first).single.name, 'Eggs');
    });

    test('changing the day bought keeps the time it was ticked', () async {
      final id = await repo.addGrocery('Eggs');
      await repo.setBought(id, true); // Nov 26, 09:00
      final g = (await repo.watchBought().first).single;
      await repo.setBoughtOn(g, DateTime(2026, 11, 24));
      expect((await repo.watchBought().first).single.boughtAt, DateTime(2026, 11, 24, 9).toUtc());
    });

    test('history is every bought item, newest day first, grouped by day', () async {
      Future<String> buy(String name, DateTime at) async {
        now = at;
        final id = await repo.addGrocery(name, quantityText: '1', store: 'SM');
        await repo.setBought(id, true);
        return id;
      }

      await buy('Rice', DateTime(2026, 11, 22, 10));
      await buy('Oil', DateTime(2026, 11, 22, 10, 5));
      await repo.clearBought();
      await buy('Eggs', DateTime(2026, 11, 26, 8));
      await repo.addGrocery('Milk'); // not bought: not in history
      final removed = await buy('Soap', DateTime(2026, 11, 26, 9));
      await repo.removeGrocery(removed); // removed: not in history

      final days = groupByDay(await repo.watchHistory().first);
      expect(days.map((d) => d.day), [DateTime(2026, 11, 26), DateTime(2026, 11, 22)]);
      expect(days.map((d) => d.items.map((g) => g.name).toList()), [
        ['Eggs'],
        ['Oil', 'Rice'],
      ]);
    });

    test('buy again copies name, quantity and store unless already listed', () async {
      final id = await repo.addGrocery('Eggs', quantityText: '1 tray', store: 'SM');
      await repo.setBought(id, true);
      await repo.clearBought();
      final past = (await repo.watchHistory().first).single;

      expect(await repo.buyAgain(past), isTrue);
      final listed = (await repo.watchToBuy().first).single;
      expect([listed.name, listed.quantityText, listed.store], ['Eggs', '1 tray', 'SM']);
      expect(listed.id, isNot(id));
      expect(await repo.buyAgain(past), isFalse);
      expect(await repo.watchToBuy().first, hasLength(1));
    });
  });

  group('pantry', () {
    test('stock changes go out as increments and fold into the insert', () async {
      final id = await repo.addPantry(name: 'Sardines', unit: 'can', quantity: 6, minQuantity: 2);
      await repo.adjust(id, -1);
      await repo.adjust(id, -1);
      final p = (await repo.watchPantry().first).single;
      expect(p.quantity, 4);
      final sent = await ops();
      expect(sent, hasLength(1), reason: 'unsent changes fold into the insert');
      expect((sent.single['fields'] as Map)['quantity'], 4);
    });

    test('a stock-take sends the difference, not the absolute count', () async {
      final id = await repo.addPantry(name: 'Rice', unit: 'kg', quantity: 5);
      await db.delete(db.outbox).go();
      var p = (await repo.watchPantry().first).single;
      await repo.setQuantity(p, 3.5);
      p = (await repo.watchPantry().first).single;
      expect(p.quantity, 3.5);
      final sent = await ops();
      expect(sent.single['op'], 'increment');
      expect(sent.single['fields'], {'quantity': -1.5});
      await repo.setQuantity(p, 3.5);
      expect(await ops(), hasLength(1), reason: 'no change, nothing sent');
      expect(id, p.id);
    });

    test('editing never writes quantity directly', () async {
      await repo.addPantry(name: 'Oil', quantity: 1);
      await db.delete(db.outbox).go();
      final p = (await repo.watchPantry().first).single;
      await repo.editPantry(p, name: 'Cooking oil', unit: 'bottle', location: 'cabinet', expiresOn: '2027-01-31');
      final fields = (await ops()).single['fields'] as Map;
      expect(fields.keys, unorderedEquals(['name', 'unit', 'location', 'expires_on']));
    });

    test('running low first, then expiring soonest, then by name', () async {
      await repo.addPantry(name: 'Zucchini', quantity: 3);
      await repo.addPantry(name: 'Milk', quantity: 2, expiresOn: '2026-11-28');
      await repo.addPantry(name: 'Yogurt', quantity: 1, expiresOn: '2026-11-25');
      await repo.addPantry(name: 'Coffee', quantity: 1, minQuantity: 1);
      await repo.addPantry(name: 'Apples', quantity: 5, expiresOn: '2027-03-01');
      expect((await repo.watchPantry().first).map((p) => p.name), ['Coffee', 'Yogurt', 'Milk', 'Apples', 'Zucchini']);
    });

    test('add to grocery list skips items already on it', () async {
      await repo.addPantry(name: 'Coffee', quantity: 0, minQuantity: 1);
      final p = (await repo.watchPantry().first).single;
      expect(await repo.addToGrocery(p), isTrue);
      expect(await repo.addToGrocery(p), isFalse);
      await repo.addGrocery(' coffee ');
      expect((await repo.watchToBuy().first).where((g) => g.name.toLowerCase().trim() == 'coffee'), hasLength(2));
    });
  });

  group('helpers', () {
    PantryItem item({double q = 1, double? min, String? expires}) => PantryItem(
      id: 'x',
      householdId: householdId,
      createdAt: now,
      updatedAt: now,
      name: 'x',
      quantity: q,
      minQuantity: min,
      expiresOn: expires,
    );

    test('low only when a minimum is set and reached', () {
      expect(isLow(item(q: 0)), isFalse);
      expect(isLow(item(q: 1, min: 1)), isTrue);
      expect(isLow(item(q: 2, min: 1)), isFalse);
    });

    test('expiry by calendar day', () {
      final today = DateTime(2026, 11, 26, 23, 59);
      expect(expiryOf(item(), today), Expiry.none);
      expect(expiryOf(item(expires: '2026-11-25'), today), Expiry.expired);
      expect(expiryOf(item(expires: '2026-11-26'), today), Expiry.soon);
      expect(expiryOf(item(expires: '2026-12-03'), today), Expiry.soon);
      expect(expiryOf(item(expires: '2026-12-04'), today), Expiry.none);
      expect(daysUntil(DateTime(2026, 11, 27), today), 1);
    });

    test('quantities and dates format plainly', () {
      expect(formatQuantity(2), '2');
      expect(formatQuantity(1.5), '1.5');
      expect(formatQuantity(0.25), '0.25');
      expect(isoDate(DateTime(2027, 1, 5)), '2027-01-05');
    });
  });

  test('two devices using stock offline: both uses count after sync', () async {
    final server = FakeSyncServer();
    final dbB = memoryDb();
    final wA = writer(db, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final a = PantryRepository(db, wA);
    final b = PantryRepository(dbB, wB);
    final syncA = SyncEngine(
      db: db,
      api: server.apiFor(memberId: memberA, deviceId: deviceA),
      clock: wA.clock,
    );
    final syncB = SyncEngine(
      db: dbB,
      api: server.apiFor(memberId: memberB, deviceId: deviceB),
      clock: wB.clock,
    );

    final id = await a.addPantry(name: 'Eggs', quantity: 12);
    final g = await a.addGrocery('Rice');
    await syncA.sync();
    await syncB.sync();

    // Offline on both: each uses eggs; one buys rice, the other un-ticks it.
    await a.adjust(id, -2);
    await b.adjust(id, -3);
    await b.setBought(g, true);
    await syncB.sync();
    await a.setBought(g, false);
    await syncA.sync();
    await syncB.sync();

    for (final r in [a, b]) {
      expect((await r.watchPantry().first).single.quantity, 7);
      expect((await r.watchBought().first).single.name, 'Rice', reason: 'bought stays bought (forward-only)');
    }
    await dbB.close();
  });

  test('upgrading a version 6 database adds cleared_at and keeps the list', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v6 = AppDatabase(NativeDatabase(file));
    final old = PantryRepository(v6, writer(v6, identity(memberId: memberA, deviceId: deviceA)));
    final id = await old.addGrocery('Eggs');
    await v6.customStatement('ALTER TABLE grocery_items DROP COLUMN cleared_at');
    await v6.customStatement('ALTER TABLE grocery_items DROP COLUMN planned_on');
    // Also undo versions 9 and 10 (calendar events).
    await v6.customStatement('ALTER TABLE events DROP COLUMN "ends_on"');
    await v6.customStatement('ALTER TABLE events DROP COLUMN "color"');
    await v6.customStatement('DROP TABLE vehicles'); // added in v11
    await v6.customStatement('DROP TABLE vehicle_logs');
    await v6.customStatement('PRAGMA user_version = 6');
    await v6.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = PantryRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.setBought(id, true);
    expect(await repo.clearBought(), 1);
    expect((await repo.watchHistory().first).single.name, 'Eggs');
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
