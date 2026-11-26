import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/sync/hlc.dart';

const deviceA = '0193a1f2-7c4e-7b2a-9d11-3f6c2a9e8b10';
const deviceB = 'aa93a1f2-7c4e-7b2a-9d11-3f6c2a9e8b10';

void main() {
  group('Hlc format', () {
    test('formats as <13-digit ms>-<4 hex>-<8 hex> and parses back', () {
      const h = Hlc(1795586684123, 3, '3f6c2a9e');
      expect(h.toString(), '1795586684123-0003-3f6c2a9e');
      expect(Hlc.parse('1795586684123-0003-3f6c2a9e'), h);
    });

    test('pads small physical times to 13 digits', () {
      expect(const Hlc(5, 0, '00000000').toString(), '0000000000005-0000-00000000');
    });

    test('rejects malformed strings', () {
      expect(() => Hlc.parse('123-0000-abc'), throwsFormatException);
      expect(Hlc.tryParse('nope'), isNull);
    });

    test('string order equals tuple order', () {
      final list = [
        const Hlc(1000000000001, 0, '00000001'),
        const Hlc(1000000000000, 0xffff, 'ffffffff'),
        const Hlc(1000000000000, 2, '00000000'),
        const Hlc(1000000000000, 10, '00000000'),
        const Hlc(1000000000000, 2, '0000000a'),
      ];
      final byTuple = [...list]..sort();
      final byString = [...list]..sort((a, b) => a.toString().compareTo(b.toString()));
      expect(byString, byTuple);
    });
  });

  group('HlcClock', () {
    test('node is the first 8 hex chars of the device id', () {
      expect(HlcClock(deviceId: deviceA).node, '0193a1f2');
    });

    test('tick is strictly increasing even when the clock stands still', () {
      final clock = HlcClock(deviceId: deviceA, now: () => 1000);
      final a = clock.tick();
      final b = clock.tick();
      final c = clock.tick();
      expect(a, const Hlc(1000, 0, '0193a1f2'));
      expect(b, const Hlc(1000, 1, '0193a1f2'));
      expect(c.compareTo(b), greaterThan(0));
    });

    test('tick never goes backwards when the phone clock jumps back', () {
      var now = 5000;
      final clock = HlcClock(deviceId: deviceA, now: () => now);
      final before = clock.tick();
      now = 1000;
      final after = clock.tick();
      expect(after.compareTo(before), greaterThan(0));
      expect(after.physical, 5000);
    });

    test('counter resets when physical time advances', () {
      var now = 1000;
      final clock = HlcClock(deviceId: deviceA, now: () => now);
      clock.tick();
      clock.tick();
      now = 2000;
      expect(clock.tick(), const Hlc(2000, 0, '0193a1f2'));
    });

    test('counter overflow moves physical forward instead of wrapping', () {
      final clock = HlcClock(
        deviceId: deviceA,
        now: () => 1000,
        last: const Hlc(1000, 0xffff, '0193a1f2'),
      );
      expect(clock.tick(), const Hlc(1001, 0, '0193a1f2'));
    });

    test('receive moves past a remote clock from the future', () {
      final clock = HlcClock(deviceId: deviceA, now: () => 1000);
      final remote = const Hlc(9000, 7, 'aa93a1f2');
      final merged = clock.receive(remote);
      expect(merged.compareTo(remote), greaterThan(0));
      expect(clock.tick().compareTo(remote), greaterThan(0));
    });

    test('receive keeps local time when the remote is older', () {
      final clock = HlcClock(deviceId: deviceA, now: () => 5000);
      final merged = clock.receive(const Hlc(1000, 3, 'aa93a1f2'));
      expect(merged, const Hlc(5000, 0, '0193a1f2'));
    });

    test('a phone with a wrong (late) date orders correctly after one sync', () {
      const trueNow = 1795586684000;
      const oneDay = 24 * 60 * 60 * 1000;

      // Phone B's date is a day behind; phone A is right.
      final a = HlcClock(deviceId: deviceA, now: () => trueNow);
      final b = HlcClock(deviceId: deviceB, now: () => trueNow - oneDay);

      final editOnA = a.tick();
      // Without server time, B's later edit would sort before A's.
      expect(b.copy().tick().compareTo(editOnA), lessThan(0));

      // After one sync B has seen the server time and orders correctly,
      // even for edits made long after the sync.
      b.observeServerTime(trueNow + 10, localNowMs: trueNow - oneDay);
      expect(b.tick().compareTo(editOnA), greaterThan(0));
    });

    test('observed server time is remembered as a skew for later ticks', () {
      var now = 1000;
      final clock = HlcClock(deviceId: deviceA, now: () => now);
      clock.observeServerTime(61000, localNowMs: 1000);
      expect(clock.skewMs, 60000);
      now = 2000;
      expect(clock.tick().physical, 62000);
    });
  });
}
