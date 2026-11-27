import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/sheet_body.dart';
import '../members/members_screen.dart' show memberColor;
import '../sync/sync_widgets.dart';
import 'emergency_providers.dart';
import 'emergency_repository.dart';

const _manggaText = Color(0xFF8A5A00); // Mangga, darkened for text

void _openSheet(BuildContext context, Widget sheet) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => sheet);

String _dialable(String phone) => phone.replaceAll(RegExp(r'[^\d+]'), '');

Future<void> _call(String phone) => launchUrl(Uri(scheme: 'tel', path: _dialable(phone)));

/// The bag's title: "Household" or the member's name.
String bagTitle(AppLocalizations l10n, Map<String, Member> members, String? memberId) =>
    memberId == null ? l10n.emergencyHouseholdBag : (members[memberId]?.name ?? l10n.emergencyUnknownMember);

/// Emergency & Disaster Preparedness, laid out to act first (owner picked
/// layout A): check in, who is safe, numbers to call, where to meet, then
/// go-bags and hazard checklists.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final board = ref.watch(checkinBoardProvider);
    final bags = ref.watch(goBagsProvider);
    final done = ref.watch(hazardDoneProvider);
    final contacts = ref.watch(emergencyContactsProvider).value ?? const <EmergencyContact>[];
    final plan = ref.watch(emergencyPlanProvider).value;
    final adult = ref.watch(canEditEmergencyProvider);
    final me = ref.watch(emergencyMeProvider);
    final members = {for (final m in board.members) m.id: m};
    final title = Theme.of(context).textTheme.titleMedium;
    final repo = ref.read(emergencyRepoProvider);

    final help = board.needHelp;
    final memberBags = bags.where((b) => b.memberId != null && b.items.isNotEmpty).toList();
    final String figure;
    final String caption;
    if (help.isNotEmpty) {
      figure = help.length == 1
          ? l10n.emergencyNeedsHelpFigure(help.single.name)
          : l10n.emergencyManyNeedHelp(help.length);
      caption = l10n.emergencySafeCaption(board.safeCount, board.members.length);
    } else if (board.active) {
      figure = l10n.emergencySafeFigure(board.safeCount, board.members.length);
      caption = l10n.emergencyLast24h;
    } else {
      figure = l10n.emergencyReadyFigure;
      caption = memberBags.isEmpty
          ? l10n.emergencyReadyCaption
          : l10n.emergencyBagsPacked(memberBags.where((b) => b.ready).length, memberBags.length);
    }

    Future<void> safe() async {
      await repo.checkIn(safeStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emergencyCheckedInSafe)));
      }
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: figure,
            caption: caption,
            color: HomeColors.gumamela,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (me != null)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('checkin-safe'),
                          style: FilledButton.styleFrom(
                            backgroundColor: HomeColors.dahon,
                            minimumSize: const Size.fromHeight(56),
                          ),
                          onPressed: safe,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(l10n.emergencyImSafe),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('checkin-help'),
                          style: FilledButton.styleFrom(
                            backgroundColor: HomeColors.gumamela,
                            minimumSize: const Size.fromHeight(56),
                          ),
                          onPressed: () => _openSheet(context, const HelpForm()),
                          icon: const Icon(Icons.sos_outlined),
                          label: Text(l10n.emergencyNeedHelp),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(l10n.emergencyWho, style: title),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [for (final m in board.members) _CheckinTile(member: m, board: board)],
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.emergencyCall, style: title),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final (key, number) in nationalHotlines)
                        ListTile(
                          key: Key('hotline-$number'),
                          leading: const CircleAvatar(
                            backgroundColor: HomeColors.gumamela,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.local_phone_outlined),
                          ),
                          title: Text(l10n.emergencyHotline(key)),
                          subtitle: Text(number),
                          trailing: IconButton(
                            tooltip: l10n.emergencyCallNumber(number),
                            icon: const Icon(Icons.call),
                            onPressed: () => _call(number),
                          ),
                        ),
                      for (final c in contacts)
                        ListTile(
                          key: Key('contact-${c.name}'),
                          leading: const CircleAvatar(
                            backgroundColor: HomeColors.capiz,
                            foregroundColor: HomeColors.narra,
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(c.name),
                          subtitle: Text([l10n.emergencyContactKind(c.kind), c.phone, ?c.note].join(' · ')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SyncMarker(entity: 'emergency_contacts', id: c.id),
                              IconButton(
                                tooltip: l10n.emergencyCallNumber(c.phone),
                                icon: const Icon(Icons.call),
                                onPressed: () => _call(c.phone),
                              ),
                            ],
                          ),
                          onTap: adult ? () => _openSheet(context, ContactForm(contact: c)) : null,
                        ),
                    ],
                  ),
                ),
                if (adult)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('add-contact'),
                      onPressed: () => _openSheet(context, const ContactForm()),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.emergencyAddContact),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(l10n.emergencyWhereToMeet, style: title),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (plan == null ||
                          (plan.meetingPoint == null && plan.meetingPointFar == null && plan.evacuationCenter == null))
                        ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(l10n.emergencyNoPlan),
                          subtitle: Text(adult ? l10n.emergencyNoPlanAdult : l10n.emergencyNoPlanOthers),
                        )
                      else ...[
                        for (final (label, value) in [
                          (l10n.emergencyMeetingPoint, plan.meetingPoint),
                          (l10n.emergencyMeetingPointFar, plan.meetingPointFar),
                          (l10n.emergencyEvacuationCenter, plan.evacuationCenter),
                        ])
                          if (value != null)
                            ListTile(
                              leading: const Icon(Icons.place_outlined, color: HomeColors.gumamela),
                              title: Text(value),
                              subtitle: Text(label),
                            ),
                        if (plan.note != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Align(alignment: Alignment.centerLeft, child: Text(plan.note!)),
                          ),
                      ],
                      if (adult)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: TextButton.icon(
                              key: const Key('edit-plan'),
                              onPressed: () => _openSheet(context, PlanForm(plan: plan)),
                              icon: const Icon(Icons.edit_outlined),
                              label: Text(l10n.emergencyEditPlan),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.emergencyGoBags, style: title),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final b in bags)
                        ListTile(
                          key: Key('bag-${b.memberId ?? 'household'}'),
                          leading: CircleAvatar(
                            backgroundColor: b.memberId == null
                                ? HomeColors.narra
                                : memberColor(members[b.memberId]?.color),
                            foregroundColor: Colors.white,
                            child: Icon(b.ready ? Icons.check : Icons.backpack_outlined),
                          ),
                          title: Text(bagTitle(l10n, members, b.memberId)),
                          subtitle: Text(
                            [
                              b.items.isEmpty
                                  ? l10n.emergencyBagEmpty
                                  : l10n.emergencyBagPacked(b.packed, b.items.length),
                              if (b.expiring(repo.now).isNotEmpty)
                                l10n.emergencyBagExpiring(b.expiring(repo.now).length),
                            ].join(' · '),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openSheet(context, GoBagSheet(memberId: b.memberId)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.emergencyChecklists, style: title),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final h in hazardChecklists.keys)
                        ListTile(
                          key: Key('hazard-$h'),
                          leading: CircleAvatar(
                            backgroundColor: HomeColors.dagat,
                            foregroundColor: Colors.white,
                            child: Icon(switch (h) {
                              'typhoon' => Icons.storm_outlined,
                              'flood' => Icons.water_outlined,
                              _ => Icons.landslide_outlined,
                            }),
                          ),
                          title: Text(l10n.emergencyHazard(h)),
                          subtitle: Text(l10n.emergencyChecksDone(done[h]!.length, hazardChecklists[h]!.length)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openSheet(context, HazardSheet(hazard: h)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.emergencyWorksOffline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckinTile extends StatelessWidget {
  const _CheckinTile({required this.member, required this.board});

  final Member member;
  final CheckinBoard board;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final current = board.current(member.id);
    final last = board.latest[member.id];
    final help = current?.status == helpStatus;
    final String line;
    if (current != null) {
      final at = current.checkedAt.toLocal();
      final when = daysUntil(at, board.now) == 0
          ? DateFormat.jm(locale).format(at)
          : DateFormat.MMMd(locale).add_jm().format(at);
      line = [help ? l10n.emergencyStatusHelp : l10n.emergencyStatusSafe, when, ?current.note].join(' · ');
    } else if (last != null) {
      line = l10n.emergencyLastCheckin(DateFormat.MMMd(locale).format(last.checkedAt.toLocal()));
    } else {
      line = l10n.emergencyNoCheckin;
    }
    return ListTile(
      key: Key('checkin-${member.name}'),
      leading: CircleAvatar(
        backgroundColor: memberColor(member.color),
        foregroundColor: Colors.white,
        child: Text(member.name.isEmpty ? '?' : member.name[0].toUpperCase()),
      ),
      title: Text(member.name),
      subtitle: Text(
        line,
        style: current == null
            ? null
            : TextStyle(color: help ? HomeColors.gumamela : HomeColors.dahon, fontWeight: FontWeight.w600),
      ),
      trailing: current == null
          ? null
          : Icon(help ? Icons.sos_outlined : Icons.check_circle, color: help ? HomeColors.gumamela : HomeColors.dahon),
    );
  }
}

/// "Need help", with an optional note on where and what.
class HelpForm extends ConsumerStatefulWidget {
  const HelpForm({super.key});

  @override
  ConsumerState<HelpForm> createState() => _HelpFormState();
}

class _HelpFormState extends ConsumerState<HelpForm> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: l10n.emergencyNeedHelp,
      children: [
        TextField(
          key: const Key('help-note'),
          controller: _note,
          autofocus: true,
          maxLines: 2,
          decoration: InputDecoration(labelText: l10n.emergencyHelpNote, hintText: l10n.emergencyHelpNoteHint),
        ),
        const SizedBox(height: 8),
        Text(l10n.emergencyHelpSyncs, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('help-send'),
          style: FilledButton.styleFrom(backgroundColor: HomeColors.gumamela),
          onPressed: () async {
            await ref.read(emergencyRepoProvider).checkIn(helpStatus, note: _note.text);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.emergencySendHelp),
        ),
      ],
    );
  }
}

/// Add or edit a contact.
class ContactForm extends ConsumerStatefulWidget {
  const ContactForm({super.key, this.contact});

  final EmergencyContact? contact;

  @override
  ConsumerState<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<ContactForm> {
  late final _name = TextEditingController(text: widget.contact?.name ?? '');
  late final _phone = TextEditingController(text: widget.contact?.phone ?? '');
  late final _note = TextEditingController(text: widget.contact?.note ?? '');
  late String _kind = widget.contact?.kind ?? emergencyContactKinds.first;
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _phoneBad => _dialable(_phone.text).length < 3;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phoneBad) {
      setState(() => _tried = true);
      return;
    }
    final repo = ref.read(emergencyRepoProvider);
    final c = widget.contact;
    if (c == null) {
      await repo.addContact(name: _name.text, kind: _kind, phone: _phone.text, note: _note.text);
    } else {
      await repo.editContact(c, name: _name.text, kind: _kind, phone: _phone.text, note: _note.text);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.contact;
    return SheetBody(
      title: c == null ? l10n.emergencyAddContact : l10n.emergencyEditContact,
      children: [
        TextField(
          key: const Key('contact-name'),
          controller: _name,
          autofocus: c == null,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.emergencyContactName,
            errorText: _tried && _name.text.trim().isEmpty ? l10n.itemNameRequired : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('contact-phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.emergencyContactPhone,
            errorText: _tried && _phoneBad ? l10n.emergencyPhoneInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final k in emergencyContactKinds)
              ChoiceChip(
                key: Key('kind-$k'),
                label: Text(l10n.emergencyContactKind(k)),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          decoration: InputDecoration(labelText: l10n.emergencyNote),
        ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('contact-save'), onPressed: _save, child: Text(l10n.save)),
        if (c != null)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
            onPressed: () async {
              await ref.read(emergencyRepoProvider).removeContact(c.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.emergencyRemoveContact),
          ),
      ],
    );
  }
}

/// Where to meet and where to evacuate.
class PlanForm extends ConsumerStatefulWidget {
  const PlanForm({super.key, this.plan});

  final EmergencyPlan? plan;

  @override
  ConsumerState<PlanForm> createState() => _PlanFormState();
}

class _PlanFormState extends ConsumerState<PlanForm> {
  late final _near = TextEditingController(text: widget.plan?.meetingPoint ?? '');
  late final _far = TextEditingController(text: widget.plan?.meetingPointFar ?? '');
  late final _center = TextEditingController(text: widget.plan?.evacuationCenter ?? '');
  late final _note = TextEditingController(text: widget.plan?.note ?? '');

  @override
  void dispose() {
    for (final c in [_near, _far, _center, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: l10n.emergencyWhereToMeet,
      children: [
        TextField(
          key: const Key('plan-near'),
          controller: _near,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.emergencyMeetingPoint, hintText: l10n.emergencyMeetingPointHint),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('plan-far'),
          controller: _far,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.emergencyMeetingPointFar,
            hintText: l10n.emergencyMeetingPointFarHint,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('plan-center'),
          controller: _center,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.emergencyEvacuationCenter,
            hintText: l10n.emergencyEvacuationCenterHint,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          maxLines: 2,
          decoration: InputDecoration(labelText: l10n.emergencyNote),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('plan-save'),
          onPressed: () async {
            await ref
                .read(emergencyRepoProvider)
                .savePlan(
                  meetingPoint: _near.text,
                  meetingPointFar: _far.text,
                  evacuationCenter: _center.text,
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

/// One go-bag's checklist.
class GoBagSheet extends ConsumerStatefulWidget {
  const GoBagSheet({super.key, required this.memberId});

  final String? memberId;

  @override
  ConsumerState<GoBagSheet> createState() => _GoBagSheetState();
}

class _GoBagSheetState extends ConsumerState<GoBagSheet> {
  final _add = TextEditingController();

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(emergencyRepoProvider);
    final members = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m};
    final bag =
        ref.watch(goBagsProvider).where((b) => b.memberId == widget.memberId).firstOrNull ??
        GoBag(widget.memberId, const []);
    final canTick = canTickBag(ref.watch(emergencyMeProvider), widget.memberId);

    Future<void> add() async {
      final name = _add.text.trim();
      if (name.isEmpty) return;
      await repo.addBagItem(widget.memberId, name);
      _add.clear();
    }

    return SheetBody(
      title: widget.memberId == null
          ? l10n.emergencyHouseholdBagTitle
          : l10n.emergencyBagTitle(bagTitle(l10n, members, widget.memberId)),
      children: [
        if (bag.items.isNotEmpty)
          Text(l10n.emergencyBagPacked(bag.packed, bag.items.length), key: const Key('bag-count')),
        for (final i in bag.items)
          CheckboxListTile(
            key: Key('bag-item-${i.name}'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: i.packed,
            onChanged: canTick ? (v) => repo.setPacked(i, v ?? false) : null,
            title: Text(i.name),
            subtitle: switch (parseIsoDate(i.expiresOn)) {
              null => null,
              final d => Text(
                daysUntil(d, repo.now) < 0
                    ? l10n.emergencyExpired(DateFormat.yMMMd(locale).format(d))
                    : l10n.emergencyExpires(DateFormat.yMMMd(locale).format(d)),
                style: TextStyle(
                  color: daysUntil(d, repo.now) < 0
                      ? HomeColors.gumamela
                      : daysUntil(d, repo.now) <= goBagExpirySoonDays
                      ? _manggaText
                      : null,
                ),
              ),
            },
            secondary: canTick
                ? IconButton(
                    tooltip: l10n.emergencyEditItem,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _openSheet(context, BagItemForm(item: i)),
                  )
                : null,
          ),
        if (canTick) ...[
          const SizedBox(height: 8),
          TextField(
            key: const Key('bag-add'),
            controller: _add,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => add(),
            decoration: InputDecoration(
              labelText: l10n.emergencyAddToBag,
              suffixIcon: IconButton(tooltip: l10n.emergencyAddToBag, icon: const Icon(Icons.add), onPressed: add),
            ),
          ),
          if (bag.items.isEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('bag-starter'),
              onPressed: () =>
                  repo.addStarter(widget.memberId, [for (final k in goBagStarterKeys) l10n.emergencyStarterItem(k)]),
              icon: const Icon(Icons.playlist_add),
              label: Text(l10n.emergencyAddStarter),
            ),
          ],
        ] else if (bag.items.isEmpty)
          Text(l10n.emergencyBagEmpty),
      ],
    );
  }
}

/// Rename a go-bag item, set when it expires, or remove it.
class BagItemForm extends ConsumerStatefulWidget {
  const BagItemForm({super.key, required this.item});

  final GoBagItem item;

  @override
  ConsumerState<BagItemForm> createState() => _BagItemFormState();
}

class _BagItemFormState extends ConsumerState<BagItemForm> {
  late final _name = TextEditingController(text: widget.item.name);
  late DateTime? _expires = parseIsoDate(widget.item.expiresOn);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(emergencyRepoProvider);
    final today = repo.now;
    return SheetBody(
      title: l10n.emergencyEditItem,
      children: [
        TextField(
          key: const Key('bag-item-name'),
          controller: _name,
          decoration: InputDecoration(labelText: l10n.emergencyItemName),
        ),
        ListTile(
          key: const Key('bag-item-expires'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.emergencyExpiresField),
          subtitle: Text(_expires == null ? l10n.emergencyNoExpiry : DateFormat.yMMMd(locale).format(_expires!)),
          trailing: _expires == null
              ? null
              : IconButton(
                  tooltip: l10n.emergencyNoExpiry,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _expires = null),
                ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _expires ?? today,
              firstDate: DateTime(today.year - 5),
              lastDate: DateTime(today.year + 10, 12, 31),
            );
            if (picked != null) setState(() => _expires = picked);
          },
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('bag-item-save'),
          onPressed: () async {
            if (_name.text.trim().isEmpty) return;
            await repo.editBagItem(widget.item, name: _name.text, expiresOn: _expires);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: HomeColors.gumamela),
          onPressed: () async {
            await repo.removeBagItem(widget.item.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.emergencyRemoveItem),
        ),
      ],
    );
  }
}

/// A built-in hazard checklist. Adults tick; everyone reads.
class HazardSheet extends ConsumerWidget {
  const HazardSheet({super.key, required this.hazard});

  final String hazard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(emergencyRepoProvider);
    final adult = ref.watch(canEditEmergencyProvider);
    final done = ref.watch(hazardDoneProvider)[hazard]!;
    final items = hazardChecklists[hazard]!;
    return SheetBody(
      title: l10n.emergencyHazardTitle(hazard),
      children: [
        Text(l10n.emergencyChecksDone(done.length, items.length)),
        for (final item in items)
          CheckboxListTile(
            key: Key('check-$item'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: done.contains(item),
            onChanged: adult ? (v) => repo.setCheck(hazard, item, v ?? false) : null,
            title: Text(l10n.emergencyCheckItem('${hazard}_$item')),
          ),
        if (adult && done.isNotEmpty)
          TextButton(
            key: const Key('checks-clear'),
            onPressed: () => repo.clearChecks(hazard),
            child: Text(l10n.emergencyClearChecks),
          ),
      ],
    );
  }
}
