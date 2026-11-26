import 'dart:async';

import 'sync_api.dart';

enum SyncPhase {
  idle,
  syncing,

  /// Last attempt failed; another is scheduled ([SyncStatus.retryAt]).
  waitingToRetry,

  /// Server needs a newer app. Sync stays paused until the app is updated.
  upgradeRequired,

  /// Token revoked: the user has to sign in again.
  signedOut,
}

class SyncStatus {
  const SyncStatus(this.phase, {this.retryAt, this.error});

  final SyncPhase phase;
  final DateTime? retryAt;
  final Object? error;

  @override
  String toString() => 'SyncStatus($phase, retryAt: $retryAt, error: $error)';
}

/// Decides *when* to sync (sync-protocol §8): on demand, 3 s after a local
/// write, on a fixed period while the app is open, and with backoff after a
/// failure (5 s, 30 s, 2 min, then every 10 min). Platform triggers (resume,
/// connectivity, WorkManager) call [requestSync].
class SyncScheduler {
  SyncScheduler({
    required Future<void> Function() sync,
    this.debounce = const Duration(seconds: 3),
    this.backoff = const [
      Duration(seconds: 5),
      Duration(seconds: 30),
      Duration(minutes: 2),
      Duration(minutes: 10),
    ],
    this.period,
    DateTime Function()? now,
  }) : _sync = sync,
       _now = now ?? DateTime.now;

  final Future<void> Function() _sync;
  final Duration debounce;
  final List<Duration> backoff;

  /// Periodic sync while running (3 min on web); null to disable.
  final Duration? period;
  final DateTime Function() _now;

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncStatus(SyncPhase.idle);
  Timer? _debounceTimer;
  Timer? _retryTimer;
  Timer? _periodicTimer;
  int _failures = 0;
  bool _running = false;
  bool _again = false;
  bool _disposed = false;

  SyncStatus get status => _current;
  Stream<SyncStatus> get statusStream => _status.stream;

  void start() {
    final p = period;
    if (p != null) _periodicTimer ??= Timer.periodic(p, (_) => requestSync());
    requestSync();
  }

  /// A local write happened: sync soon, coalescing bursts of edits.
  void notifyLocalWrite() {
    if (_disposed) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, requestSync);
  }

  /// Sync now (or right after the current sync finishes).
  void requestSync() {
    if (_disposed || _current.phase == SyncPhase.upgradeRequired) return;
    if (_running) {
      _again = true;
      return;
    }
    _retryTimer?.cancel();
    unawaited(_run());
  }

  /// After a new sign-in, clear a signed-out state.
  void resume() {
    if (_current.phase == SyncPhase.signedOut) _emit(const SyncStatus(SyncPhase.idle));
    requestSync();
  }

  Future<void> _run() async {
    _running = true;
    _emit(const SyncStatus(SyncPhase.syncing));
    try {
      await _sync();
      _failures = 0;
      _emit(const SyncStatus(SyncPhase.idle));
    } on UpgradeRequired catch (e) {
      _again = false;
      _emit(SyncStatus(SyncPhase.upgradeRequired, error: e));
    } on SignedOut catch (e) {
      _again = false;
      _emit(SyncStatus(SyncPhase.signedOut, error: e));
    } catch (e) {
      final delay = backoff[_failures < backoff.length ? _failures : backoff.length - 1];
      _failures++;
      _again = false;
      _emit(SyncStatus(SyncPhase.waitingToRetry, retryAt: _now().add(delay), error: e));
      _retryTimer = Timer(delay, requestSync);
    } finally {
      _running = false;
    }
    if (_again && !_disposed) {
      _again = false;
      requestSync();
    }
  }

  void _emit(SyncStatus s) {
    _current = s;
    if (!_disposed) _status.add(s);
  }

  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    _periodicTimer?.cancel();
    _status.close();
  }
}
