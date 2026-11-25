import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

/// 4-digit PINs for shared-tablet profiles and the app lock.
bool isValidPin(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);

/// Bcrypt hash in the `$2y$` form Laravel's `Hash::check` accepts, so the
/// hub verifies the same `pin_hash` the app wrote. Cost 10 keeps the
/// offline check quick on phones and in the browser.
String hashPin(String pin) {
  if (!isValidPin(pin)) throw ArgumentError('PIN must be 4 digits');
  final h = BCrypt.hashpw(pin, BCrypt.gensalt(logRounds: 10));
  return '\$2y\$${h.substring(4)}';
}

/// Checks [pin] against [hash] off the UI thread (inline on web).
Future<bool> verifyPin(String pin, String? hash) async {
  if (hash == null || !isValidPin(pin)) return false;
  return compute(_check, (pin, hash));
}

bool _check((String, String) args) {
  try {
    return BCrypt.checkpw(args.$1, args.$2);
  } on ArgumentError {
    return false;
  }
}

/// Too many wrong PINs; the next try is accepted from [until].
class TooManyPinAttempts implements Exception {
  const TooManyPinAttempts(this.until);
  final DateTime until;
}

/// Slows down PIN guessing: after [maxFailures] wrong tries the next try
/// waits [lockout], doubling with each further lockout.
class AttemptLimiter {
  AttemptLimiter({
    this.maxFailures = 5,
    this.lockout = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final int maxFailures;
  final Duration lockout;
  final DateTime Function() _now;
  int _failures = 0;
  int _lockouts = 0;
  DateTime? _until;

  /// Null when a try is allowed, else the time the next one is.
  DateTime? get blockedUntil {
    final until = _until;
    return until != null && _now().isBefore(until) ? until : null;
  }

  void success() {
    _failures = 0;
    _lockouts = 0;
    _until = null;
  }

  void failure() {
    _failures++;
    if (_failures >= maxFailures) {
      _failures = 0;
      _until = _now().add(lockout * (1 << _lockouts));
      if (_lockouts < 6) _lockouts++;
    }
  }
}
