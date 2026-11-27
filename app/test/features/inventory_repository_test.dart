import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/core/vault/vault_files_api.dart';
import 'package:homesync/features/inventory/inventory_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const memberA = '01900000-0000-7000-8000-0000000000aa';
const memberB = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

/// Holds uploaded files in memory, like the hub's /api/files.
class MemoryFiles implements VaultFilesApi {
  final stored = <String, Uint8List>{};
  final _chunks = <String, Map<int, Uint8List>>{};

  @override
  Future<Set<int>?> status(String sha256) async =>
      stored.containsKey(sha256) ? null : (_chunks[sha256]?.keys.toSet() ?? <int>{});

  @override
  Future<void> putChunk(String sha256, int index, Uint8List bytes) async => (_chunks[sha256] ??= {})[index] = bytes;

  @override
  Future<void> complete(String sha256, int chunks) async {
    final parts = _chunks.remove(sha256)!;
    stored[sha256] = Uint8List.fromList([for (var i = 0; i < chunks; i++) ...parts[i]!]);
  }

  @override
  Future<Uint8List?> download(String sha256) async => stored[sha256];
}

void main() {
  group('repository', () {
    late AppDatabase db;
    late InventoryRepository repo;
    var now = DateTime(2026, 12, 6, 9);

    setUp(() {
      db = memoryDb();
      now = DateTime(2026, 12, 6, 9);
      repo = InventoryRepository(
        db,
        writer(db, identity(memberId: memberA, deviceId: deviceA)),
        now: () => now,
      );
    });
    tearDown(() => db.close());

    Future<InventoryItem> item(String id) => (db.select(db.inventoryItems)..where((i) => i.id.equals(id))).getSingle();
    Future<InventorySummary> summary() async => InventorySummary(await repo.watchItems().first, now);

    test('add, edit only what changed, lend and get it back', () async {
      final id = await repo.add(
        ItemDraft(
          name: 'Aircon',
          category: 'appliance',
          room: ' Kwarto ',
          brand: 'Carrier',
          serialNo: '',
          boughtOn: DateTime(2025, 4, 10),
          priceMinor: 2899900,
          warrantyUntil: DateTime(2027, 4, 10),
        ),
      );
      var a = await item(id);
      expect(a.room, 'Kwarto');
      expect(a.serialNo, isNull);
      expect(a.boughtOn, '2025-04-10');
      expect(a.warrantyUntil, '2027-04-10');

      final before = (await db.select(db.outbox).get()).length;
      await repo.edit(a, ItemDraft.of(a));
      expect((await db.select(db.outbox).get()).length, before, reason: 'nothing changed, nothing sent');
      final d = ItemDraft.of(a);
      await repo.edit(
        a,
        ItemDraft(
          name: d.name,
          category: d.category,
          room: 'Sala',
          brand: d.brand,
          priceMinor: d.priceMinor,
          boughtOn: d.boughtOn,
          warrantyUntil: d.warrantyUntil,
        ),
      );
      final clocks = {
        for (final c in await (db.select(db.fieldClocks)..where((c) => c.entityId.equals(id))).get()) c.field: c.hlc,
      };
      expect(clocks['room']!.compareTo(clocks['price_minor']!), greaterThan(0), reason: 'only the room was sent again');
      expect(clocks['name'], clocks['price_minor']);

      a = await item(id);
      await repo.lend(a, 'Tita Baby');
      a = await item(id);
      expect(a.lentTo, 'Tita Baby');
      expect(a.lentOn, '2026-12-06');
      await repo.returned(a);
      a = await item(id);
      expect(a.lentTo, isNull);
      expect(a.lentOn, isNull);
    });

    test('warranty: active, ending within 30 days, ended', () async {
      final id = await repo.add(ItemDraft(name: 'Ref', category: 'appliance', warrantyUntil: DateTime(2027, 1, 5)));
      expect(warrantyOf(await item(id), now), Warranty.soon);
      expect(warrantyOf(await item(id), DateTime(2026, 11, 1)), Warranty.active);
      expect(warrantyOf(await item(id), DateTime(2027, 1, 5)), Warranty.soon, reason: 'the last day still counts');
      expect(warrantyOf(await item(id), DateTime(2027, 1, 6)), Warranty.ended);
      final none = await repo.add(const ItemDraft(name: 'Sofa', category: 'furniture'));
      expect(warrantyOf(await item(none), now), Warranty.none);
    });

    test('summary: rooms in order with no room last, search, attention, value', () async {
      await repo.add(
        const ItemDraft(name: 'TV', category: 'electronics', room: 'Sala', brand: 'Samsung', priceMinor: 2500000),
      );
      await repo.add(const ItemDraft(name: 'Electric fan', category: 'appliance', room: 'kwarto', priceMinor: 150000));
      await repo.add(const ItemDraft(name: 'Drill', category: 'tools'));
      final ref = await repo.add(
        ItemDraft(name: 'Ref', category: 'appliance', room: 'Kusina', warrantyUntil: DateTime(2026, 12, 20)),
      );
      final ladder = await repo.add(const ItemDraft(name: 'Ladder', category: 'tools', room: 'Garahe'));
      await repo.lend(await item(ladder), 'Kuya Ben', on: DateTime(2026, 11, 2));

      final s = await summary();
      expect(s.count, 5);
      expect(s.totalValue, 2650000);
      expect(s.byRoom().map((g) => g.$1).toList(), ['Garahe', 'Kusina', 'kwarto', 'Sala', '']);
      expect(s.rooms, ['Garahe', 'Kusina', 'kwarto', 'Sala']);
      expect(s.byRoom(query: 'samsung').single.$2.single.name, 'TV');
      expect(s.byRoom(query: 'ben').single.$2.single.name, 'Ladder', reason: 'who borrowed it');
      expect(s.needsAttention.map((i) => i.id).toList(), [ref, ladder]);
    });

    test('a photo is kept here until it is uploaded, then other devices download it', () async {
      final files = MemoryFiles();
      final id = await repo.add(const ItemDraft(name: 'TV', category: 'electronics'));
      final photo = Uint8List.fromList(List.generate(3000, (i) => i % 251));
      await repo.setPhoto(await item(id), photo);
      final sha = (await item(id)).photoSha256!;
      expect(sha, await InventoryRepository.sha256Hex(photo));
      expect((await item(id)).photoSize, 3000);

      expect(await VaultUploader(db, files).uploadPending(), 1);
      expect(files.stored[sha], photo);

      final other = memoryDb();
      final repoB = InventoryRepository(
        other,
        writer(other, identity(memberId: memberB, deviceId: deviceB)),
        files: files,
      );
      expect(await repoB.readPhoto(sha), photo);
      files.stored.clear();
      expect(await repoB.readPhoto(sha), photo, reason: 'kept on the device once downloaded');
      expect(await repoB.readPhoto('0' * 64), isNull);
      await other.close();

      await repo.removePhoto(await item(id));
      expect((await item(id)).photoSha256, isNull);
    });

    test('a photo that is too big is refused', () async {
      final id = await repo.add(const ItemDraft(name: 'TV', category: 'electronics'));
      expect(
        () async => repo.setPhoto(await item(id), Uint8List(inventoryPhotoMaxBytes + 1)),
        throwsA(isA<PhotoTooBig>()),
      );
    });
  });

  test('lent out on one device, moved to another room on another: both stick', () async {
    final server = FakeSyncServer();
    final dbA = memoryDb();
    final dbB = memoryDb();
    final wA = writer(dbA, identity(memberId: memberA, deviceId: deviceA));
    final wB = writer(dbB, identity(memberId: memberB, deviceId: deviceB));
    final a = InventoryRepository(dbA, wA);
    final b = InventoryRepository(dbB, wB);
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

    await a.add(const ItemDraft(name: 'Ladder', category: 'tools', room: 'Garahe'));
    await syncA.sync();
    await syncB.sync();
    await a.lend((await a.watchItems().first).single, 'Kuya Ben');
    final onB = (await b.watchItems().first).single;
    await b.edit(onB, ItemDraft(name: onB.name, category: onB.category, room: 'Bodega'));
    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    for (final repo in [a, b]) {
      final i = (await repo.watchItems().first).single;
      expect(i.lentTo, 'Kuya Ben');
      expect(i.room, 'Bodega');
    }
    await dbA.close();
    await dbB.close();
  });

  test('upgrading a version 14 database adds the inventory table', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v14 = AppDatabase(NativeDatabase(file));
    await v14.customStatement('SELECT 1');
    await v14.customStatement('DROP TABLE inventory_items');
    await v14.customStatement('PRAGMA user_version = 14');
    await v14.close();

    final reopened = AppDatabase(NativeDatabase(file));
    final repo = InventoryRepository(reopened, writer(reopened, identity(memberId: memberA, deviceId: deviceA)));
    await repo.add(const ItemDraft(name: 'TV', category: 'electronics'));
    expect(await repo.watchItems().first, hasLength(1));
    await reopened.close();
    await dir.delete(recursive: true);
  });
}
