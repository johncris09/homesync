import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/app_lock.dart';
import 'package:homesync/core/auth/auth_api.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/auth/pin_hash.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/db/database.dart';
import 'package:homesync/core/sync/sync_api.dart';

const household = '01900000-0000-7000-8000-000000000001';
const owner = '01900000-0000-7000-8000-0000000000aa';
const kid = '01900000-0000-7000-8000-0000000000cc';

class FakeAuthApi implements AuthApi {
  bool online = true;
  final pinLogins = <String>[];
  final loggedOut = <String>[];
  final pins = <String, String>{kid: '4821', owner: '1111'};

  AuthResult _result(
    String token,
    String deviceId,
    String memberId,
    String name,
    String role, {
    bool isShared = true,
  }) => AuthResult(
    token: token,
    deviceId: deviceId,
    isShared: isShared,
    memberId: memberId,
    memberName: name,
    role: role,
    householdId: household,
    householdName: 'Manabo',
  );

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    required String deviceId,
    required String deviceName,
    required String platform,
    required bool isShared,
  }) async {
    if (!online) throw const SyncUnavailable('offline');
    if (password != 'secret') throw const InvalidCredentials('Email or password is incorrect.');
    return _result('tablet-token', deviceId, owner, 'Mama', 'owner', isShared: isShared);
  }

  @override
  Future<AuthResult> pinLogin({
    required String tabletToken,
    required String memberId,
    required String pin,
    required String deviceId,
  }) async {
    if (!online) throw const SyncUnavailable('offline');
    if (pins[memberId] != pin) throw const InvalidCredentials('That PIN is not right.');
    pinLogins.add(memberId);
    return _result('token-$memberId', deviceId, memberId, 'Kid', 'child');
  }

  @override
  Future<void> logout(String token) async {
    if (!online) throw const SyncUnavailable('offline');
    loggedOut.add(token);
  }
}

Member member(String id, String name, String role, String? pin) => Member(
  id: id,
  householdId: household,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  name: name,
  role: role,
  pinHash: pin == null ? null : hashPin(pin),
);

void main() {
  late MemorySecureStore store;
  late FakeAuthApi api;
  late AuthService auth;

  setUp(() {
    store = MemorySecureStore();
    api = FakeAuthApi();
    auth = AuthService(store: store, api: api);
  });

  Future<void> signInTablet() => auth.signIn(
    email: 'mama@example.com',
    password: 'secret',
    deviceName: 'Tablet',
    platform: 'android',
    isShared: true,
  );

  group('pin hashing', () {
    test('hashes in the \$2y\$ form and verifies', () async {
      final h = hashPin('4821');
      expect(h, startsWith(r'$2y$10$'));
      expect(await verifyPin('4821', h), isTrue);
      expect(await verifyPin('0000', h), isFalse);
      expect(await verifyPin('4821', null), isFalse);
      expect(await verifyPin('48', h), isFalse);
      expect(() => hashPin('12a4'), throwsArgumentError);
    });

    test('limiter blocks after 5 failures and doubles the wait', () {
      var now = DateTime.utc(2026);
      final l = AttemptLimiter(now: () => now);
      for (var i = 0; i < 5; i++) {
        l.failure();
      }
      expect(l.blockedUntil, now.add(const Duration(seconds: 30)));
      now = now.add(const Duration(seconds: 31));
      expect(l.blockedUntil, isNull);
      for (var i = 0; i < 5; i++) {
        l.failure();
      }
      expect(l.blockedUntil, now.add(const Duration(seconds: 60)));
    });
  });

  group('AuthService', () {
    test('sign-in stores the token and session; restore brings it back', () async {
      await signInTablet();
      final s = auth.session!;
      expect(s.main.memberId, owner);
      expect(s.active.memberId, owner);
      expect(s.main.deviceId, await auth.installId());
      expect(await auth.tokenFor(s.main.deviceId), 'tablet-token');

      final again = AuthService(store: store, api: api);
      await again.restore();
      expect(again.session!.identity.memberId, owner);
      expect(again.session!.householdName, 'Manabo');
    });

    test('install id is made once', () async {
      expect(await auth.installId(), await auth.installId());
    });

    test('wrong password is reported', () async {
      expect(
        () => auth.signIn(email: 'x@example.com', password: 'nope', deviceName: 'P', platform: 'web'),
        throwsA(isA<InvalidCredentials>()),
      );
    });

    test('PIN profile online: switches and gets its own device and token', () async {
      await signInTablet();
      final s = await auth.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821');
      expect(s.active.memberId, kid);
      expect(s.active.deviceId, isNot(s.main.deviceId));
      expect(s.identity.deviceId, s.active.deviceId);
      expect(await auth.tokenFor(s.active.deviceId), 'token-$kid');
    });

    test('PIN profile offline: verified locally; token fetched once online', () async {
      await signInTablet();
      api.online = false;
      final s = await auth.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821');
      expect(s.active.memberId, kid);
      expect(await auth.tokenFor(s.active.deviceId), isNull);

      api.online = true;
      await auth.fetchMissingProfileTokens();
      expect(await auth.tokenFor(s.active.deviceId), 'token-$kid');
      expect(api.pinLogins, [kid]);
    });

    test('profile keeps the same device id each time', () async {
      await signInTablet();
      final first = await auth.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821');
      await auth.switchProfile(member(owner, 'Mama', 'owner', '1111'), '1111');
      final second = await auth.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821');
      expect(second.active.deviceId, first.active.deviceId);
    });

    test('switching back to the main account uses its own device', () async {
      await signInTablet();
      await auth.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821');
      final s = await auth.switchProfile(member(owner, 'Mama', 'owner', '1111'), '1111');
      expect(s.active.deviceId, s.main.deviceId);
    });

    test('wrong PIN, missing PIN and too many tries are refused', () async {
      await signInTablet();
      final k = member(kid, 'Kid', 'child', '4821');
      await expectLater(auth.switchProfile(k, '0000'), throwsA(isA<InvalidCredentials>()));
      await expectLater(
        auth.switchProfile(member(kid, 'Kid', 'child', null), '0000'),
        throwsA(isA<InvalidCredentials>()),
      );
      for (var i = 0; i < 3; i++) {
        await expectLater(auth.switchProfile(k, '0000'), throwsA(isA<InvalidCredentials>()));
      }
      await expectLater(auth.switchProfile(k, '4821'), throwsA(isA<TooManyPinAttempts>()));
      expect(auth.session!.active.memberId, owner);
    });

    test('tablet asks the setup person for a PIN, only while they are active', () async {
      await signInTablet();
      expect(auth.needsTabletPin, isTrue);
      await auth.setTabletPin('2468');
      expect(auth.needsTabletPin, isFalse);
      expect(store.values['tablet_main_pin_hash'], startsWith(r'$2y$10$'));

      final again = AuthService(store: store, api: api);
      await again.restore();
      expect(again.needsTabletPin, isFalse, reason: 'kept across launches');

      await auth.signOut();
      expect(store.values.containsKey('tablet_main_pin_hash'), isFalse);
      expect(auth.needsTabletPin, isFalse, reason: 'signed out');
    });

    test('a phone (not shared) never asks for a tablet PIN', () async {
      await auth.signIn(email: 'mama@example.com', password: 'secret', deviceName: 'Phone', platform: 'android');
      expect(auth.needsTabletPin, isFalse);
    });

    test('the setup person switches back with the tablet PIN even without a synced one', () async {
      await signInTablet();
      await auth.setTabletPin('2468');
      await auth.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821');
      expect(auth.needsTabletPin, isFalse, reason: 'never asked while someone else is active');
      final mama = member(owner, 'Mama', 'owner', null);
      await expectLater(auth.switchProfile(mama, '1111'), throwsA(isA<InvalidCredentials>()));
      final s = await auth.switchProfile(mama, '2468');
      expect(s.active.memberId, owner);
      expect(s.active.deviceId, s.main.deviceId);
      await expectLater(
        auth.switchProfile(member(kid, 'Kid', 'child', null), '2468'),
        throwsA(isA<InvalidCredentials>()),
        reason: 'the tablet PIN only opens the setup person',
      );
    });

    test('PIN profiles need a signed-in shared tablet', () async {
      final signedOut = AuthService(store: MemorySecureStore(), api: api);
      expect(() => signedOut.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821'), throwsStateError);
    });

    test('sign-out revokes every token it can and forgets them', () async {
      await signInTablet();
      final s = await auth.switchProfile(member(kid, 'Kid', 'child', '4821'), '4821');
      await auth.switchProfile(member(owner, 'Mama', 'owner', '1111'), '1111');
      await auth.signOut();
      expect(auth.session, isNull);
      expect(api.loggedOut.toSet(), {'tablet-token', 'token-$kid'});
      expect(await auth.tokenFor(s.active.deviceId), isNull);
      expect(await auth.tokenFor(s.main.deviceId), isNull);
    });
  });

  group('AppLock', () {
    late DateTime now;
    late AppLock lock;
    var bioOk = true;

    setUp(() async {
      now = DateTime.utc(2026);
      lock = AppLock(store: store, biometricAuth: _Bio(() => bioOk), now: () => now);
      await lock.load();
    });

    test('off by default', () {
      expect(lock.enabled, isFalse);
      expect(lock.locked, isFalse);
    });

    test('enabled lock starts locked on the next launch and opens with the PIN', () async {
      await lock.enable('2468');
      final next = AppLock(store: store, biometricAuth: _Bio(() => true));
      await next.load();
      expect(next.locked, isTrue);
      expect(await next.unlockWithPin('1357'), isFalse);
      expect(next.locked, isTrue);
      expect(await next.unlockWithPin('2468'), isTrue);
      expect(next.locked, isFalse);
    });

    test('locks again after a minute in the background, not sooner', () async {
      await lock.enable('2468');
      lock.onPaused();
      now = now.add(const Duration(seconds: 30));
      lock.onResumed();
      expect(lock.locked, isFalse);
      lock.onPaused();
      now = now.add(const Duration(minutes: 2));
      lock.onResumed();
      expect(lock.locked, isTrue);
    });

    test('biometrics unlock only when turned on', () async {
      await lock.enable('2468');
      lock.onPaused();
      now = now.add(const Duration(minutes: 2));
      lock.onResumed();
      expect(await lock.unlockWithBiometrics('Unlock'), isFalse);
      await lock.enable('2468', biometrics: true);
      lock.onPaused();
      now = now.add(const Duration(minutes: 2));
      lock.onResumed();
      bioOk = false;
      expect(await lock.unlockWithBiometrics('Unlock'), isFalse);
      bioOk = true;
      expect(await lock.unlockWithBiometrics('Unlock'), isTrue);
      expect(lock.locked, isFalse);
    });

    test('wrong PINs block further tries for a while', () async {
      await lock.enable('2468');
      for (var i = 0; i < 5; i++) {
        await lock.unlockWithPin('0000');
      }
      expect(() => lock.unlockWithPin('2468'), throwsA(isA<TooManyPinAttempts>()));
      now = now.add(const Duration(seconds: 31));
      expect(await lock.unlockWithPin('2468'), isTrue);
    });

    test('disable removes the lock', () async {
      await lock.enable('2468');
      await lock.disable();
      final next = AppLock(store: store, biometricAuth: _Bio(() => true));
      await next.load();
      expect(next.enabled, isFalse);
    });
  });
}

class _Bio implements BiometricAuth {
  _Bio(this.result);
  final bool Function() result;
  @override
  Future<bool> available() async => true;
  @override
  Future<bool> authenticate(String reason) async => result();
}
