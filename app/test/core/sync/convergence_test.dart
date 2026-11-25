import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/hlc.dart';
import 'package:homesync/core/sync/outbox.dart';
import 'package:homesync/core/sync/sync_api.dart';
import 'package:homesync/core/sync/sync_engine.dart';

import '../../support/fake_server.dart';
import '../../support/test_db.dart';

/// Simulated devices that edit offline, sync in random order (with dropped
/// connections and lost responses) and must end up with identical data.
class SimDevice {
  SimDevice(FakeSyncServer server, this.name, String member, String device, int Function() now)
    : db = memoryDb() {
    api = server.apiFor(memberId: member, deviceId: device);
    w = LocalWriter(
      db: db,
      identity: identity(memberId: member, deviceId: device),
      clock: HlcClock(deviceId: device, now: now),
    );
    engine = SyncEngine(db: db, api: api, clock: w.clock, deviceId: device, pushBatchSize: 7, pullPageSize: 5);
  }

  final String name;
  final AppDatabase db;
  late final FakeSyncApi api;
  late final LocalWriter w;
  late final SyncEngine engine;

  Future<void> trySync() async {
    try {
      await engine.sync();
    } on SyncUnavailable {
      // offline or dropped: the next round retries
    }
  }

  Future<List<String>> ids(String table) async => [
    for (final r in await db.customSelect('SELECT id FROM "$table" ORDER BY id').get()) r.read<String>('id'),
  ];

  Future<List<Map<String, Object?>>> dump(String table) async => [
    for (final r in await db.customSelect('SELECT * FROM "$table" ORDER BY id').get()) r.data,
  ];
}

const tables = ['grocery_items', 'pantry_items', 'bills', 'transactions'];

Future<void> runScenario(int seed, {int steps = 120}) async {
  final rnd = Random(seed);
  final server = FakeSyncServer();
  var virtualMs = 1795586000000;
  int clockOf(int skewMs) => virtualMs + skewMs;

  final devices = [
    SimDevice(server, 'A', '01900000-0000-7000-8000-0000000000aa', 'a0000000-0000-7000-8000-00000000000a', () => clockOf(0)),
    // B's date is a day behind, C's is ten minutes ahead.
    SimDevice(server, 'B', '01900000-0000-7000-8000-0000000000bb', 'b0000000-0000-7000-8000-00000000000b', () => clockOf(-86400000)),
    SimDevice(server, 'C', '01900000-0000-7000-8000-0000000000cc', 'c0000000-0000-7000-8000-00000000000c', () => clockOf(600000)),
  ];

  // Expected pantry quantity per record: initial + every increment, anywhere.
  final expectedQty = <String, num>{};
  T pick<T>(List<T> xs) => xs[rnd.nextInt(xs.length)];

  for (var step = 0; step < steps; step++) {
    virtualMs += rnd.nextInt(5000);
    server.timeMs = virtualMs;
    final d = pick(devices);
    final roll = rnd.nextInt(100);

    if (roll < 25) {
      d.api.offline = rnd.nextInt(5) == 0;
      d.api.dropNextPushResponse = rnd.nextInt(5) == 0;
      await d.trySync();
      d.api.offline = false;
      continue;
    }

    final table = pick(tables);
    final known = await d.ids(table);
    final createNew = known.isEmpty || roll < 40;

    switch (table) {
      case 'grocery_items':
        if (createNew) {
          await d.w.insert(table, {'name': 'item ${rnd.nextInt(50)}', 'store': pick(['SM', 'Puregold', null])});
        } else {
          final id = pick(known);
          switch (rnd.nextInt(4)) {
            case 0:
              await d.w.update(table, id, {'name': 'renamed by ${d.name} $step'});
            case 1:
              await d.w.update(table, id, {'is_bought': true, 'bought_at': DateTime.utc(2026, 11, 25, step % 24)});
            case 2:
              await d.w.update(table, id, {'is_bought': false});
            default:
              await d.w.delete(table, id);
          }
        }
      case 'pantry_items':
        if (createNew) {
          final qty = rnd.nextInt(20);
          final id = await d.w.insert(table, {'name': 'stock $step', 'quantity': qty});
          expectedQty[id] = qty;
        } else {
          final id = pick(known);
          if (rnd.nextBool()) {
            final delta = rnd.nextInt(7) - 3;
            await d.w.increment(table, id, {'quantity': delta});
            expectedQty[id] = expectedQty[id]! + delta;
          } else {
            await d.w.update(table, id, {'location': pick(['Ref', 'Cabinet', 'Bodega'])});
          }
        }
      case 'bills':
        if (createNew) {
          await d.w.insert(table, {'name': 'bill $step', 'amount_minor': rnd.nextInt(500000)});
        } else {
          final id = pick(known);
          if (rnd.nextBool()) {
            await d.w.update(table, id, {'amount_minor': rnd.nextInt(500000)});
          } else {
            await d.w.update(table, id, {'is_paid': true, 'paid_at': DateTime.utc(2026, 11, 26)});
          }
        }
      case 'transactions':
        if (createNew) {
          await d.w.insert(table, {
            'amount_minor': -rnd.nextInt(100000),
            'occurred_at': DateTime.utc(2026, 11, 25, step % 24),
            'category': pick(['food', 'transport', 'school']),
          });
        } else {
          await d.w.update(table, pick(known), {'note': 'note from ${d.name} $step'});
        }
    }
  }

  // Back online: sync in random order until nothing is pending anywhere,
  // then one more pull each so everyone has seen the last changes.
  for (final d in devices) {
    d.api
      ..offline = false
      ..dropNextPushResponse = false;
  }
  for (var round = 0; round < 10; round++) {
    final order = [...devices]..shuffle(rnd);
    for (final d in order) {
      await d.engine.sync();
    }
    var pending = 0;
    for (final d in devices) {
      pending += (await d.db.select(d.db.outbox).get()).length;
    }
    if (pending == 0) break;
  }
  for (final d in devices) {
    await d.engine.sync();
  }

  // Every device holds the same rows, column for column.
  for (final table in tables) {
    final reference = await devices.first.dump(table);
    expect(reference.length, server.rows[table]?.length ?? 0, reason: 'seed $seed: $table row count');
    for (final d in devices.skip(1)) {
      expect(await d.dump(table), reference, reason: 'seed $seed: ${d.name} differs from A in $table');
    }
  }

  // No increment lost or double-counted, despite dropped responses.
  for (final d in devices) {
    final rows = await (d.db.select(d.db.pantryItems)..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    for (final r in rows) {
      expect(r.quantity, expectedQty[r.id], reason: 'seed $seed: ${d.name} quantity of ${r.name}');
    }
    expect(await d.db.select(d.db.syncErrors).get(), isEmpty, reason: 'seed $seed: ${d.name} had rejections');
  }

  for (final d in devices) {
    await d.db.close();
  }
}

void main() {
  for (var seed = 1; seed <= 25; seed++) {
    test('three devices converge (seed $seed)', () => runScenario(seed));
  }
}
