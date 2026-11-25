import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/outbox.dart';
import 'package:homesync/core/sync/sync_api.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/core/sync/sync_state_store.dart';

import '../../support/fake_server.dart';
import '../../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

class Device {
  Device(FakeSyncServer server, {required String member, required String device, int pullPageSize = 500})
    : db = memoryDb() {
    api = server.apiFor(memberId: member, deviceId: device);
    final id = identity(memberId: member, deviceId: device);
    w = writer(db, id);
    engine = SyncEngine(db: db, api: api, clock: w.clock, deviceId: device, pullPageSize: pullPageSize);
  }

  final AppDatabase db;
  late final FakeSyncApi api;
  late final LocalWriter w;
  late final SyncEngine engine;

  Future<int> outboxCount() async => (await db.select(db.outbox).get()).length;
}

/// Wraps an API and runs [beforePull] between push and pull: a local edit
/// landing while a sync is in progress.
class RacingApi implements SyncApi {
  RacingApi(this.inner, this.beforePull);
  final SyncApi inner;
  Future<void> Function()? beforePull;

  @override
  Future<PushResponse> push(String deviceId, List<Map<String, Object?>> ops) => inner.push(deviceId, ops);

  @override
  Future<PullResponse> pull(int cursor, int limit) async {
    final hook = beforePull;
    beforePull = null;
    if (hook != null) await hook();
    return inner.pull(cursor, limit);
  }
}

void main() {
  late FakeSyncServer server;
  late Device a;
  late Device b;

  setUp(() {
    server = FakeSyncServer();
    a = Device(server, member: memberA, device: deviceA);
    b = Device(server, member: memberB, device: deviceB);
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  Future<GroceryItem> grocery(Device d, String id) =>
      (d.db.select(d.db.groceryItems)..where((g) => g.id.equals(id))).getSingle();

  test('push empties the outbox and the other device pulls the change', () async {
    final id = await a.w.insert('grocery_items', {'name': 'Rice'});
    final report = await a.engine.sync();
    expect(report.pushed, 1);
    expect(await a.outboxCount(), 0);

    await b.engine.sync();
    final row = await grocery(b, id);
    expect(row.name, 'Rice');
    expect(row.serverVersion, 1);
    expect(row.updatedBy, memberA);
    expect(await SyncStateStore(b.db).cursor(), 1);
    expect(await SyncStateStore(b.db).lastSyncedAt(), isNotNull);
  });

  test('the sender gets the server version back on pull', () async {
    final id = await a.w.insert('grocery_items', {'name': 'Rice'});
    await a.engine.sync();
    expect((await grocery(a, id)).serverVersion, 1);
  });

  test('rejected ops leave the outbox and land in sync_errors', () async {
    final id = await a.w.insert('pantry_items', {'name': 'Rice', 'quantity': 3});
    await a.engine.sync();
    // Forge an op the server refuses (absolute counter update).
    await a.db.into(a.db.outbox).insert(
      OutboxCompanion.insert(
        opId: '01937000-0000-7000-8000-000000000001',
        entity: 'pantry_items',
        entityId: id,
        op: 'update',
        fields: '{"quantity": 1}',
        hlc: a.w.clock.tick().toString(),
      ),
    );
    final report = await a.engine.sync();
    expect(report.rejected, 1);
    expect(await a.outboxCount(), 0);
    final err = (await a.db.select(a.db.syncErrors).get()).single;
    expect(err.error, 'not_counter');
    expect(err.entityId, id);
  });

  test('a lost push response is retried safely (duplicate, no double count)', () async {
    final id = await a.w.insert('pantry_items', {'name': 'Rice', 'quantity': 10});
    await a.engine.sync();
    await a.w.increment('pantry_items', id, {'quantity': -1});

    a.api.dropNextPushResponse = true;
    await expectLater(a.engine.sync(), throwsA(isA<SyncUnavailable>()));
    expect(await a.outboxCount(), 1, reason: 'kept until the server answers');

    // A new edit must not fold into the op the server may already have.
    await a.w.increment('pantry_items', id, {'quantity': -2});
    expect(await a.outboxCount(), 2);

    await a.engine.sync();
    expect(server.rows['pantry_items']![id]!['quantity'], 7);
    final row = await (a.db.select(a.db.pantryItems)..where((p) => p.id.equals(id))).getSingle();
    expect(row.quantity, 7);
  });

  test('426 pauses sync and keeps local data', () async {
    await a.w.insert('grocery_items', {'name': 'Rice'});
    a.api.upgradeRequired = true;
    await expectLater(a.engine.sync(), throwsA(isA<UpgradeRequired>()));
    expect(await a.outboxCount(), 1);
    expect((await a.db.select(a.db.groceryItems).get()).length, 1);
  });

  test('pull walks every page and stores the cursor', () async {
    for (var i = 0; i < 5; i++) {
      await a.w.insert('grocery_items', {'name': 'Item $i'});
    }
    await a.engine.sync();
    final paged = Device(server, member: memberB, device: deviceB, pullPageSize: 2);
    final report = await paged.engine.sync();
    expect(report.pulled, 5);
    expect((await paged.db.select(paged.db.groceryItems).get()).length, 5);
    expect(await SyncStateStore(paged.db).cursor(), 5);
    await paged.db.close();
  });

  test('a local edit made during a sync survives the pull', () async {
    final id = await a.w.insert('grocery_items', {'name': 'Rice'});
    await a.engine.sync();
    await b.engine.sync();
    await b.w.update('grocery_items', id, {'store': 'SM'});
    await b.engine.sync();

    final racing = RacingApi(a.api, () => a.w.update('grocery_items', id, {'note': 'jasmine'}));
    final engine = SyncEngine(db: a.db, api: racing, clock: a.w.clock, deviceId: deviceA);
    await engine.sync();

    final row = await grocery(a, id);
    expect(row.store, 'SM', reason: 'remote change applied');
    expect(row.note, 'jasmine', reason: 'pending local edit re-applied on top');
    expect(await a.outboxCount(), 1);

    await a.engine.sync();
    await b.engine.sync();
    expect((await grocery(b, id)).note, 'jasmine');
  });

  test('forward-only: bought stays bought when another device un-ticks offline', () async {
    final id = await a.w.insert('grocery_items', {'name': 'Rice'});
    await a.engine.sync();
    await b.engine.sync();

    await a.w.update('grocery_items', id, {'is_bought': true});
    await b.w.update('grocery_items', id, {'is_bought': true});
    await b.w.update('grocery_items', id, {'is_bought': false, 'name': 'Rice 5kg'});

    await a.engine.sync();
    await b.engine.sync();
    await a.engine.sync();

    for (final d in [a, b]) {
      final row = await grocery(d, id);
      expect(row.isBought, isTrue);
      expect(row.name, 'Rice 5kg');
    }
  });

  test('counters: offline decrements on two devices add up', () async {
    final id = await a.w.insert('pantry_items', {'name': 'Eggs', 'quantity': 12});
    await a.engine.sync();
    await b.engine.sync();

    await a.w.increment('pantry_items', id, {'quantity': -2});
    await b.w.increment('pantry_items', id, {'quantity': -3});
    await a.engine.sync();
    await b.engine.sync();
    await a.engine.sync();

    for (final d in [a, b]) {
      final row = await (d.db.select(d.db.pantryItems)..where((p) => p.id.equals(id))).getSingle();
      expect(row.quantity, 7);
    }
  });

  test('concurrent sync calls share one run', () async {
    await a.w.insert('grocery_items', {'name': 'Rice'});
    final first = a.engine.sync();
    final second = a.engine.sync();
    expect(identical(first, second), isTrue);
    await first;
    expect(server.pushCalls, 1);
  });
}
