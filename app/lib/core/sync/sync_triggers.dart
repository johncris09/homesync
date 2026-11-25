import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../app_services.dart';
import 'sync_api.dart';
import 'sync_scheduler.dart';

/// Foreground triggers (sync-protocol §8): app start and resume, and
/// connectivity coming back. Also tells the app lock about backgrounding.
class SyncTriggers {
  SyncTriggers({
    required this.scheduler,
    this.onPause,
    this.onResume,
    Stream<List<ConnectivityResult>>? connectivity,
  }) : _connectivity = connectivity;

  final SyncScheduler scheduler;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  Stream<List<ConnectivityResult>>? _connectivity;

  AppLifecycleListener? _lifecycle;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _online = true;

  void attach() {
    _lifecycle = AppLifecycleListener(
      onResume: () {
        onResume?.call();
        scheduler.requestSync();
      },
      onPause: onPause,
    );
    _sub = (_connectivity ??= Connectivity().onConnectivityChanged).listen(onConnectivity);
    scheduler.start();
  }

  @visibleForTesting
  void onConnectivity(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online && !_online) scheduler.requestSync();
    _online = online;
  }

  void dispose() {
    _lifecycle?.dispose();
    _sub?.cancel();
  }
}

// ------------------------------------------------------ Android background

const backgroundSyncTask = 'homesync.sync';
const _backgroundSyncName = 'homesync-periodic-sync';

bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Registers the ~15 min WorkManager sync. No-op on web.
Future<void> registerBackgroundSync() async {
  if (!_isAndroid) return;
  await Workmanager().initialize(backgroundSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    _backgroundSyncName,
    backgroundSyncTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, input) async {
    final services = await AppServices.open();
    try {
      if (!services.auth.signedIn) return true;
      await services.auth.fetchMissingProfileTokens();
      await services.engine.sync();
      return true;
    } on UpgradeRequired {
      return true; // nothing to retry until the app is updated
    } on SignedOut {
      return true;
    } catch (_) {
      return false; // WorkManager retries with its own backoff
    } finally {
      await services.close();
    }
  });
}
