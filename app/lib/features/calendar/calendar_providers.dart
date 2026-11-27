import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../bills/bills_providers.dart';
import '../vehicles/vehicles_providers.dart';
import 'calendar_repository.dart';

final calendarRepoProvider = Provider<CalendarRepository>((ref) {
  final s = ref.watch(servicesProvider);
  return CalendarRepository(s.db, s.writer);
});

final eventsProvider = StreamProvider<List<CalendarEvent>>((ref) => ref.watch(calendarRepoProvider).watchEvents());

/// Everyone but viewers adds events (`write` in api/config/homesync.php).
final canAddEventsProvider = Provider<bool>((ref) {
  final role = ref.watch(authProvider).session?.active.role;
  return role != null && role != 'viewer';
});

/// Adults change any event; others only the ones they added.
final canEditEventProvider = Provider<bool Function(CalendarEvent)>((ref) {
  final active = ref.watch(authProvider).session?.active;
  return (e) {
    if (active == null || active.role == 'viewer') return false;
    return active.isAdult || e.createdBy == active.memberId;
  };
});

/// The month being shown, as its first day.
final calendarMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
  final t = ref.watch(calendarRepoProvider).today;
  return DateTime(t.year, t.month);
});

/// The picked day (today when the screen opens).
final calendarDayProvider = StateProvider.autoDispose<DateTime>((ref) {
  final t = ref.watch(calendarRepoProvider).today;
  return DateTime(t.year, t.month, t.day);
});

/// From the start of the shown month (or today, if earlier) to [comingUpDays]
/// after the later of today and the month's end; bills and subscriptions for
/// adults, and vehicle due dates.
final agendaProvider = Provider.autoDispose<Agenda>((ref) {
  final today = ref.watch(calendarRepoProvider).today;
  final month = ref.watch(calendarMonthProvider);
  final monthEnd = DateTime(month.year, month.month + 1, 0);
  final from = month.isBefore(today) ? month : DateTime(today.year, today.month, today.day);
  final last = monthEnd.isAfter(today) ? monthEnd : today;
  final adult = ref.watch(canSeeBillsProvider);
  return Agenda(
    ref.watch(eventsProvider).value ?? const <CalendarEvent>[],
    from,
    DateTime(last.year, last.month, last.day + comingUpDays),
    bills: adult ? ref.watch(unpaidBillsProvider).value ?? const <Bill>[] : const [],
    subscriptions: adult ? ref.watch(subscriptionsProvider).value ?? const <Subscription>[] : const [],
    vehicles: ref.watch(canSeeVehiclesProvider) ? ref.watch(vehiclesProvider).value ?? const <Vehicle>[] : const [],
  );
});

/// Today and the next [comingUpDays] days, for the home tile.
final upcomingAgendaProvider = Provider<Agenda>((ref) {
  final t = ref.watch(calendarRepoProvider).today;
  final adult = ref.watch(canSeeBillsProvider);
  return Agenda(
    ref.watch(eventsProvider).value ?? const <CalendarEvent>[],
    t,
    DateTime(t.year, t.month, t.day + comingUpDays),
    bills: adult ? ref.watch(unpaidBillsProvider).value ?? const <Bill>[] : const [],
    subscriptions: adult ? ref.watch(subscriptionsProvider).value ?? const <Subscription>[] : const [],
    vehicles: ref.watch(canSeeVehiclesProvider) ? ref.watch(vehiclesProvider).value ?? const <Vehicle>[] : const [],
  );
});
