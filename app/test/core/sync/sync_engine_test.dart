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
    engine = SyncEngine(db: db, api: api, clock: w.clock, pullPageSize: pullPageSize);
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

  @override
  Future<BootstrapResponse> bootstrap() => inner.bootstrap();
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
        memberId: memberA,
        deviceId: deviceA,
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
    await a.w.insert('grocery_items', {'name': 'First'});
    await a.engine.sync();
    final paged = Device(server, member: memberB, device: deviceB, pullPageSize: 2);
    await paged.engine.sync(); // bootstrap, cursor 1
    for (var i = 0; i < 5; i++) {
      await a.w.insert('grocery_items', {'name': 'Item $i'});
    }
    await a.engine.sync();
    final report = await paged.engine.sync();
    expect(report.pulled, 5);
    expect(paged.api.bootstrapCalls, 1);
    expect((await paged.db.select(paged.db.groceryItems).get()).length, 6);
    expect(await SyncStateStore(paged.db).cursor(), 6);
    await paged.db.close();
  });

  test('a new device starts from a snapshot, including rows the hub made itself', () async {
    // The owner row from `homesync:setup` is in the table but not the log.
    server.rows['members'] = {
      memberA: {
        'id': memberA,
        'household_id': householdId,
        'name': 'Mama',
        'role': 'owner',
        'user_id': 1,
        'created_at': '2026-11-26T00:00:00.000Z',
        'updated_at': '2026-11-26T00:00:00.000Z',
        'deleted_at': null,
        'hlc': null,
        'server_version': null,
        'updated_by': null,
        'device_id': null,
      },
    };
    final id = await a.w.insert('grocery_items', {'name': 'Rice'});
    await a.engine.sync();

    final report = await b.engine.sync();
    expect(b.api.bootstrapCalls, 1);
    expect(report.pulled, 2);
    final members = await b.db.select(b.db.members).get();
    expect(members.single.name, 'Mama');
    expect(members.single.role, 'owner');
    expect((await grocery(b, id)).name, 'Rice');
    expect(await SyncStateStore(b.db).cursor(), 1);

    await b.engine.sync();
    expect(b.api.bootstrapCalls, 1, reason: 'later syncs pull from the cursor');
  });

  test('a snapshot keeps rows recorded on this device before the first sync', () async {
    final theirs = await a.w.insert('grocery_items', {'name': 'Rice'});
    await a.engine.sync();
    b.api.offline = true;
    final mine = await b.w.insert('grocery_items', {'name': 'Eggs'});
    await expectLater(b.engine.sync(), throwsA(isA<SyncUnavailable>()));
    b.api.offline = false;
    await b.engine.sync();
    expect((await grocery(b, theirs)).name, 'Rice');
    expect((await grocery(b, mine)).name, 'Eggs');
    await a.engine.sync();
    expect((await grocery(a, mine)).name, 'Eggs');
  });

  test('a local edit made during a sync survives the pull', () async {
    final id = await a.w.insert('grocery_items', {'name': 'Rice'});
    await a.engine.sync();
    await b.engine.sync();
    await b.w.update('grocery_items', id, {'store': 'SM'});
    await b.engine.sync();

    final racing = RacingApi(a.api, () => a.w.update('grocery_items', id, {'note': 'jasmine'}));
    final engine = SyncEngine(db: a.db, api: racing, clock: a.w.clock);
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

  test('shared tablet: each PIN profile pushes with its own token', () async {
    const kidMember = '01900000-0000-7000-8000-0000000000cc';
    const kidDevice = 'c0000000-0000-7000-8000-00000000000c';
    final rice = await a.w.insert('grocery_items', {'name': 'Rice'});

    a.w.identity = identity(memberId: kidMember, deviceId: kidDevice);
    final milk = await a.w.insert('grocery_items', {'name': 'Milk'});
    // Same record edited by two profiles: never folded into one op.
    await a.w.update('grocery_items', rice, {'note': 'kid says brown'});
    expect(await a.outboxCount(), 3);

    // The kid's profile has no token yet: the parent's op goes, the kid's wait.
    final first = await a.engine.sync();
    expect(first.pushed, 1);
    expect(first.waitingForDevice, kidDevice);
    expect(await a.outboxCount(), 2);

    a.api.profiles[kidDevice] = kidMember; // PIN sign-in online gave a token
    final second = await a.engine.sync();
    expect(second.waitingForDevice, isNull);
    expect(await a.outboxCount(), 0);
    expect(server.rows['grocery_items']![milk]!['updated_by'], kidMember);
    expect(server.rows['grocery_items']![milk]!['device_id'], kidDevice);
    expect(server.rows['grocery_items']![rice]!['updated_by'], kidMember);
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
