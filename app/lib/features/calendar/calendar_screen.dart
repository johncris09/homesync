import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../members/members_screen.dart' show memberColor;
import '../sync/sync_widgets.dart';
import 'calendar_providers.dart';
import 'calendar_repository.dart';
import 'event_colors.dart';

TimeOfDay? parseTime(String? hhmm) {
  final parts = hhmm?.split(':');
  if (parts == null || parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  return h == null || m == null ? null : TimeOfDay(hour: h, minute: m);
}

String hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "All day", "3:00 PM" or "3:00 PM – 4:30 PM" for an event's own times.
String eventTimes(BuildContext context, String? startTime, String? endTime) {
  final l10n = AppLocalizations.of(context);
  final m = MaterialLocalizations.of(context);
  final start = parseTime(startTime);
  if (start == null) return l10n.eventAllDay;
  final end = parseTime(endTime);
  return end == null ? m.formatTimeOfDay(start) : '${m.formatTimeOfDay(start)} – ${m.formatTimeOfDay(end)}';
}

/// The times on the item's day: as [eventTimes], and on a multi-day event
/// "Starts 6:00 PM" on the first day and "Until 3:00 PM" on the last.
String timeLabel(BuildContext context, CalendarItem i) {
  final l10n = AppLocalizations.of(context);
  final m = MaterialLocalizations.of(context);
  if (!i.multiDay) return eventTimes(context, i.startTime, i.endTime);
  final start = parseTime(i.startTime);
  final end = parseTime(i.endTime);
  if (start != null) return l10n.eventStartsAt(m.formatTimeOfDay(start));
  if (end != null) return l10n.eventUntilTime(m.formatTimeOfDay(end));
  return l10n.eventAllDay;
}

/// "Nov 1 – Nov 3".
String rangeLabel(BuildContext context, DateTime from, DateTime to) {
  final f = DateFormat.MMMd(Localizations.localeOf(context).toString());
  return AppLocalizations.of(context).calendarRange(f.format(from), f.format(to));
}

/// "Today", "Tomorrow" or "Fri, Nov 27".
String dayLabel(BuildContext context, DateTime day, DateTime today) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  return switch (daysUntil(day, today)) {
    0 => l10n.calendarToday,
    1 => l10n.calendarTomorrow,
    _ => DateFormat.MMMEd(locale).format(day),
  };
}

String repeatName(AppLocalizations l10n, String repeat) => switch (repeat) {
  'weekly' => l10n.eventWeekly,
  'monthly' => l10n.eventMonthly,
  'yearly' => l10n.eventYearly,
  _ => l10n.eventOnce,
};

/// Calendar: a month to pick a day from, that day's events, and what is
/// coming up. Adults also see bills and subscriptions on their due dates.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(calendarRepoProvider).today;
    final agenda = ref.watch(agendaProvider);
    final day = ref.watch(calendarDayProvider);
    final todays = agenda.on(today);
    final next = agenda.daysAfter(today).firstOrNull;
    final canAdd = ref.watch(canAddEventsProvider);

    final figure = todays.isEmpty ? l10n.calendarFreeToday : l10n.calendarCountToday(todays.length);
    final caption = next == null
        ? l10n.calendarNothingAhead
        : l10n.calendarNext(next.$2.first.title, dayLabel(context, next.$1, today));
    final onDay = agenda.on(day);
    final ahead = agenda.daysAfter(day).where((d) => daysUntil(d.$1, day) <= comingUpDays).take(10).toList();

    return Scaffold(
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => EventForm(day: day),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.eventAdd),
            )
          : null,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: HomeColors.ube,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _MonthCard(),
                const SizedBox(height: 16),
                Text(dayLabel(context, day, today), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (onDay.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l10n.calendarDayEmpty, textAlign: TextAlign.center),
                  )
                else
                  Card(
                    child: Column(children: [for (final i in onDay) _ItemTile(item: i)]),
                  ),
                if (ahead.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.calendarComingUp, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (final (d, items) in ahead)
                          for (final i in items)
                            _ItemTile(
                              item: i,
                              showDay: i.multiDay
                                  ? rangeLabel(context, i.spanStart, i.spanEnd)
                                  : dayLabel(context, d, today),
                            ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends ConsumerWidget {
  const _MonthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final m = MaterialLocalizations.of(context);
    final today = ref.watch(calendarRepoProvider).today;
    final month = ref.watch(calendarMonthProvider);
    final day = ref.watch(calendarDayProvider);
    final agenda = ref.watch(agendaProvider);

    final first = m.firstDayOfWeekIndex; // 0 = Sunday
    final lead = (month.weekday % 7 - first + 7) % 7;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final rows = (lead + days + 6) ~/ 7;

    final layout = BandLayout(agenda, month, DateTime(month.year, month.month, days));

    // Lanes drawn in a week row: up to its highest used lane, so a quiet week
    // keeps thick bands even when another week of the month is busy.
    int rowLanes(int row) {
      var most = 0;
      for (var col = 0; col < 7; col++) {
        final n = row * 7 + col - lead + 1;
        if (n < 1 || n > days) continue;
        final here = layout.on(DateTime(month.year, month.month, n));
        final used = here.lastIndexWhere((i) => i != null) + 1;
        if (used > most) most = used;
      }
      return most;
    }

    void moveMonth(int by) {
      final next = DateTime(month.year, month.month + by);
      ref.read(calendarMonthProvider.notifier).state = next;
      final isThisMonth = next.year == today.year && next.month == today.month;
      ref.read(calendarDayProvider.notifier).state = isThisMonth ? DateTime(today.year, today.month, today.day) : next;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.calendarPrevMonth,
                  onPressed: () => moveMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM(locale).format(month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.calendarNextMonth,
                  onPressed: () => moveMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Text(
                      m.narrowWeekdays[(first + i) % 7],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (var row = 0; row < rows; row++)
              Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final n = row * 7 + col - lead + 1;
                          if (n < 1 || n > days) return const SizedBox(height: 44);
                          final d = DateTime(month.year, month.month, n);
                          final here = layout.on(d).take(rowLanes(row)).toList();
                          final left = col > 0 && n > 1 ? layout.on(DateTime(d.year, d.month, n - 1)) : null;
                          final right = col < 6 && n < days ? layout.on(DateTime(d.year, d.month, n + 1)) : null;
                          return _DayCell(
                            day: d,
                            bands: [
                              for (var l = 0; l < here.length; l++)
                                if (here[l] case final i?)
                                  _Band(
                                    color: bandTint(
                                      eventColor(i.event!.color) ?? HomeColors.ube,
                                      stacked: here.length > 1,
                                    ),
                                    joinLeft: BandLayout.same(i, left?[l]),
                                    joinRight: BandLayout.same(i, right?[l]),
                                  )
                                else
                                  null,
                            ],
                            more: layout.hiddenOn(d),
                            selected: daysUntil(d, day) == 0,
                            isToday: daysUntil(d, today) == 0,
                            items: agenda.on(d),
                            onTap: () => ref.read(calendarDayProvider.notifier).state = d,
                          );
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// One lane of a multi-day band in a day cell.
class _Band {
  const _Band({required this.color, required this.joinLeft, required this.joinRight});

  final Color color;

  /// The same occurrence goes on to the neighbouring day in the same row.
  final bool joinLeft;
  final bool joinRight;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.items,
    required this.onTap,
    this.bands = const [],
    this.more = 0,
  });

  final DateTime day;

  /// Multi-day events on this day, one per lane (null = free lane): soft bands
  /// stacked behind the number, joined to the days they go on to.
  final List<_Band?> bands;

  /// Multi-day events here that have no lane (shown as "+").
  final int more;
  final bool selected;
  final bool isToday;
  final List<CalendarItem> items;
  final VoidCallback onTap;

  /// Lane [l] of [bands]: lanes share the 26 px behind the number.
  Widget _lane(int l, _Band b) {
    const gap = 2.0;
    final height = (26 - gap * (bands.length - 1)) / bands.length;
    final radius = Radius.circular(height / 2);
    return Positioned(
      key: Key('band-${isoDate(day)}-$l'),
      left: 0,
      right: 0,
      top: 2 + l * (height + gap),
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: b.joinLeft ? ColoredBox(color: b.color) : const SizedBox()),
          Container(
            width: 30,
            decoration: BoxDecoration(
              color: b.color,
              borderRadius: BorderRadius.horizontal(
                left: b.joinLeft ? Radius.zero : radius,
                right: b.joinRight ? Radius.zero : radius,
              ),
            ),
          ),
          Expanded(child: b.joinRight ? ColoredBox(color: b.color) : const SizedBox()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      key: Key('day-${isoDate(day)}'),
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (var l = 0; l < bands.length; l++)
                    if (bands[l] case final b?) _lane(l, b),
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? HomeColors.ube : null,
                      border: isToday && !selected ? Border.all(color: HomeColors.ube, width: 1.5) : null,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected ? Colors.white : HomeColors.narra,
                        fontWeight: isToday || selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (more > 0) Icon(Icons.add, key: Key('more-${isoDate(day)}'), size: 9, color: HomeColors.narra),
                for (final i in items.where((i) => !i.multiDay).take(3))
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: switch (i.kind) {
                        CalendarKind.event => eventColor(i.event?.color) ?? HomeColors.ube,
                        CalendarKind.vehicle || CalendarKind.checkup => HomeColors.dagat,
                        _ => HomeColors.mangga,
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item, this.showDay});

  final CalendarItem item;

  /// Day label for the coming-up list.
  final String? showDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final members = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m};
    final event = item.event;

    if (item.kind == CalendarKind.checkup) {
      final who = members[item.memberId]?.name;
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: HomeColors.dagat,
          foregroundColor: Colors.white,
          child: Icon(item.dueKind == 'vaccine' ? Icons.vaccines_outlined : Icons.medical_services_outlined),
        ),
        title: Text(item.title),
        subtitle: Text(
          [?showDay, l10n.calendarCheckupDue(item.dueKind ?? 'checkup'), timeLabel(context, item), ?who].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.health),
      );
    }

    if (item.kind == CalendarKind.vehicle) {
      return ListTile(
        leading: const CircleAvatar(
          backgroundColor: HomeColors.dagat,
          foregroundColor: Colors.white,
          child: Icon(Icons.directions_car_outlined),
        ),
        title: Text(item.title),
        subtitle: Text([?showDay, l10n.calendarVehicleDue(item.dueKind ?? 'pms')].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.vehicles),
      );
    }

    if (event == null) {
      final what = item.kind == CalendarKind.bill ? l10n.calendarBillDue : l10n.calendarSubscriptionDue;
      final money = formatPeso(item.amountMinor ?? 0, locale: locale);
      return ListTile(
        leading: const CircleAvatar(
          backgroundColor: HomeColors.mangga,
          foregroundColor: HomeColors.narra,
          child: Icon(Icons.receipt_long_outlined),
        ),
        title: Text(item.title),
        subtitle: Text([?showDay, '$what · $money'].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.bills),
      );
    }

    final who = members[item.memberId];
    final canEdit = ref.watch(canEditEventProvider)(event);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: eventColor(event.color) ?? (who == null ? HomeColors.ube : memberColor(who.color)),
        foregroundColor: Colors.white,
        child: Icon(event.repeat == 'yearly' ? Icons.cake_outlined : Icons.event_outlined),
      ),
      title: Text(item.title),
      subtitle: Text([?showDay, timeLabel(context, item), ?event.location].join(' · ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(who?.name ?? l10n.eventEveryone, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 4),
          SyncMarker(entity: 'events', id: event.id),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => canEdit ? EventForm(event: event) : _EventDetails(item: item),
      ),
    );
  }
}

/// Read-only view for people who can't change the event.
class _EventDetails extends ConsumerWidget {
  const _EventDetails({required this.item});

  final CalendarItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final e = item.event!;
    final names = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m.name};
    return SheetBody(
      title: e.title,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule),
          title: Text(
            item.multiDay
                ? '${l10n.calendarRange(DateFormat.yMMMEd(locale).format(item.spanStart), DateFormat.yMMMEd(locale).format(item.spanEnd))}'
                      ' · ${eventTimes(context, e.startTime, e.endTime)}'
                : '${DateFormat.yMMMEd(locale).format(item.day)} · ${timeLabel(context, item)}',
          ),
          subtitle: Text(repeatName(l10n, e.repeat)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text(names[e.memberId] ?? l10n.eventEveryone),
        ),
        if (e.location != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(e.location!),
          ),
        if (e.note != null)
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.notes), title: Text(e.note!)),
        if (e.createdBy != null)
          Text(l10n.eventAddedBy(names[e.createdBy] ?? l10n.someone), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Add or edit an event. Changes to a repeating event apply to every date.
class EventForm extends ConsumerStatefulWidget {
  const EventForm({super.key, this.event, this.day});

  final CalendarEvent? event;

  /// Date for a new event.
  final DateTime? day;

  @override
  ConsumerState<EventForm> createState() => _EventFormState();
}

class _EventFormState extends ConsumerState<EventForm> {
  late final _title = TextEditingController(text: widget.event?.title ?? '');
  late final _location = TextEditingController(text: widget.event?.location ?? '');
  late final _note = TextEditingController(text: widget.event?.note ?? '');
  late DateTime _date = parseIsoDate(widget.event?.startsOn) ?? widget.day ?? ref.read(calendarRepoProvider).today;

  /// Last day of a multi-day event; null = one day.
  late DateTime? _until = parseIsoDate(widget.event?.endsOn);
  late TimeOfDay? _start = parseTime(widget.event?.startTime);
  late TimeOfDay? _end = parseTime(widget.event?.endTime);
  late String _repeat = widget.event?.repeat ?? 'none';
  late String? _memberId = widget.event?.memberId;
  late String _color = eventColor(widget.event?.color) == null ? eventColorDefault : widget.event!.color!;
  bool _tried = false;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  /// How many days the event lasts.
  int get _days => _until == null ? 1 : daysUntil(_until!, _date) + 1;

  bool get _tooLong {
    final max = maxSpanDays(_repeat);
    return max != null && _days > max;
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _tooLong) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(calendarRepoProvider);
    final start = _start == null ? null : hhmm(_start!);
    final end = _end == null ? null : hhmm(_end!);
    final e = widget.event;
    if (e == null) {
      await repo.addEvent(
        title: _title.text,
        startsOn: _date,
        endsOn: _until,
        startTime: start,
        endTime: end,
        repeat: _repeat,
        color: _color,
        memberId: _memberId,
        location: _location.text,
        note: _note.text,
      );
    } else {
      await repo.editEvent(
        e,
        title: _title.text,
        startsOn: _date,
        endsOn: _until,
        startTime: start,
        endTime: end,
        repeat: _repeat,
        color: _color,
        memberId: _memberId,
        location: _location.text,
        note: _note.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) => showTimePicker(context: context, initialTime: initial);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final m = MaterialLocalizations.of(context);
    final today = ref.read(calendarRepoProvider).today;
    final members = [
      for (final mem in ref.watch(membersProvider).value ?? const <Member>[])
        if (mem.role != 'viewer') mem,
    ];

    return SheetBody(
      title: widget.event == null ? l10n.eventAdd : l10n.eventEdit,
      children: [
        TextField(
          key: const Key('event-title'),
          controller: _title,
          autofocus: widget.event == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.eventTitle,
            hintText: l10n.eventTitleHint,
            errorText: _tried && _title.text.trim().isEmpty ? l10n.eventTitleRequired : null,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(DateFormat.yMMMEd(locale).format(_date)),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(today.year - 100),
              lastDate: DateTime(today.year + 5),
            );
            if (picked == null) return;
            setState(() {
              // Moving the start keeps how many days it lasts.
              if (_until != null) _until = DateTime(picked.year, picked.month, picked.day + _days - 1);
              _date = picked;
            });
          },
        ),
        SwitchListTile(
          key: const Key('event-several-days'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventSeveralDays),
          value: _until != null,
          onChanged: (on) => setState(() => _until = on ? DateTime(_date.year, _date.month, _date.day + 1) : null),
        ),
        if (_until != null)
          ListTile(
            key: const Key('event-until'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available_outlined),
            title: Text(l10n.eventUntilDate(DateFormat.yMMMEd(locale).format(_until!))),
            subtitle: Text(
              _tooLong ? l10n.eventTooLong(maxSpanDays(_repeat)!) : l10n.eventDayCount(_days),
              style: _tooLong ? const TextStyle(color: HomeColors.gumamela) : null,
            ),
            onTap: () async {
              final first = DateTime(_date.year, _date.month, _date.day + 1);
              final max = maxSpanDays(_repeat);
              final last = max == null
                  ? DateTime(_date.year + 5)
                  : DateTime(_date.year, _date.month, _date.day + max - 1);
              final picked = await showDatePicker(
                context: context,
                initialDate: _until!.isAfter(last) ? last : (_until!.isBefore(first) ? first : _until!),
                firstDate: first,
                lastDate: last,
              );
              if (picked != null) setState(() => _until = picked);
            },
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventAllDay),
          value: _start == null,
          onChanged: (allDay) async {
            if (allDay) {
              setState(() {
                _start = null;
                _end = null;
              });
              return;
            }
            final t = await _pickTime(const TimeOfDay(hour: 9, minute: 0));
            if (t != null) setState(() => _start = t);
          },
        ),
        if (_start != null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text(m.formatTimeOfDay(_start!)),
                  onPressed: () async {
                    final t = await _pickTime(_start!);
                    if (t != null) setState(() => _start = t);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text(_end == null ? l10n.eventEndTime : m.formatTimeOfDay(_end!)),
                  onPressed: () async {
                    final t = await _pickTime(_end ?? TimeOfDay(hour: (_start!.hour + 1) % 24, minute: _start!.minute));
                    if (t != null) setState(() => _end = t);
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 'none', label: Text(l10n.eventOnce)),
            ButtonSegment(value: 'weekly', label: Text(l10n.eventWeekly)),
            ButtonSegment(value: 'monthly', label: Text(l10n.eventMonthly)),
            ButtonSegment(value: 'yearly', label: Text(l10n.eventYearly)),
          ],
          selected: {_repeat},
          onSelectionChanged: (s) => setState(() => _repeat = s.first),
        ),
        const SizedBox(height: 16),
        Text(l10n.eventColour, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final name in eventColorNames)
              Tooltip(
                message: eventColorLabel(l10n, name),
                child: Semantics(
                  selected: _color == name,
                  button: true,
                  child: InkResponse(
                    key: Key('event-colour-$name'),
                    radius: 22,
                    onTap: () => setState(() => _color = name),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: eventColor(name),
                        border: _color == name ? Border.all(color: HomeColors.capiz, width: 3) : null,
                        boxShadow: _color == name ? const [BoxShadow(color: HomeColors.narra, spreadRadius: 2)] : null,
                      ),
                      child: _color == name ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.eventForWho, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.eventEveryone),
              selected: _memberId == null,
              onSelected: (_) => setState(() => _memberId = null),
            ),
            for (final mem in members)
              ChoiceChip(
                avatar: CircleAvatar(backgroundColor: memberColor(mem.color)),
                label: Text(mem.name),
                selected: _memberId == mem.id,
                onSelected: (_) => setState(() => _memberId = mem.id),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('event-location'),
          controller: _location,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.eventLocation),
        ),
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(labelText: l10n.eventNote),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
        if (widget.event != null)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              await ref.read(calendarRepoProvider).removeEvent(widget.event!.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.eventRemove),
          ),
      ],
    );
  }
}
