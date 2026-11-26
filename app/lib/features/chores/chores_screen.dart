import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/sheet_body.dart';
import '../members/members_screen.dart' show memberColor;
import '../sync/sync_widgets.dart';
import 'chores_providers.dart';
import 'chores_repository.dart';

/// Weekday name for 1 (Monday) .. 7 (Sunday).
String weekdayName(String locale, int weekday) =>
    DateFormat.EEEE(locale).format(DateTime(2026, 11, 22 + weekday)); // Nov 23, 2026 is a Monday

/// "Daily", "Every Monday", "Once, Dec 5".
String repeatLabel(AppLocalizations l10n, String locale, Chore c) => switch (c.repeat) {
  'weekly' => l10n.choreEveryWeekday(weekdayName(locale, c.weekday ?? 1)),
  'once' => l10n.choreOnceOn(DateFormat.MMMd(locale).format(parseIsoDate(c.dueOn) ?? DateTime.now())),
  _ => l10n.choreDaily,
};

/// Chores: today's list for everyone, ticked off by whoever does them.
class ChoresScreen extends ConsumerWidget {
  const ChoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final board = ref.watch(choreBoardProvider);
    final manage = ref.watch(canManageChoresProvider);
    final adult = manage;

    final figure = board.today.isEmpty
        ? l10n.choresNoneToday
        : board.left == 0
        ? l10n.choresAllDone
        : l10n.choresLeft(board.left);
    final caption = !adult && board.mineLeft > 0
        ? l10n.choresMineCaption(board.mineLeft)
        : l10n.choresDoneCaption(board.doneCount);

    return Scaffold(
      floatingActionButton: manage
          ? FloatingActionButton.extended(
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const ChoreForm(),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.choreAdd),
            )
          : null,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: HomeColors.dagat,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.choresToday, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (board.today.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      manage && board.upcoming.isEmpty ? l10n.choresEmptyAdult : l10n.choresEmpty,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Card(
                    child: Column(children: [for (final t in board.today) _TodayTile(item: t)]),
                  ),
                if (board.upcoming.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.choresComingUp, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (final u in board.upcoming)
                          _ChoreTile(chore: u.chore, subtitle: DateFormat.MMMEd(locale).format(u.on)),
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

class _TodayTile extends ConsumerWidget {
  const _TodayTile({required this.item});

  final ChoreToday item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final names = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m.name};
    final repo = ref.read(choresRepoProvider);
    final canTick = ref.watch(canTickProvider)(item.chore);
    final c = item.chore;

    final String subtitle;
    if (item.isDone) {
      subtitle = l10n.choreDoneBy(item.done.map((x) => names[x.memberId] ?? l10n.someone).toSet().join(', '));
    } else if (item.overdueSince != null) {
      subtitle = l10n.choreOverdueSince(DateFormat.MMMd(locale).format(item.overdueSince!));
    } else {
      subtitle = repeatLabel(l10n, locale, c);
    }

    Future<void> toggle() async {
      if (!item.isDone) {
        await repo.markDone(c);
        return;
      }
      final mine = item.done.where(repo.canUndo).toList();
      if (mine.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.choreUndoOnlyDoer)));
        return;
      }
      for (final x in mine) {
        await repo.undo(x);
      }
    }

    return _ChoreTile(
      chore: c,
      subtitle: subtitle,
      overdue: item.overdueSince != null && !item.isDone,
      leading: IconButton(
        key: Key('tick-${c.id}'),
        tooltip: item.isDone ? l10n.choreUndo : l10n.choreMarkDone,
        onPressed: canTick ? toggle : null,
        icon: Icon(
          item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.isDone ? HomeColors.dahon : (canTick ? HomeColors.dagat : Colors.black26),
          size: 30,
        ),
      ),
      done: item.isDone,
    );
  }
}

class _ChoreTile extends ConsumerWidget {
  const _ChoreTile({
    required this.chore,
    required this.subtitle,
    this.leading,
    this.done = false,
    this.overdue = false,
  });

  final Chore chore;
  final String subtitle;
  final Widget? leading;
  final bool done;
  final bool overdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final members = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m};
    final manage = ref.watch(canManageChoresProvider);
    final who = members[chore.assignedTo];

    return ListTile(
      leading: leading ?? const Icon(Icons.event_repeat_outlined, color: HomeColors.dagat),
      title: Text(
        chore.name,
        style: done ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black54) : null,
      ),
      subtitle: Text(
        subtitle,
        style: overdue ? const TextStyle(color: HomeColors.gumamela, fontWeight: FontWeight.w600) : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            visualDensity: VisualDensity.compact,
            avatar: who == null ? null : CircleAvatar(backgroundColor: memberColor(who.color)),
            label: Text(who?.name ?? l10n.choreAnyone),
          ),
          const SizedBox(width: 4),
          SyncMarker(entity: 'chores', id: chore.id),
        ],
      ),
      onTap: manage
          ? () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => ChoreForm(chore: chore),
            )
          : null,
    );
  }
}

/// Add or edit a chore (adults).
class ChoreForm extends ConsumerStatefulWidget {
  const ChoreForm({super.key, this.chore});

  final Chore? chore;

  @override
  ConsumerState<ChoreForm> createState() => _ChoreFormState();
}

class _ChoreFormState extends ConsumerState<ChoreForm> {
  late final _name = TextEditingController(text: widget.chore?.name ?? '');
  late String? _assignedTo = widget.chore?.assignedTo;
  late String _repeat = widget.chore?.repeat ?? 'daily';
  late int _weekday = widget.chore?.weekday ?? ref.read(choresRepoProvider).today.weekday;
  late DateTime _due = parseIsoDate(widget.chore?.dueOn) ?? ref.read(choresRepoProvider).today;
  bool _tried = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(choresRepoProvider);
    final c = widget.chore;
    if (c == null) {
      await repo.addChore(name: _name.text, assignedTo: _assignedTo, repeat: _repeat, weekday: _weekday, dueOn: _due);
    } else {
      await repo.editChore(
        c,
        name: _name.text,
        assignedTo: _assignedTo,
        repeat: _repeat,
        weekday: _weekday,
        dueOn: _due,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(choresRepoProvider).today;
    final members = [
      for (final m in ref.watch(membersProvider).value ?? const <Member>[])
        if (m.role != 'viewer') m,
    ];

    return SheetBody(
      title: widget.chore == null ? l10n.choreAdd : l10n.choreEdit,
      children: [
        TextField(
          key: const Key('chore-name'),
          controller: _name,
          autofocus: widget.chore == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.choreNameHint,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.choreWho, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.choreAnyone),
              selected: _assignedTo == null,
              onSelected: (_) => setState(() => _assignedTo = null),
            ),
            for (final m in members)
              ChoiceChip(
                avatar: CircleAvatar(backgroundColor: memberColor(m.color)),
                label: Text(m.name),
                selected: _assignedTo == m.id,
                onSelected: (_) => setState(() => _assignedTo = m.id),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'daily', label: Text(l10n.choreDaily)),
            ButtonSegment(value: 'weekly', label: Text(l10n.choreWeekly)),
            ButtonSegment(value: 'once', label: Text(l10n.choreOnce)),
          ],
          selected: {_repeat},
          onSelectionChanged: (s) => setState(() => _repeat = s.first),
        ),
        const SizedBox(height: 12),
        if (_repeat == 'weekly')
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var d = 1; d <= 7; d++)
                ChoiceChip(
                  label: Text(DateFormat.E(locale).format(DateTime(2026, 11, 22 + d))),
                  selected: _weekday == d,
                  onSelected: (_) => setState(() => _weekday = d),
                ),
            ],
          ),
        if (_repeat == 'once')
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(DateFormat.yMMMEd(locale).format(_due)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _due,
                firstDate: DateTime(today.year - 1),
                lastDate: DateTime(today.year + 2),
              );
              if (picked != null) setState(() => _due = picked);
            },
          ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
        if (widget.chore != null)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              await ref.read(choresRepoProvider).removeChore(widget.chore!.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.choreRemove),
          ),
      ],
    );
  }
}
