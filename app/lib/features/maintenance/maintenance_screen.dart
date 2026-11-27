import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/money.dart';
import '../../shared/sheet_body.dart';
import '../inventory/inventory_providers.dart' show inventoryItemsProvider;
import '../sync/sync_widgets.dart';
import 'maintenance_providers.dart';
import 'maintenance_repository.dart';

void _openSheet(BuildContext context, Widget sheet) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

Future<void> _call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), '')));

/// How often a task may repeat, in months (null = once).
const _everyChoices = <int?>[null, 1, 2, 3, 4, 6, 12, 24, 36];

IconData areaIcon(String area) => switch (area) {
  'aircon' => Icons.ac_unit,
  'water' => Icons.water_drop_outlined,
  'roof' => Icons.roofing,
  'electrical' => Icons.electrical_services,
  'plumbing' => Icons.plumbing,
  'septic' => Icons.water_damage_outlined,
  'pest' => Icons.pest_control_outlined,
  'appliance' => Icons.kitchen_outlined,
  'garden' => Icons.yard_outlined,
  _ => Icons.home_repair_service_outlined,
};

/// "today", "tomorrow", "in 5 days" or "on Feb 10".
String upkeepWhen(AppLocalizations l10n, String locale, DateTime due, DateTime today) {
  final days = daysUntil(due, today);
  if (days == 0) return l10n.maintWhenToday;
  if (days == 1) return l10n.maintWhenTomorrow;
  if (days > 1 && days <= upkeepSoonDays) return l10n.maintWhenInDays(days);
  return l10n.maintWhenOn(DateFormat.MMMd(locale).format(due));
}

String _date(String locale, String iso) => DateFormat.yMMMd(locale).format(parseIsoDate(iso)!);

/// Home Maintenance, due first (owner picked layout A): upkeep with overdue
/// on top, the history of upkeep and repairs, and contractors.
class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 3, vsync: this)..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final s = ref.watch(maintenanceSummaryProvider);
    final adult = ref.watch(canEditMaintenanceProvider);
    final overdue = s.overdue.length;
    final next = s.next;

    final figure = s.isEmpty
        ? l10n.maintNoneFigure
        : overdue > 0
        ? l10n.maintOverdueFigure(overdue)
        : next != null
        ? l10n.maintNextFigure(next.name, upkeepWhen(l10n, locale, parseIsoDate(next.nextDueOn)!, s.today))
        : l10n.maintNothingDueFigure;
    final caption = s.isEmpty
        ? l10n.maintEmptyCaption
        : [
            l10n.maintTaskCount(s.tasks.length),
            if (adult && s.spentThisYear > 0)
              l10n.maintSpentThisYear(formatPeso(s.spentThisYear, locale: locale, whole: true)),
          ].join(' · ');
    final color = overdue > 0 ? HomeColors.gumamela : HomeColors.narra;

    final (fabKey, fabLabel, fabSheet) = switch (_tabs.index) {
      0 => ('add-task', l10n.maintAddTask, const TaskForm() as Widget),
      1 => ('log-repair', l10n.maintLogRepair, const RepairForm() as Widget),
      _ => ('add-contractor', l10n.maintAddContractor, const ContractorForm() as Widget),
    };

    return Scaffold(
      floatingActionButton: adult
          ? FloatingActionButton.extended(
              key: Key(fabKey),
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => _openSheet(context, fabSheet),
              icon: const Icon(Icons.add),
              label: Text(fabLabel),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: color,
            leading: const BackButton(color: Colors.white),
          ),
          Material(
            color: color,
            child: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: HomeColors.mangga,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.maintUpkeepTab),
                Tab(text: l10n.maintHistoryTab),
                Tab(text: l10n.maintContractorsTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(controller: _tabs, children: const [UpkeepTab(), HistoryTab(), ContractorsTab()]),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- upkeep

class UpkeepTab extends ConsumerWidget {
  const UpkeepTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(maintenanceSummaryProvider);
    final adult = ref.watch(canEditMaintenanceProvider);
    final title = Theme.of(context).textTheme.titleMedium;

    if (s.tasks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(adult ? l10n.maintUpkeepEmpty : l10n.maintUpkeepEmptyViewer, textAlign: TextAlign.center),
          ),
        ],
      );
    }

    Widget section(String heading, List<MaintenanceTask> tasks) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(heading, style: title),
        const SizedBox(height: 8),
        Card(
          child: Column(children: [for (final t in tasks) _TaskTile(task: t)]),
        ),
        const SizedBox(height: 16),
      ],
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (s.overdue.isNotEmpty) section(l10n.maintOverdue, s.overdue),
        if (s.upcoming.isNotEmpty) section(l10n.maintComingUp, s.upcoming),
        if (s.undated.isNotEmpty) section(l10n.maintNoDate, s.undated),
        if (s.done.isNotEmpty) section(l10n.maintDoneOnce, s.done),
      ],
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final MaintenanceTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final adult = ref.watch(canEditMaintenanceProvider);
    final today = ref.read(maintenanceRepoProvider).today;
    final contractor = ref.watch(contractorsByIdProvider)[task.contractorId];
    final due = dueOf(task, today);
    final when = task.nextDueOn == null
        ? (task.lastDoneOn == null ? null : l10n.maintDoneOn(_date(locale, task.lastDoneOn!)))
        : due == Due.overdue
        ? l10n.maintWasDue(_date(locale, task.nextDueOn!))
        : l10n.maintDueOn(upkeepWhen(l10n, locale, parseIsoDate(task.nextDueOn)!, today));
    final details = [
      task.everyMonths == null ? l10n.maintOnce : l10n.maintEvery(task.everyMonths!),
      ?contractor?.name,
    ].join(' · ');
    final (bg, fg) = switch (due) {
      Due.overdue => (HomeColors.gumamela, Colors.white),
      Due.soon => (HomeColors.mangga, HomeColors.narra),
      _ => (HomeColors.narra, Colors.white),
    };

    return ListTile(
      key: Key('task-${task.name}'),
      leading: CircleAvatar(backgroundColor: bg, foregroundColor: fg, child: Icon(areaIcon(task.area))),
      title: Row(
        children: [
          Flexible(child: Text(task.name, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 6),
          SyncMarker(entity: 'maintenance_tasks', id: task.id),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (when != null)
            Text(
              when,
              style: due == Due.overdue
                  ? const TextStyle(color: HomeColors.gumamela, fontWeight: FontWeight.w600)
                  : null,
            ),
          Text(details),
        ],
      ),
      isThreeLine: when != null,
      trailing: adult && task.nextDueOn != null || adult && task.lastDoneOn == null
          ? IconButton(
              key: Key('done-${task.name}'),
              tooltip: l10n.maintMarkDone,
              icon: const Icon(Icons.check_circle_outline, color: HomeColors.dahon),
              onPressed: () => _openSheet(context, DoneSheet(task: task)),
            )
          : null,
      onTap: adult ? () => _openSheet(context, TaskForm(task: task)) : null,
    );
  }
}

/// A date row that opens a picker.
class _DateRow extends StatelessWidget {
  const _DateRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.first,
    required this.last,
    this.clearable = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime first;
  final DateTime last;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: Text(value == null ? l10n.maintNotSet : DateFormat.yMMMEd(locale).format(value!)),
      trailing: clearable && value != null
          ? IconButton(tooltip: l10n.maintClearDate, icon: const Icon(Icons.close), onPressed: () => onChanged(null))
          : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: first,
          lastDate: last,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Area chips.
class _AreaPicker extends StatelessWidget {
  const _AreaPicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final a in maintenanceAreas)
          ChoiceChip(
            key: Key('area-$a'),
            avatar: Icon(areaIcon(a), size: 18),
            label: Text(l10n.maintArea(a)),
            selected: value == a,
            onSelected: (_) => onChanged(a),
          ),
      ],
    );
  }
}

/// Optional contractor and Inventory item pickers.
class _LinkPickers extends ConsumerWidget {
  const _LinkPickers({required this.contractorId, required this.onContractor, this.itemId, this.onItem});

  final String? contractorId;
  final ValueChanged<String?> onContractor;
  final String? itemId;
  final ValueChanged<String?>? onItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final contractors = ref.watch(contractorsProvider).value ?? const <Contractor>[];
    final items = ref.watch(inventoryItemsProvider).value ?? const <InventoryItem>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contractors.isNotEmpty) ...[
          DropdownButtonFormField<String?>(
            key: const Key('pick-contractor'),
            initialValue: contractors.any((c) => c.id == contractorId) ? contractorId : null,
            decoration: InputDecoration(labelText: l10n.maintContractor),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.maintNoContractor)),
              for (final c in contractors)
                DropdownMenuItem(value: c.id, child: Text('${c.name} · ${l10n.maintTrade(c.trade)}')),
            ],
            onChanged: onContractor,
          ),
          const SizedBox(height: 12),
        ],
        if (onItem != null && items.isNotEmpty) ...[
          DropdownButtonFormField<String?>(
            key: const Key('pick-item'),
            initialValue: items.any((i) => i.id == itemId) ? itemId : null,
            decoration: InputDecoration(labelText: l10n.maintItem),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.maintNoItem)),
              for (final i in items) DropdownMenuItem(value: i.id, child: Text([i.name, ?i.room].join(' · '))),
            ],
            onChanged: onItem,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

Future<bool> _confirm(BuildContext context, String message, String action) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
        TextButton(key: const Key('confirm'), onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
      ],
    ),
  );
  return ok == true;
}

/// Adds or edits an upkeep task.
class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({super.key, this.task});

  final MaintenanceTask? task;

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  late final _name = TextEditingController(text: widget.task?.name);
  late final _note = TextEditingController(text: widget.task?.note);
  late String _area = widget.task?.area ?? 'aircon';
  late int? _every = widget.task == null ? 3 : widget.task!.everyMonths;
  late DateTime? _next = parseIsoDate(widget.task?.nextDueOn);
  late String? _contractor = widget.task?.contractorId;
  late String? _item = widget.task?.inventoryItemId;
  bool _nameMissing = false;
  bool _canUndo = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null && t.lastDoneOn != null) {
      ref.read(maintenanceRepoProvider).canUndo(t).then((v) {
        if (mounted) setState(() => _canUndo = v);
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameMissing = true);
      return;
    }
    final repo = ref.read(maintenanceRepoProvider);
    final t = widget.task;
    if (t == null) {
      await repo.addTask(
        name: _name.text,
        area: _area,
        everyMonths: _every,
        nextDueOn: _next,
        inventoryItemId: _item,
        contractorId: _contractor,
        note: _note.text,
      );
    } else {
      await repo.editTask(
        t,
        name: _name.text,
        area: _area,
        everyMonths: _every,
        nextDueOn: _next,
        inventoryItemId: _item,
        contractorId: _contractor,
        note: _note.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(maintenanceRepoProvider).today;
    final t = widget.task;
    return SheetBody(
      title: t == null ? l10n.maintAddTask : l10n.maintEditTask,
      children: [
        if (t == null) ...[
          Text(l10n.maintSuggestions, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final (key, area, every) in upkeepStarters)
                ActionChip(
                  key: Key('starter-$key'),
                  avatar: Icon(areaIcon(area), size: 18),
                  label: Text(l10n.maintStarter(key)),
                  onPressed: () => setState(() {
                    _name.text = l10n.maintStarter(key);
                    _area = area;
                    _every = every;
                    _next ??= today;
                    _nameMissing = false;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          key: const Key('task-name'),
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.maintTaskName,
            errorText: _nameMissing ? l10n.maintNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.maintAreaLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        _AreaPicker(value: _area, onChanged: (a) => setState(() => _area = a)),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          key: const Key('task-every'),
          initialValue: _every,
          decoration: InputDecoration(labelText: l10n.maintHowOften),
          items: [
            for (final e in {..._everyChoices, _every})
              DropdownMenuItem(value: e, child: Text(e == null ? l10n.maintOnce : l10n.maintEvery(e))),
          ],
          onChanged: (v) => setState(() => _every = v),
        ),
        _DateRow(
          key: const Key('task-next'),
          label: l10n.maintNextDue,
          value: _next,
          clearable: true,
          first: DateTime(today.year - 5),
          last: DateTime(today.year + 10),
          onChanged: (d) => setState(() => _next = d),
        ),
        const SizedBox(height: 8),
        _LinkPickers(
          contractorId: _contractor,
          onContractor: (v) => setState(() => _contractor = v),
          itemId: _item,
          onItem: (v) => setState(() => _item = v),
        ),
        TextField(
          key: const Key('task-note'),
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.maintNote),
        ),
        const SizedBox(height: 16),
        FilledButton(key: const Key('task-save'), onPressed: _save, child: Text(l10n.save)),
        if (t != null) ...[
          if (_canUndo)
            TextButton.icon(
              key: const Key('task-undo'),
              onPressed: () async {
                await ref.read(maintenanceRepoProvider).undoDone(t);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.undo),
              label: Text(l10n.maintUndoDone),
            ),
          TextButton.icon(
            key: const Key('task-delete'),
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              if (!await _confirm(context, l10n.maintDeleteTaskConfirm(t.name), l10n.maintDelete)) return;
              await ref.read(maintenanceRepoProvider).removeTask(t.id);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.maintDeleteTask),
          ),
        ],
      ],
    );
  }
}

/// Peso amount field.
class _CostField extends StatelessWidget {
  const _CostField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      key: const Key('cost'),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: l10n.maintCost, prefixText: '₱ ', helperText: l10n.maintCostHint),
    );
  }
}

/// Marks an upkeep task done: when, the cost, who did it.
class DoneSheet extends ConsumerStatefulWidget {
  const DoneSheet({super.key, required this.task});

  final MaintenanceTask task;

  @override
  ConsumerState<DoneSheet> createState() => _DoneSheetState();
}

class _DoneSheetState extends ConsumerState<DoneSheet> {
  final _cost = TextEditingController();
  final _note = TextEditingController();
  late DateTime _on = ref.read(maintenanceRepoProvider).today;
  late String? _contractor = widget.task.contractorId;

  @override
  void dispose() {
    _cost.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(maintenanceRepoProvider).today;
    final next = nextDueAfter(widget.task, _on);
    return SheetBody(
      title: l10n.maintDoneTitle(widget.task.name),
      children: [
        _DateRow(
          key: const Key('done-date'),
          label: l10n.maintDoneDate,
          value: _on,
          first: DateTime(today.year - 2),
          last: today,
          onChanged: (d) => setState(() => _on = d ?? _on),
        ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.maintNextAfter(_date(locale, next)), key: const Key('done-next')),
          ),
        _CostField(controller: _cost),
        const SizedBox(height: 12),
        _LinkPickers(contractorId: _contractor, onContractor: (v) => setState(() => _contractor = v)),
        TextField(
          key: const Key('done-note'),
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.maintNote),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('done-save'),
          onPressed: () async {
            await ref
                .read(maintenanceRepoProvider)
                .markDone(
                  widget.task,
                  doneOn: _on,
                  costMinor: parsePeso(_cost.text),
                  contractorId: _contractor,
                  note: _note.text,
                );
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.maintMarkDone),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ history

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logs = ref.watch(maintenanceLogsProvider).value ?? const <MaintenanceLog>[];
    if (logs.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.maintHistoryEmpty, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Card(
          child: Column(children: [for (final l in logs) LogTile(log: l)]),
        ),
      ],
    );
  }
}

/// One upkeep or repair entry (also used on an Inventory item's sheet).
class LogTile extends ConsumerWidget {
  const LogTile({super.key, required this.log});

  final MaintenanceLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final adult = ref.watch(canEditMaintenanceProvider);
    final contractor = ref.watch(contractorsByIdProvider)[log.contractorId];
    return ListTile(
      key: Key('log-${log.title}'),
      leading: CircleAvatar(
        backgroundColor: log.kind == repairKind ? HomeColors.mangga : HomeColors.dahon,
        foregroundColor: log.kind == repairKind ? HomeColors.narra : Colors.white,
        child: Icon(log.kind == repairKind ? Icons.build_outlined : areaIcon(log.area)),
      ),
      title: Row(
        children: [
          Flexible(child: Text(log.title, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 6),
          SyncMarker(entity: 'maintenance_logs', id: log.id),
        ],
      ),
      subtitle: Text(
        [
          DateFormat.yMMMd(locale).format(parseIsoDate(log.doneOn)!),
          l10n.maintKind(log.kind),
          ?contractor?.name,
          ?log.note,
        ].join(' · '),
      ),
      trailing: adult && log.costMinor != null
          ? Text(formatPeso(log.costMinor!, locale: locale, whole: true), key: Key('cost-${log.title}'))
          : null,
      onTap: !adult
          ? null
          : () async {
              if (!await _confirm(context, l10n.maintDeleteEntryConfirm(log.title), l10n.maintDelete)) return;
              await ref.read(maintenanceRepoProvider).removeLog(log);
            },
      onLongPress: null,
    );
  }
}

/// Logs a repair.
class RepairForm extends ConsumerStatefulWidget {
  const RepairForm({super.key, this.inventoryItemId});

  final String? inventoryItemId;

  @override
  ConsumerState<RepairForm> createState() => _RepairFormState();
}

class _RepairFormState extends ConsumerState<RepairForm> {
  final _title = TextEditingController();
  final _cost = TextEditingController();
  final _note = TextEditingController();
  String _area = 'other';
  late DateTime _on = ref.read(maintenanceRepoProvider).today;
  String? _contractor;
  late String? _item = widget.inventoryItemId;
  bool _titleMissing = false;

  @override
  void dispose() {
    _title.dispose();
    _cost.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(maintenanceRepoProvider).today;
    return SheetBody(
      title: l10n.maintLogRepair,
      children: [
        TextField(
          key: const Key('repair-title'),
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.maintRepairTitle,
            errorText: _titleMissing ? l10n.maintNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.maintAreaLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        _AreaPicker(value: _area, onChanged: (a) => setState(() => _area = a)),
        _DateRow(
          key: const Key('repair-date'),
          label: l10n.maintDoneDate,
          value: _on,
          first: DateTime(today.year - 5),
          last: today,
          onChanged: (d) => setState(() => _on = d ?? _on),
        ),
        _CostField(controller: _cost),
        const SizedBox(height: 12),
        _LinkPickers(
          contractorId: _contractor,
          onContractor: (v) => setState(() => _contractor = v),
          itemId: _item,
          onItem: (v) => setState(() => _item = v),
        ),
        TextField(
          key: const Key('repair-note'),
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.maintNote),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('repair-save'),
          onPressed: () async {
            if (_title.text.trim().isEmpty) {
              setState(() => _titleMissing = true);
              return;
            }
            await ref
                .read(maintenanceRepoProvider)
                .addRepair(
                  title: _title.text,
                  area: _area,
                  doneOn: _on,
                  costMinor: parsePeso(_cost.text),
                  contractorId: _contractor,
                  inventoryItemId: _item,
                  note: _note.text,
                );
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- contractors

class ContractorsTab extends ConsumerWidget {
  const ContractorsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final adult = ref.watch(canEditMaintenanceProvider);
    final list = ref.watch(contractorsProvider).value ?? const <Contractor>[];
    if (list.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.maintContractorsEmpty, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Card(
          child: Column(
            children: [
              for (final c in list)
                ListTile(
                  key: Key('contractor-${c.name}'),
                  leading: const CircleAvatar(
                    backgroundColor: HomeColors.dagat,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.engineering_outlined),
                  ),
                  title: Text(c.name),
                  subtitle: Text([l10n.maintTrade(c.trade), ?c.phone, ?c.note].join(' · ')),
                  trailing: c.phone == null
                      ? null
                      : IconButton(
                          key: Key('call-${c.name}'),
                          tooltip: l10n.maintCall(c.name),
                          icon: const Icon(Icons.call_outlined, color: HomeColors.dahon),
                          onPressed: () => _call(c.phone!),
                        ),
                  onTap: adult ? () => _openSheet(context, ContractorForm(contractor: c)) : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContractorForm extends ConsumerStatefulWidget {
  const ContractorForm({super.key, this.contractor});

  final Contractor? contractor;

  @override
  ConsumerState<ContractorForm> createState() => _ContractorFormState();
}

class _ContractorFormState extends ConsumerState<ContractorForm> {
  late final _name = TextEditingController(text: widget.contractor?.name);
  late final _phone = TextEditingController(text: widget.contractor?.phone);
  late final _note = TextEditingController(text: widget.contractor?.note);
  late String _trade = widget.contractor?.trade ?? 'electrician';
  bool _nameMissing = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.contractor;
    return SheetBody(
      title: c == null ? l10n.maintAddContractor : l10n.maintEditContractor,
      children: [
        TextField(
          key: const Key('contractor-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.maintContractorName,
            errorText: _nameMissing ? l10n.maintNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.maintTradeLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final t in contractorTrades)
              ChoiceChip(
                key: Key('trade-$t'),
                label: Text(l10n.maintTrade(t)),
                selected: _trade == t,
                onSelected: (_) => setState(() => _trade = t),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('contractor-phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: l10n.maintPhone),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('contractor-note'),
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.maintNote),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('contractor-save'),
          onPressed: () async {
            if (_name.text.trim().isEmpty) {
              setState(() => _nameMissing = true);
              return;
            }
            final repo = ref.read(maintenanceRepoProvider);
            if (c == null) {
              await repo.addContractor(name: _name.text, trade: _trade, phone: _phone.text, note: _note.text);
            } else {
              await repo.editContractor(c, name: _name.text, trade: _trade, phone: _phone.text, note: _note.text);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
        if (c != null)
          TextButton.icon(
            key: const Key('contractor-delete'),
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              await ref.read(maintenanceRepoProvider).removeContractor(c.id);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.maintDeleteContractor),
          ),
      ],
    );
  }
}
