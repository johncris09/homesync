/// Hybrid logical clock (docs/sync-protocol.md §4).
///
/// Wire format: `<13-digit ms>-<4 hex counter>-<8 hex node>`. Every part is
/// fixed width, so comparing the strings gives the same order as comparing
/// the (physical, counter, node) tuples.
class Hlc implements Comparable<Hlc> {
  const Hlc(this.physical, this.counter, this.node);

  final int physical;
  final int counter;
  final String node;

  static const maxCounter = 0xffff;
  static final _pattern = RegExp(r'^(\d{13})-([0-9a-f]{4})-([0-9a-f]{8})$');

  static Hlc parse(String value) {
    final m = _pattern.firstMatch(value);
    if (m == null) throw FormatException('Not an HLC', value);
    return Hlc(int.parse(m[1]!), int.parse(m[2]!, radix: 16), m[3]!);
  }

  static Hlc? tryParse(String? value) {
    if (value == null) return null;
    try {
      return parse(value);
    } on FormatException {
      return null;
    }
  }

  @override
  int compareTo(Hlc other) {
    if (physical != other.physical) return physical.compareTo(other.physical);
    if (counter != other.counter) return counter.compareTo(other.counter);
    return node.compareTo(other.node);
  }

  bool operator >(Hlc other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.physical == physical &&
      other.counter == counter &&
      other.node == node;

  @override
  int get hashCode => Object.hash(physical, counter, node);

  @override
  String toString() =>
      '${physical.toString().padLeft(13, '0')}-'
      '${counter.toRadixString(16).padLeft(4, '0')}-$node';
}

/// This device's clock. Not persisted by itself: callers save [last] and
/// [skewMs] (see SyncStateStore) and pass them back on start.
class HlcClock {
  HlcClock({
    required String deviceId,
    Hlc? last,
    int skewMs = 0,
    int Function()? now,
  }) : node = deviceId.replaceAll('-', '').substring(0, 8).toLowerCase(),
       _last = last,
       _skewMs = skewMs,
       _now = now ?? (() => DateTime.now().millisecondsSinceEpoch);

  final String node;
  final int Function() _now;
  Hlc? _last;
  int _skewMs;

  Hlc? get last => _last;

  /// Server time minus phone time, from the latest sync response. Corrects a
  /// phone whose date is wrong.
  int get skewMs => _skewMs;

  int get _wallMs => _now() + _skewMs;

  /// Clock for a change made on this device.
  Hlc tick() => _advance(_wallMs, null);

  /// Merge a clock seen on a pulled change, so later local changes sort after it.
  Hlc receive(Hlc remote) => _advance(_wallMs, remote);

  /// Record `server_time_ms` from a response.
  void observeServerTime(int serverMs, {int? localNowMs}) {
    _skewMs = serverMs - (localNowMs ?? _now());
    final last = _last;
    if (last == null || serverMs > last.physical) {
      _last = Hlc(serverMs, 0, node);
    }
  }

  HlcClock copy() => HlcClock(deviceId: node, last: _last, skewMs: _skewMs, now: _now);

  Hlc _advance(int wall, Hlc? remote) {
    final last = _last;
    var physical = wall;
    if (last != null && last.physical > physical) physical = last.physical;
    if (remote != null && remote.physical > physical) physical = remote.physical;

    var counter = 0;
    if (last != null && physical == last.physical) counter = last.counter + 1;
    if (remote != null && physical == remote.physical && remote.counter + 1 > counter) {
      counter = remote.counter + 1;
    }
    if (counter > Hlc.maxCounter) {
      physical += 1;
      counter = 0;
    }
    return _last = Hlc(physical, counter, node);
  }
}
