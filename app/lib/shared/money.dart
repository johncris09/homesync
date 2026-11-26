import 'package:intl/intl.dart';

/// Money is stored as integer centavos (`*_minor`), PHP by default.

/// ₱1,240.50 for 124050. [whole] drops centavos when they are zero
/// (₱11,550 for big header figures).
String formatPeso(int minor, {String locale = 'en', bool whole = false}) {
  final showCents = !whole || minor % 100 != 0;
  final f = NumberFormat.currency(locale: locale, symbol: '₱', decimalDigits: showCents ? 2 : 0);
  return f.format(minor / 100);
}

/// Parses what someone typed ("1,240.50", "₱ 85", "12.5") into centavos.
/// Null when it isn't a positive amount with at most two decimals.
int? parsePeso(String input) {
  final s = input.replaceAll(RegExp(r'[₱,\s]'), '');
  final m = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(s);
  if (m == null) return null;
  final cents = (m.group(2) ?? '').padRight(2, '0');
  final value = int.parse(m.group(1)!) * 100 + int.parse(cents);
  return value > 0 ? value : null;
}
