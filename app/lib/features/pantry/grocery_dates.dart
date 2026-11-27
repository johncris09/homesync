import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'pantry_repository.dart';

/// "Today", "Yesterday" or "Wed, Nov 26" for the day an item was bought.
String boughtDayLabel(BuildContext context, DateTime day, DateTime today) {
  final l10n = AppLocalizations.of(context);
  return switch (daysUntil(day, today)) {
    0 => l10n.groceryToday,
    -1 => l10n.groceryYesterday,
    _ => DateFormat.MMMEd(Localizations.localeOf(context).toString()).format(day),
  };
}

/// Asks for the day an item was bought (today at the latest).
Future<DateTime?> pickBoughtDay(BuildContext context, DateTime current) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return showDatePicker(
    context: context,
    initialDate: current.isAfter(today) ? today : current,
    firstDate: DateTime(today.year - 5),
    lastDate: today,
    helpText: AppLocalizations.of(context).groceryChangeDate,
  );
}

/// "Today", "Tomorrow" or "Sat, Nov 29" for a planned shopping day.
String plannedDayLabel(BuildContext context, DateTime day, DateTime today) {
  final l10n = AppLocalizations.of(context);
  return switch (daysUntil(day, today)) {
    0 => l10n.groceryToday,
    1 => l10n.groceryTomorrow,
    _ => DateFormat.MMMEd(Localizations.localeOf(context).toString()).format(day),
  };
}

/// Asks for the day to buy an item (today or later).
Future<DateTime?> pickPlannedDay(BuildContext context, DateTime? current) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return showDatePicker(
    context: context,
    initialDate: current == null || current.isBefore(today) ? today : current,
    firstDate: today,
    lastDate: DateTime(today.year + 2),
    helpText: AppLocalizations.of(context).groceryPlanHelp,
  );
}
