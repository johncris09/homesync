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

TimeOfDay? parseTime(String? hhmm) {
  final parts = hhmm?.split(':');
  if (parts == null || parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  return h == null || m == null ? null : TimeOfDay(hour: h, minute: m);
}

String hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "All day", "3:00 PM" or "3:00 PM – 4:30 PM".
String timeLabel(BuildContext context, CalendarItem i) {
  final l10n = AppLocalizations.of(context);
  final m = MaterialLocalizations.of(context);
  final start = parseTime(i.startTime);
  if (start == null) return l10n.eventAllDay;
  final end = parseTime(i.endTime);
  return end == null ? m.formatTimeOfDay(start) : '${m.formatTimeOfDay(start)} – ${m.formatTimeOfDay(end)}';
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
                          for (final i in items) _ItemTile(item: i, showDay: dayLabel(context, d, today)),
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
                          return _DayCell(
                            day: d,
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.items,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final List<CalendarItem> items;
  final VoidCallback onTap;

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
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final i in items.take(3))
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i.kind == CalendarKind.event ? HomeColors.ube : HomeColors.mangga,
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
        backgroundColor: who == null ? HomeColors.ube : memberColor(who.color),
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
          title: Text('${DateFormat.yMMMEd(locale).format(item.day)} · ${timeLabel(context, item)}'),
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
  late TimeOfDay? _start = parseTime(widget.event?.startTime);
  late TimeOfDay? _end = parseTime(widget.event?.endTime);
  late String _repeat = widget.event?.repeat ?? 'none';
  late String? _memberId = widget.event?.memberId;
  bool _tried = false;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
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
        startTime: start,
        endTime: end,
        repeat: _repeat,
        memberId: _memberId,
        location: _location.text,
        note: _note.text,
      );
    } else {
      await repo.editEvent(
        e,
        title: _title.text,
        startsOn: _date,
        startTime: start,
        endTime: end,
        repeat: _repeat,
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
            if (picked != null) setState(() => _date = picked);
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
