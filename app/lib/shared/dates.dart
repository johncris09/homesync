/// Calendar-date helpers. Dates without a time are stored as `YYYY-MM-DD`.
library;

/// Whole calendar days from [today] to [date] (negative when past).
int daysUntil(DateTime date, DateTime today) =>
    DateTime.utc(date.year, date.month, date.day).difference(DateTime.utc(today.year, today.month, today.day)).inDays;

/// `YYYY-MM-DD` for a picked date.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Parses `YYYY-MM-DD` (null when missing or invalid).
DateTime? parseIsoDate(String? s) => s == null ? null : DateTime.tryParse(s);

/// [d] moved [months] on, on day [day] (default: [d]'s day), clamped to the
/// month's length: Jan 31 + 1 month = Feb 28, and back to the 31st in March
/// when [day] is 31.
DateTime addMonths(DateTime d, int months, {int? day}) {
  final first = DateTime(d.year, d.month + months);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  final want = day ?? d.day;
  return DateTime(first.year, first.month, want > lastDay ? lastDay : want);
}
