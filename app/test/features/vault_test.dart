import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/hlc.dart';
import 'package:homesync/core/sync/outbox.dart';
import 'package:homesync/core/sync/sync_engine.dart';
import 'package:homesync/core/sync/sync_status_repository.dart';
import 'package:homesync/core/vault/vault_crypto.dart';
import 'package:homesync/core/vault/vault_files_api.dart';
import 'package:homesync/core/vault/vault_session.dart';
import 'package:homesync/features/vault/vault_repository.dart';

import '../support/fake_server.dart';
import '../support/test_db.dart';

const owner = '01900000-0000-7000-8000-0000000000aa';
const adult = '01900000-0000-7000-8000-0000000000bb';
const deviceA = 'a0000000-0000-7000-8000-00000000000a';
const deviceB = 'b0000000-0000-7000-8000-00000000000b';

String hex(List<int> b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

/// The hub's /api/files, in memory.
class FakeVaultFiles implements VaultFilesApi {
  final chunks = <String, Map<int, Uint8List>>{};
  final stored = <String, Uint8List>{};
  int puts = 0;

  @override
  Future<Set<int>?> status(String sha256) async =>
      stored.containsKey(sha256) ? null : (chunks[sha256]?.keys.toSet() ?? <int>{});

  @override
  Future<void> putChunk(String sha256, int index, Uint8List bytes) async {
    puts++;
    (chunks[sha256] ??= {})[index] = bytes;
  }

  @override
  Future<void> complete(String sha256, int count) async {
    final parts = chunks.remove(sha256)!;
    stored[sha256] = Uint8List.fromList([for (var i = 0; i < count; i++) ...parts[i]!]);
  }

  @override
  Future<Uint8List?> download(String sha256) async => stored[sha256];
}

/// One device with its own database, writer and vault.
class Device {
  Device(this.server, this.files, String member, String device, int Function() now) : db = memoryDb() {
    w = LocalWriter(
      db: db,
      identity: identity(memberId: member, deviceId: device),
      clock: HlcClock(deviceId: device, now: now),
    );
    engine = SyncEngine(
      db: db,
      api: server.apiFor(memberId: member, deviceId: device),
      clock: w.clock,
    );
    store = MemorySecureStore();
    session = VaultSession(store: store);
    repo = VaultRepository(db: db, writer: w, session: session, crypto: VaultCrypto(iterations: 1000), files: files);
    inbox = ConflictInbox(w);
  }

  final FakeSyncServer server;
  final FakeVaultFiles files;
  final AppDatabase db;
  late final LocalWriter w;
  late final SyncEngine engine;
  late final MemorySecureStore store;
  late final VaultSession session;
  late final VaultRepository repo;
  late final ConflictInbox inbox;

  Future<void> sync() async {
    await engine.sync();
    await VaultUploader(db, files).uploadPending();
  }
}

void main() {
  group('crypto', () {
    final crypto = VaultCrypto(iterations: 1000);

    test('PBKDF2-HMAC-SHA256 matches the published test vectors', () async {
      final salt = utf8.encode('salt');
      expect(
        hex(await VaultCrypto(iterations: 1).passphraseKey('password', salt)),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
      expect(
        hex(await VaultCrypto(iterations: 2).passphraseKey('password', salt)),
        'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
      );
      expect(VaultCrypto().iterations, 600000, reason: 'production cost (docs/vault.md)');
    });

    test('sealed values round-trip and fail with the wrong key, place or bytes', () async {
      final key = crypto.newKey();
      final sealed = await crypto.sealJson(key, {'number': 'P1234567B'}, 'homesync/vault_items/1/sealed');
      expect(sealed, isNot(contains('P1234567B')));
      expect(await crypto.openJson(key, sealed, 'homesync/vault_items/1/sealed'), {'number': 'P1234567B'});

      // A fresh nonce each time: the same value never seals the same way.
      expect(
        await crypto.sealJson(key, {'number': 'P1234567B'}, 'a'),
        isNot(await crypto.sealJson(key, {'number': 'P1234567B'}, 'a')),
      );

      await expectLater(
        crypto.openJson(crypto.newKey(), sealed, 'homesync/vault_items/1/sealed'),
        throwsA(isA<VaultDecryptError>()),
      );
      await expectLater(
        crypto.openJson(key, sealed, 'homesync/vault_items/2/sealed'),
        throwsA(isA<VaultDecryptError>()),
      );
      final bytes = base64.decode(sealed)..[20] ^= 1;
      await expectLater(
        crypto.openJson(key, base64.encode(bytes), 'homesync/vault_items/1/sealed'),
        throwsA(isA<VaultDecryptError>()),
      );
      await expectLater(crypto.openJson(key, 'not base64!', 'x'), throwsA(isA<VaultDecryptError>()));
    });

    test('a recovery code reads back however it is typed', () {
      final code = RecoveryCode.random(crypto);
      expect(code.text, matches(RegExp(r'^[0-9A-HJKMNP-TV-Z]{4}(-[0-9A-HJKMNP-TV-Z]{4}){5}$')));
      expect(RecoveryCode.tryParse(code.text)!.bytes, code.bytes);
      expect(RecoveryCode.tryParse(code.text.toLowerCase().replaceAll('-', ' '))!.bytes, code.bytes);
      final typo = code.text.replaceAll('0', 'O').replaceAll('1', 'l');
      expect(RecoveryCode.tryParse(typo)!.bytes, code.bytes, reason: 'O reads as 0, I and L as 1');
      expect(RecoveryCode.tryParse('K7QM-3XRT'), isNull);
      expect(code.lastGroup, code.text.substring(25));
    });

    test('numbers are masked except their ends', () {
      expect(maskNumber('P1234542B'), 'P•••••42B');
      expect(maskNumber('1234-5678-7731'), '••••-••••-•731');
      expect(maskNumber('12'), '12');
    });
  });

  group('repository', () {
    late FakeSyncServer server;
    late FakeVaultFiles files;
    late Device phone;
    var now = 1795600000000;

    setUp(() {
      server = FakeSyncServer();
      files = FakeVaultFiles();
      phone = Device(server, files, owner, deviceA, () => now += 1000);
    });

    tearDown(() => phone.db.close());

    test('setting up writes only wrapped keys, and the passphrase or recovery code opens it again', () async {
      final code = await phone.repo.setUp('bahay kubo sa bukid');
      expect(phone.session.unlocked, isTrue);
      final row = (await phone.repo.keyRow())!;
      expect(row.id, vaultKeyId(householdId));
      expect(row.kdfIterations, 1000);
      final outbox = await phone.db.select(phone.db.outbox).get();
      expect(outbox.single.entity, 'vault_keys');
      expect(
        outbox.single.fields,
        isNot(contains(base64.encode(phone.session.key!))),
        reason: 'the key never leaves raw',
      );
      final key = Uint8List.fromList(phone.session.key!);

      phone.session.lock();
      expect(await phone.repo.unlockWithPassphrase('bahay kubo'), isFalse);
      expect(phone.session.unlocked, isFalse);
      expect(await phone.repo.unlockWithPassphrase('bahay kubo sa bukid'), isTrue);
      expect(phone.session.key, key);

      phone.session.lock();
      expect(await phone.repo.unlockWithRecovery('AAAA-AAAA-AAAA-AAAA-AAAA-AAAA'), isFalse);
      expect(await phone.repo.unlockWithRecovery(code.text.toLowerCase()), isTrue);
      expect(phone.session.key, key);
      await expectLater(phone.repo.setUp('another one!'), throwsStateError);
    });

    test('a new passphrase or recovery code re-wraps the same key; old ones stop working', () async {
      final code = await phone.repo.setUp('first passphrase');
      final id = await phone.repo.saveDoc(
        kind: 'id',
        fields: const VaultFields(title: 'Passport', number: 'P1234542B'),
      );
      await phone.repo.changePassphrase('second passphrase');
      final code2 = await phone.repo.newRecoveryCode();

      phone.session.lock();
      expect(await phone.repo.unlockWithPassphrase('first passphrase'), isFalse);
      expect(await phone.repo.unlockWithRecovery(code.text), isFalse);
      expect(await phone.repo.unlockWithRecovery(code2.text), isTrue);
      phone.session.lock();
      expect(await phone.repo.unlockWithPassphrase('second passphrase'), isTrue);
      final docs = await phone.repo.openAll(await phone.repo.watchItems().first);
      expect(docs.single.item.id, id);
      expect(docs.single.fields!.number, 'P1234542B', reason: 'documents are not re-encrypted');
    });

    test('documents are stored sealed; kind, owner and expiry stay readable while locked', () async {
      await phone.repo.setUp('bahay kubo sa bukid');
      final id = await phone.repo.saveDoc(
        kind: 'id',
        memberId: owner,
        expiresOn: '2026-12-12',
        fields: const VaultFields(title: 'Passport', number: 'P1234542B', issuer: 'DFA', note: 'renew at SM'),
      );
      final raw = (await rawRow(phone.db, 'vault_items', id))!;
      expect(raw['sealed'], isNot(contains('P1234542B')));
      expect(raw['sealed'], isNot(contains('Passport')));
      expect(raw['expires_on'], '2026-12-12');
      final outbox = await phone.db.select(phone.db.outbox).get();
      expect(outbox.map((o) => o.fields).join(), isNot(contains('P1234542B')));

      await phone.repo.saveDoc(
        id: id,
        kind: 'id',
        memberId: owner,
        expiresOn: '2036-12-12',
        fields: const VaultFields(title: 'Passport', number: 'P7654321C'),
      );
      final doc = (await phone.repo.openAll(await phone.repo.watchItems().first)).single;
      expect(doc.fields!.number, 'P7654321C');
      expect(doc.item.expiresOn, '2036-12-12');

      phone.session.lock();
      expect((await phone.repo.watchItems().first).single.kind, 'id');
      await expectLater(phone.repo.openFields(id, doc.item.sealed), throwsStateError);
    });

    test('renew soon: within 60 days of expiry or already expired', () async {
      final repo = VaultRepository(
        db: phone.db,
        writer: phone.w,
        session: phone.session,
        crypto: VaultCrypto(iterations: 1000),
        files: files,
        now: () => DateTime(2026, 11, 27),
      );
      VaultItem item(String? on) => VaultItem(
        id: 'x',
        householdId: householdId,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        kind: 'id',
        sealed: '',
        expiresOn: on,
      );
      expect(repo.renewSoon(item('2027-01-26')), isTrue);
      expect(repo.renewSoon(item('2027-01-27')), isFalse);
      expect(repo.renewSoon(item('2026-01-01')), isTrue);
      expect(repo.renewSoon(item(null)), isFalse);
      expect(repo.daysLeft(item('2026-11-26')), -1);
    });

    test('a file is sealed with its own key, uploaded in chunks after sync, and opened on another device', () async {
      final tablet = Device(server, files, adult, deviceB, () => now += 1000);
      addTearDown(tablet.db.close);
      final code = await phone.repo.setUp('bahay kubo sa bukid');
      final id = await phone.repo.saveDoc(
        kind: 'property',
        fields: const VaultFields(title: 'Land title'),
      );
      final photo = Uint8List.fromList(List.generate(vaultChunkBytes + 100, (i) => i % 251));
      final fileId = await phone.repo.addFile(id, photo, name: 'title.jpg', mime: 'image/jpeg');

      final row = await (phone.db.select(phone.db.vaultFiles)..where((f) => f.id.equals(fileId))).getSingle();
      final blob = await (phone.db.select(phone.db.vaultBlobs)).getSingle();
      expect(blob.needsUpload, isTrue);
      expect(blob.sha256, row.sha256);
      expect(row.size, blob.data.length);
      expect(blob.data.sublist(1, 200), isNot(photo.sublist(0, 199)), reason: 'only ciphertext is kept');
      expect(await phone.repo.readFile(row), photo);
      final meta = (await phone.repo.openMeta([row])).single;
      expect((meta.name, meta.mime, meta.isImage), ('title.jpg', 'image/jpeg', true));

      await phone.sync();
      expect(files.puts, 2, reason: 'two 1 MiB chunks');
      expect(files.stored[row.sha256], blob.data);
      expect((await phone.db.select(phone.db.vaultBlobs).getSingle()).needsUpload, isFalse);
      await phone.sync();
      expect(files.puts, 2, reason: 'nothing left to upload');

      // The adult's device pulls the rows, opens the vault, downloads the file.
      await tablet.sync();
      expect(await tablet.repo.unlockWithPassphrase('bahay kubo sa bukid'), isTrue);
      final theirs = await (tablet.db.select(tablet.db.vaultFiles)).getSingle();
      expect(await tablet.repo.readFile(theirs), photo);
      expect(
        (await tablet.db.select(tablet.db.vaultBlobs).getSingle()).needsUpload,
        isFalse,
        reason: 'cached, not re-uploaded',
      );
      expect(code.text, isNotEmpty);
    });

    test('a file not uploaded yet reads as null; too big a file is refused', () async {
      final tablet = Device(server, FakeVaultFiles(), adult, deviceB, () => now += 1000);
      addTearDown(tablet.db.close);
      await phone.repo.setUp('bahay kubo sa bukid');
      final id = await phone.repo.saveDoc(
        kind: 'id',
        fields: const VaultFields(title: 'UMID'),
      );
      await phone.repo.addFile(id, Uint8List.fromList([1, 2, 3]), name: 'a.png', mime: 'image/png');
      await phone.engine.sync(); // rows only, no upload
      await tablet.sync();
      await tablet.repo.unlockWithPassphrase('bahay kubo sa bukid');
      expect(await tablet.repo.readFile(await tablet.db.select(tablet.db.vaultFiles).getSingle()), isNull);

      await expectLater(
        phone.repo.addFile(id, Uint8List(vaultMaxFileBytes + 1), name: 'big.pdf', mime: 'application/pdf'),
        throwsA(isA<VaultFileTooBig>()),
      );
    });

    test('the key is kept on the device only when asked, and forgotten on sign-out', () async {
      await phone.repo.setUp('bahay kubo sa bukid');
      expect(await phone.session.hasSavedKey(householdId), isFalse);
      phone.session.lock();
      await phone.repo.unlockWithPassphrase('bahay kubo sa bukid', saveKey: true);
      expect(await phone.session.hasSavedKey(householdId), isTrue);
      phone.session.lock();
      expect(await phone.session.openSaved(householdId), isTrue);
      await phone.session.forget(householdId);
      expect(phone.session.unlocked, isFalse);
      expect(await phone.session.openSaved(householdId), isFalse);
    });
  });

  group('never auto-merged', () {
    late FakeSyncServer server;
    late Device a;
    late Device b;
    var now = 1795600000000;

    setUp(() async {
      server = FakeSyncServer();
      final files = FakeVaultFiles();
      a = Device(server, files, owner, deviceA, () => now += 1000);
      b = Device(server, files, adult, deviceB, () => now += 1000);
      await a.repo.setUp('bahay kubo sa bukid');
      await a.sync();
      await b.sync();
      await b.repo.unlockWithPassphrase('bahay kubo sa bukid');
    });

    tearDown(() async {
      await a.db.close();
      await b.db.close();
    });

    Future<VaultFields> fieldsOn(Device d, String id) async {
      final item = await (d.db.select(d.db.vaultItems)..where((i) => i.id.equals(id))).getSingle();
      return (await d.repo.openFields(id, item.sealed))!;
    }

    test('two offline edits of a document: the newer is live, the other is kept, the owner chooses', () async {
      final id = await a.repo.saveDoc(
        kind: 'id',
        fields: const VaultFields(title: 'Passport', number: 'P1'),
      );
      await a.sync();
      await b.sync();

      // Both edit offline; the adult's edit syncs first.
      await b.repo.saveDoc(
        id: id,
        kind: 'id',
        fields: const VaultFields(title: 'Passport', number: 'P-ADULT'),
      );
      await a.repo.saveDoc(
        id: id,
        kind: 'id',
        fields: const VaultFields(title: 'Passport', number: 'P-OWNER'),
      );
      final hlcA = (await a.db.select(a.db.outbox).getSingle()).hlc;
      final hlcB = (await b.db.select(b.db.outbox).getSingle()).hlc;
      final (newer, older) = hlcA.compareTo(hlcB) > 0 ? ('P-OWNER', 'P-ADULT') : ('P-ADULT', 'P-OWNER');
      await b.sync();
      await a.sync();
      await b.sync();

      expect((await fieldsOn(a, id)).number, newer);
      expect((await fieldsOn(b, id)).number, newer);
      final conflict = (await a.status().watchOpenConflicts().first).single;
      expect((conflict.entity, conflict.field), ('vault_items', 'sealed'));
      final lost = await a.repo.openFields(id, jsonDecode(conflict.lostValue!) as String);
      expect(lost!.number, older, reason: 'the other version is kept and can still be read');

      // The owner takes the other version.
      await a.inbox.revert(conflict);
      await a.sync();
      await b.sync();
      expect((await fieldsOn(a, id)).number, older);
      expect((await fieldsOn(b, id)).number, older);
      expect(await b.status().watchOpenConflicts().first, isEmpty);
    });

    test('edits made one after the other, or to different fields, do not conflict', () async {
      final id = await a.repo.saveDoc(
        kind: 'id',
        expiresOn: '2027-01-01',
        fields: const VaultFields(title: 'License'),
      );
      await a.sync();
      await b.sync();
      await b.repo.saveDoc(
        id: id,
        kind: 'id',
        expiresOn: '2027-01-01',
        fields: const VaultFields(title: 'License', number: 'N01'),
      );
      await b.sync();
      await a.sync();
      expect((await fieldsOn(a, id)).number, 'N01');

      // Offline: one changes only the expiry, the other only the sealed fields.
      await a.w.update('vault_items', id, {'expires_on': '2032-01-01'});
      await b.repo.saveDoc(
        id: id,
        kind: 'id',
        expiresOn: '2027-01-01',
        fields: const VaultFields(title: 'License', number: 'N02'),
      );
      await a.sync();
      await b.sync();
      await a.sync();
      expect(await a.status().watchOpenConflicts().first, isEmpty);
    });
  });

  test('upgrading a version 11 database adds the vault tables', () async {
    final dir = await Directory.systemTemp.createTemp('hs-migrate');
    final file = File('${dir.path}/db.sqlite');
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final v11 = AppDatabase(NativeDatabase(file));
    await v11.customStatement('SELECT 1');
    for (final t in ['vault_keys', 'vault_items', 'vault_files', 'vault_blobs']) {
      await v11.customStatement('DROP TABLE "$t"');
    }
    await v11.customStatement('DROP TABLE health_profiles'); // added in v13
    await v11.customStatement('DROP TABLE medicines');
    await v11.customStatement('DROP TABLE med_doses');
    await v11.customStatement('DROP TABLE checkups');
    await v11.customStatement('PRAGMA user_version = 11');
    await v11.close();

    final reopened = AppDatabase(NativeDatabase(file));
    await reopened
        .into(reopened.vaultItems)
        .insert(VaultItemsCompanion.insert(id: 'x', householdId: householdId, kind: 'id', sealed: 'AQ'));
    await reopened.into(reopened.vaultBlobs).insert(VaultBlobsCompanion.insert(sha256: 'ab', data: Uint8List(1)));
    expect((await reopened.select(reopened.vaultItems).getSingle()).kind, 'id');
    expect(await reopened.select(reopened.vaultKeys).get(), isEmpty);
    expect(await reopened.select(reopened.vaultFiles).get(), isEmpty);
    await reopened.close();
    await dir.delete(recursive: true);
  });
}

extension on Device {
  SyncStatusRepository status() => SyncStatusRepository(db);
}
