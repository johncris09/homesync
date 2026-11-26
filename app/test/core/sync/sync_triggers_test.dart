import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/sync/sync_scheduler.dart';
import 'package:homesync/core/sync/sync_triggers.dart';

void main() {
  test('connectivity coming back triggers a sync; staying online does not', () {
    fakeAsync((fa) {
      var runs = 0;
      final scheduler = SyncScheduler(sync: () async => runs++);
      final triggers = SyncTriggers(scheduler: scheduler);

      triggers.onConnectivity([ConnectivityResult.wifi]);
      fa.flushMicrotasks();
      expect(runs, 0, reason: 'already online');

      triggers.onConnectivity([ConnectivityResult.none]);
      fa.flushMicrotasks();
      expect(runs, 0);

      triggers.onConnectivity([ConnectivityResult.mobile, ConnectivityResult.vpn]);
      fa.flushMicrotasks();
      expect(runs, 1);

      triggers.onConnectivity([ConnectivityResult.mobile]);
      fa.flushMicrotasks();
      expect(runs, 1);
      scheduler.dispose();
    });
  });
}
