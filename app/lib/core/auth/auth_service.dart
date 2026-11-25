import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../sync/outbox.dart';
import '../sync/sync_api.dart';
import 'auth_api.dart';
import 'pin_hash.dart';
import 'secure_store.dart';

/// One person using this install: the signed-in account, or a PIN profile
/// on the shared tablet. Each profile is its own device with its own token.
@immutable
class Profile {
  const Profile({
    required this.memberId,
    required this.name,
    required this.role,
    required this.deviceId,
    this.color,
  });

  factory Profile.fromJson(Map<String, Object?> j) => Profile(
    memberId: j['member_id'] as String,
    name: j['name'] as String,
    role: j['role'] as String,
    deviceId: j['device_id'] as String,
    color: j['color'] as String?,
  );

  final String memberId;
  final String name;
  final String role;
  final String deviceId;
  final String? color;

  bool get isAdult => role == 'owner' || role == 'adult';

  Map<String, Object?> toJson() => {
    'member_id': memberId,
    'name': name,
    'role': role,
    'device_id': deviceId,
    'color': color,
  };
}

@immutable
class Session {
  const Session({
    required this.householdId,
    required this.householdName,
    required this.isShared,
    required this.main,
    required this.active,
  });

  factory Session.fromJson(Map<String, Object?> j) => Session(
    householdId: j['household_id'] as String,
    householdName: j['household_name'] as String,
    isShared: j['is_shared'] as bool,
    main: Profile.fromJson((j['main'] as Map).cast()),
    active: Profile.fromJson((j['active'] as Map).cast()),
  );

  final String householdId;
  final String householdName;

  /// This install is the shared household tablet (PIN profiles).
  final bool isShared;

  /// The account that signed this install in; its token pulls.
  final Profile main;

  /// Who is using the app right now; writes are stamped with this profile.
  final Profile active;

  SyncIdentity get identity => SyncIdentity(
    householdId: householdId,
    memberId: active.memberId,
    deviceId: active.deviceId,
  );

  Session copyWith({Profile? active}) => Session(
    householdId: householdId,
    householdName: householdName,
    isShared: isShared,
    main: main,
    active: active ?? this.active,
  );

  Map<String, Object?> toJson() => {
    'household_id': householdId,
    'household_name': householdName,
    'is_shared': isShared,
    'main': main.toJson(),
    'active': active.toJson(),
  };
}

/// Email sign-in, shared-tablet PIN profiles and token storage
/// (sync-protocol §5.0). Works offline after the first sign-in.
class AuthService extends ChangeNotifier {
  AuthService({required this.store, required this.api, AttemptLimiter? limiter})
    : pinLimiter = limiter ?? AttemptLimiter();

  final SecureStore store;
  final AuthApi api;
  final AttemptLimiter pinLimiter;

  static const _uuid = Uuid();
  static const _sessionKey = 'session';
  static const _installKey = 'install_id';
  static String _tokenKey(String deviceId) => 'token:$deviceId';
  static String _profileDeviceKey(String memberId) => 'profile_device:$memberId';
  static const _profileDevicesKey = 'profile_devices';

  Session? _session;
  Session? get session => _session;
  bool get signedIn => _session != null;

  /// PINs typed while offline, kept in memory only, to fetch the profile's
  /// token once the hub is reachable.
  final Map<String, String> _pendingPins = {};

  /// Device id of this install (the main sign-in), made once.
  Future<String> installId() async {
    final existing = await store.read(_installKey);
    if (existing != null) return existing;
    final id = _uuid.v7();
    await store.write(_installKey, id);
    return id;
  }

  Future<Session?> restore() async {
    final raw = await store.read(_sessionKey);
    _session = raw == null ? null : Session.fromJson((jsonDecode(raw) as Map).cast());
    notifyListeners();
    return _session;
  }

  Future<String?> tokenFor(String deviceId) => store.read(_tokenKey(deviceId));

  Future<Session> signIn({
    required String email,
    required String password,
    required String deviceName,
    required String platform,
    bool isShared = false,
  }) async {
    final deviceId = await installId();
    final r = await api.login(
      email: email,
      password: password,
      deviceId: deviceId,
      deviceName: deviceName,
      platform: platform,
      isShared: isShared,
    );
    await store.write(_tokenKey(r.deviceId), r.token);
    final me = Profile(memberId: r.memberId, name: r.memberName, role: r.role, color: r.color, deviceId: r.deviceId);
    await _save(Session(
      householdId: r.householdId,
      householdName: r.householdName,
      isShared: r.isShared,
      main: me,
      active: me,
    ));
    return _session!;
  }

  /// Switches the shared tablet to [member]'s profile after checking the PIN
  /// against the synced `pin_hash`, offline. Throws [InvalidCredentials].
  Future<Session> switchProfile(Member member, String pin) async {
    final s = _session;
    if (s == null || !s.isShared) throw StateError('PIN profiles need the shared tablet');
    final blocked = pinLimiter.blockedUntil;
    if (blocked != null) throw TooManyPinAttempts(blocked);
    if (member.deletedAt != null || !await verifyPin(pin, member.pinHash)) {
      pinLimiter.failure();
      throw const InvalidCredentials('That PIN is not right.');
    }
    pinLimiter.success();

    final Profile profile;
    if (member.id == s.main.memberId) {
      profile = s.main;
    } else {
      var deviceId = await store.read(_profileDeviceKey(member.id));
      if (deviceId == null) {
        deviceId = _uuid.v7();
        await store.write(_profileDeviceKey(member.id), deviceId);
        await store.write(_profileDevicesKey, jsonEncode([...await _profileDevices(), deviceId]));
      }
      profile = Profile(memberId: member.id, name: member.name, role: member.role, color: member.color, deviceId: deviceId);
      if (await tokenFor(deviceId) == null) _pendingPins[member.id] = pin;
    }
    await _save(s.copyWith(active: profile));
    await fetchMissingProfileTokens();
    return _session!;
  }

  /// Gets tokens for PIN profiles first used offline. Safe to call before
  /// every sync; network failures leave them for next time.
  Future<void> fetchMissingProfileTokens() async {
    final s = _session;
    if (s == null || _pendingPins.isEmpty) return;
    final tabletToken = await tokenFor(s.main.deviceId);
    if (tabletToken == null) return;
    for (final entry in Map.of(_pendingPins).entries) {
      final deviceId = await store.read(_profileDeviceKey(entry.key));
      if (deviceId == null) continue;
      try {
        final r = await api.pinLogin(tabletToken: tabletToken, memberId: entry.key, pin: entry.value, deviceId: deviceId);
        await store.write(_tokenKey(r.deviceId), r.token);
        _pendingPins.remove(entry.key);
      } on InvalidCredentials {
        _pendingPins.remove(entry.key); // PIN changed on the hub meanwhile
      } on SyncUnavailable {
        return;
      }
    }
  }

  /// Signs this install out: revokes tokens on the hub when reachable and
  /// forgets them locally. Local data stays (unsynced changes included).
  Future<void> signOut() async {
    final s = _session;
    if (s == null) return;
    final deviceIds = {s.main.deviceId, s.active.deviceId, ...await _profileDevices()};
    for (final id in deviceIds) {
      final token = await tokenFor(id);
      if (token == null) continue;
      try {
        await api.logout(token);
      } on Exception {
        // offline: the token is dropped locally; the owner can revoke it later
      }
      await store.delete(_tokenKey(id));
    }
    _pendingPins.clear();
    await store.delete(_sessionKey);
    _session = null;
    notifyListeners();
  }

  Future<List<String>> _profileDevices() async {
    final raw = await store.read(_profileDevicesKey);
    return raw == null ? [] : (jsonDecode(raw) as List).cast<String>();
  }

  Future<void> _save(Session s) async {
    await store.write(_sessionKey, jsonEncode(s.toJson()));
    _session = s;
    notifyListeners();
  }
}
