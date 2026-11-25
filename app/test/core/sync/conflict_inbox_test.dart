import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/hlc.dart';
import 'package:homesync/core/sync/outbox.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/core/sync/sync_status_repository.dart';

import '../../support/fake_server.dart';
import '../../support/test_db.dart';

const owner = '01900000-0000-7000-8000-0000000000aa';
const adult = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

class Phone {
  Phone(FakeSyncServer server, String member, String device, int Function() now) : db = memoryDb() {
    w = LocalWriter(db: db, identity: identity(memberId: member, deviceId: device), clock: HlcClock(deviceId: device, now: now));
    engine = SyncEngine(db: db, api: server.apiFor(memberId: member, deviceId: device), clock: w.clock);
    status = SyncStatusRepository(db);
    inbox = ConflictInbox(w);
  }

  final AppDatabase db;
  late final LocalWriter w;
  late final SyncEngine engine;
  late final SyncStatusRepository status;
  late final ConflictInbox inbox;

  Future<Bill> bill(String id) => (db.select(db.bills)..where((b) => b.id.equals(id))).getSingle();
}

void main() {
  late FakeSyncServer server;
  late Phone a;
  late Phone b;
  late String billId;
  var now = 1795586000000;

  setUp(() async {
    server = FakeSyncServer();
    a = Phone(server, owner, deviceA, () => now);
    b = Phone(server, adult, deviceB, () => now);
    billId = await a.w.insert('bills', {'name': 'Water', 'amount_minor': 120000});
    await a.engine.sync();
    await b.engine.sync();

    // Both change the amount offline; A's edit is newer, so B's value loses.
    now += 1000;
    await b.w.update('bills', billId, {'amount_minor': 124000});
    now += 1000;
    await a.w.update('bills', billId, {'amount_minor': 142000});
    await a.engine.sync();
    await b.engine.sync();
    await a.engine.sync();
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  test('the losing amount shows up in the inbox on every adult device', () async {
    for (final p in [a, b]) {
      final open = await p.status.watchOpenConflicts().first;
      expect(open, hasLength(1));
      expect(open.single.entity, 'bills');
      expect(open.single.field, 'amount_minor');
      expect(open.single.keptValue, '142000');
      expect(open.single.lostValue, '124000');
      expect(open.single.lostBy, adult);
      expect(await p.status.watchConflictIds('bills').first, {billId});
      expect((await p.bill(billId)).amountMinor, 142000);
    }
  });

  test('keep closes the conflict everywhere and leaves the amount', () async {
    final c = (await a.status.watchOpenConflicts().first).single;
    await a.inbox.keep(c);
    expect(await a.status.watchOpenConflicts().first, isEmpty, reason: 'closed locally at once');
    await a.engine.sync();
    await b.engine.sync();
    expect(await b.status.watchOpenConflicts().first, isEmpty);
    expect((await b.bill(billId)).amountMinor, 142000);
  });

  test('revert puts the lost amount back on every device', () async {
    final c = (await a.status.watchOpenConflicts().first).single;
    now += 1000;
    await a.inbox.revert(c);
    expect((await a.bill(billId)).amountMinor, 124000);
    await a.engine.sync();
    await b.engine.sync();
    expect((await b.bill(billId)).amountMinor, 124000);
    expect(await b.status.watchOpenConflicts().first, isEmpty);
  });

  test('pending ids and pending count follow the outbox', () async {
    expect(await a.status.watchPendingCount().first, 0);
    await a.w.update('bills', billId, {'provider': 'Maynilad'});
    expect(await a.status.watchPendingCount().first, 1);
    expect(await a.status.watchPendingIds('bills').first, {billId});
    expect(await a.status.watchPendingIds('grocery_items').first, isEmpty);
  });

  test('devices cannot create conflicts', () {
    expect(() => a.w.insert('conflicts', {'entity': 'bills'}), throwsArgumentError);
  });
}
