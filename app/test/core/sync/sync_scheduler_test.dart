import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/sync/sync_api.dart';
import 'package:homesync/core/sync/sync_scheduler.dart';

void main() {
  test('local writes are debounced into one sync 3 s after the last edit', () {
    fakeAsync((fa) {
      var runs = 0;
      final s = SyncScheduler(sync: () async => runs++);
      s.notifyLocalWrite();
      fa.elapse(const Duration(seconds: 2));
      s.notifyLocalWrite();
      fa.elapse(const Duration(seconds: 2));
      expect(runs, 0);
      fa.elapse(const Duration(seconds: 1));
      expect(runs, 1);
      s.dispose();
    });
  });

  test('backoff after failures: 5 s, 30 s, 2 min, then 10 min, reset on success', () {
    fakeAsync((fa) {
      var runs = 0;
      var fail = true;
      final s = SyncScheduler(
        sync: () async {
          runs++;
          if (fail) throw const SyncUnavailable('offline');
        },
      );
      s.requestSync();
      fa.flushMicrotasks();
      expect(runs, 1);
      expect(s.status.phase, SyncPhase.waitingToRetry);

      for (final (delay, expected) in [
        (const Duration(seconds: 5), 2),
        (const Duration(seconds: 30), 3),
        (const Duration(minutes: 2), 4),
        (const Duration(minutes: 10), 5),
        (const Duration(minutes: 10), 6),
      ]) {
        fa.elapse(delay - const Duration(milliseconds: 1));
        expect(runs, expected - 1, reason: 'not before $delay');
        fa.elapse(const Duration(milliseconds: 1));
        expect(runs, expected, reason: 'retried after $delay');
      }

      fail = false;
      fa.elapse(const Duration(minutes: 10));
      expect(s.status.phase, SyncPhase.idle);

      fail = true;
      s.requestSync();
      fa.flushMicrotasks();
      final before = runs;
      fa.elapse(const Duration(seconds: 5));
      expect(runs, before + 1, reason: 'backoff restarts at 5 s');
      s.dispose();
    });
  });

  test('426 stops syncing until the app is updated', () {
    fakeAsync((fa) {
      var runs = 0;
      final s = SyncScheduler(
        sync: () async {
          runs++;
          throw const UpgradeRequired(2);
        },
      );
      s.requestSync();
      fa.flushMicrotasks();
      expect(s.status.phase, SyncPhase.upgradeRequired);
      s.requestSync();
      s.notifyLocalWrite();
      fa.elapse(const Duration(hours: 1));
      expect(runs, 1);
      s.dispose();
    });
  });

  test('401 shows signed out; resume() tries again', () {
    fakeAsync((fa) {
      var signedIn = false;
      final s = SyncScheduler(
        sync: () async {
          if (!signedIn) throw const SignedOut();
        },
      );
      s.requestSync();
      fa.flushMicrotasks();
      expect(s.status.phase, SyncPhase.signedOut);
      signedIn = true;
      s.resume();
      fa.flushMicrotasks();
      expect(s.status.phase, SyncPhase.idle);
      s.dispose();
    });
  });

  test('a request during a sync runs one more sync afterwards', () {
    fakeAsync((fa) {
      var runs = 0;
      final s = SyncScheduler(
        sync: () async {
          runs++;
          await Future<void>.delayed(const Duration(seconds: 1));
        },
      );
      s.requestSync();
      fa.flushMicrotasks();
      s.requestSync();
      s.requestSync();
      fa.elapse(const Duration(seconds: 3));
      expect(runs, 2);
      s.dispose();
    });
  });

  test('periodic sync while running', () {
    fakeAsync((fa) {
      var runs = 0;
      final s = SyncScheduler(sync: () async => runs++, period: const Duration(minutes: 3));
      s.start();
      fa.flushMicrotasks();
      expect(runs, 1);
      fa.elapse(const Duration(minutes: 9));
      expect(runs, 4);
      s.dispose();
    });
  });
}
