import 'dart:math';

import 'package:flutter/foundation.dart';

import 'auth/app_lock.dart';
import 'auth/auth_api.dart';
import 'auth/auth_service.dart';
import 'auth/secure_store.dart';
import 'db/connection.dart';
import 'db/database.dart';
import 'network/dio_sync_api.dart';
import 'sync/hlc.dart';
import 'sync/outbox.dart';
import 'sync/sync_engine.dart';
import 'sync/sync_scheduler.dart';
import 'sync/sync_state_store.dart';
import 'vault/vault_crypto.dart';
import 'vault/vault_files_api.dart';
import 'vault/vault_session.dart';

/// Everything the app (and the Android background task) needs, built once.
class AppServices {
  AppServices._({
    required this.store,
    required this.db,
    required this.auth,
    required this.appLock,
    required this.clock,
    required this.engine,
    required this.scheduler,
    required this.writer,
    required this.vault,
    required this.vaultCrypto,
    required this.vaultFiles,
  });

  final SecureStore store;
  final AppDatabase db;
  final AuthService auth;
  final AppLock appLock;
  final HlcClock clock;
  final SyncEngine engine;
  final SyncScheduler scheduler;
  final LocalWriter writer;

  /// Document Vault: the key while open, the crypto, and the hub's file store.
  final VaultSession vault;
  final VaultCrypto vaultCrypto;
  final VaultFilesApi vaultFiles;

  static const _dbKey = 'db_key';

  static Future<AppServices> open({SecureStore? secureStore, AppDatabase? database, VaultCrypto? vaultCrypto}) async {
    final store = secureStore ?? FlutterSecureStore();
    final db = database ?? AppDatabase(openAppDatabase(encryptionKey: await _databaseKey(store)));
    final state = SyncStateStore(db);
    var hubVersion = await state.hubVersion();
    final dio = createApiClient(
      onHubVersion: (v) {
        if (v == hubVersion) return;
        hubVersion = v;
        state.setHubVersion(v);
      },
    );

    final auth = AuthService(store: store, api: DioAuthApi(dio));
    await auth.restore();
    final appLock = AppLock(store: store, biometricAuth: LocalAuthBiometrics());
    await appLock.load();

    final clock = await state.loadClock(await auth.installId());
    final engine = SyncEngine(
      db: db,
      api: DioSyncApi(dio, tokenFor: auth.tokenFor, mainDeviceId: () => auth.session!.main.deviceId),
      clock: clock,
    );
    final vaultFiles = DioVaultFilesApi(dio, token: () async => auth.tokenFor(auth.session!.main.deviceId));
    final scheduler = SyncScheduler(
      sync: () async {
        if (!auth.signedIn) return;
        await auth.fetchMissingProfileTokens();
        await engine.sync();
        // Vault files go up after their rows (sync-protocol §7).
        await VaultUploader(db, vaultFiles).uploadPending();
      },
      // sync-protocol §8: every 3 min on web; WorkManager covers Android in
      // the background, this only covers a long foreground session.
      period: kIsWeb ? const Duration(minutes: 3) : const Duration(minutes: 15),
    );
    final writer = LocalWriter(
      db: db,
      identity: auth.session?.identity ?? _noIdentity,
      clock: clock,
      onWrite: scheduler.notifyLocalWrite,
    );

    final vault = VaultSession(store: store);
    var vaultHousehold = auth.session?.householdId;
    var vaultMember = auth.session?.active.memberId;

    // Writes are stamped with whoever is using the app right now.
    auth.addListener(() {
      final s = auth.session;
      writer.identity = s?.identity ?? _noIdentity;
      if (s != null) scheduler.resume();
      // The vault closes when someone else takes over, and forgets its key
      // on sign-out (docs/vault.md).
      if (s == null && vaultHousehold != null) {
        vault.forget(vaultHousehold!);
      } else if (s?.active.memberId != vaultMember) {
        vault.lock();
      }
      vaultHousehold = s?.householdId;
      vaultMember = s?.active.memberId;
    });

    return AppServices._(
      store: store,
      db: db,
      auth: auth,
      appLock: appLock,
      clock: clock,
      engine: engine,
      scheduler: scheduler,
      writer: writer,
      vault: vault,
      vaultCrypto: vaultCrypto ?? VaultCrypto(),
      vaultFiles: vaultFiles,
    );
  }

  /// Placeholder before sign-in; the router keeps signed-out users away from
  /// anything that writes.
  static const _noIdentity = SyncIdentity(householdId: '', memberId: '', deviceId: '');

  /// 256-bit database key, made on first launch and kept in secure storage.
  static Future<String> _databaseKey(SecureStore store) async {
    final existing = await store.read(_dbKey);
    if (existing != null) return existing;
    final rnd = Random.secure();
    final key = List.generate(32, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await store.write(_dbKey, key);
    return key;
  }

  Future<void> close() async {
    scheduler.dispose();
    await db.close();
  }
}
