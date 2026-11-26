import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import 'pin_hash.dart';
import 'secure_store.dart';

abstract interface class BiometricAuth {
  Future<bool> available();
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometrics implements BiometricAuth {
  final _auth = LocalAuthentication();

  @override
  Future<bool> available() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } on Exception {
      return false;
    }
  }
}

/// Optional lock screen over the whole app: a 4-digit PIN, optionally
/// biometrics. Locks on start and after [timeout] in the background.
class AppLock extends ChangeNotifier {
  AppLock({
    required this.store,
    required this.biometricAuth,
    this.timeout = const Duration(minutes: 1),
    AttemptLimiter? limiter,
    DateTime Function()? now,
  }) : limiter = limiter ?? AttemptLimiter(now: now),
       _now = now ?? DateTime.now;

  final SecureStore store;
  final BiometricAuth biometricAuth;
  final Duration timeout;
  final AttemptLimiter limiter;
  final DateTime Function() _now;

  static const _pinKey = 'app_lock_pin_hash';
  static const _bioKey = 'app_lock_biometrics';

  String? _pinHash;
  bool _biometrics = false;
  bool _locked = false;
  DateTime? _pausedAt;

  bool get enabled => _pinHash != null;
  bool get biometrics => _biometrics;
  bool get locked => enabled && _locked;

  /// Reads settings; an enabled lock starts locked.
  Future<void> load() async {
    _pinHash = await store.read(_pinKey);
    _biometrics = await store.read(_bioKey) == 'true';
    _locked = enabled;
    notifyListeners();
  }

  Future<void> enable(String pin, {bool biometrics = false}) async {
    _pinHash = hashPin(pin);
    _biometrics = biometrics;
    await store.write(_pinKey, _pinHash!);
    await store.write(_bioKey, '$biometrics');
    _locked = false;
    notifyListeners();
  }

  Future<void> disable() async {
    _pinHash = null;
    _biometrics = false;
    await store.delete(_pinKey);
    await store.delete(_bioKey);
    _locked = false;
    notifyListeners();
  }

  /// Throws [TooManyPinAttempts] while blocked after repeated wrong PINs.
  Future<bool> unlockWithPin(String pin) async {
    if (limiter.blockedUntil != null) throw TooManyPinAttempts(limiter.blockedUntil!);
    final ok = await verifyPin(pin, _pinHash);
    if (ok) {
      limiter.success();
      _locked = false;
      notifyListeners();
    } else {
      limiter.failure();
    }
    return ok;
  }

  Future<bool> unlockWithBiometrics(String reason) async {
    if (!_biometrics) return false;
    final ok = await biometricAuth.authenticate(reason);
    if (ok) {
      _locked = false;
      notifyListeners();
    }
    return ok;
  }

  void onPaused() => _pausedAt = _now();

  void onResumed() {
    final at = _pausedAt;
    _pausedAt = null;
    if (enabled && at != null && _now().difference(at) >= timeout) {
      _locked = true;
      notifyListeners();
    }
  }
}
