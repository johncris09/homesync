import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/auth/pin_hash.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/pin_pad.dart';
import '../sync/sync_widgets.dart';

/// Roles the owner can give. There is one owner (set up on the hub), so the
/// owner role is not offered here.
const assignableRoles = ['adult', 'teen', 'child', 'helper', 'viewer'];

/// Member colours, stored as `#RRGGBB` (the column holds up to 16 chars).
const memberPalette = ['#2F6B3A', '#F2B630', '#2B5C8A', '#5B3F7A', '#C2332B', '#2A1E17'];

Color memberColor(String? hex) {
  final v = hex == null ? null : int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return v == null ? HomeColors.narra : Color(0xFF000000 | v);
}

String roleLabel(AppLocalizations l10n, String role) => switch (role) {
  'owner' => l10n.roleOwner,
  'adult' => l10n.roleAdult,
  'teen' => l10n.roleTeen,
  'child' => l10n.roleChild,
  'helper' => l10n.roleHelper,
  'viewer' => l10n.roleViewer,
  _ => role,
};

/// Owner only: add household members, edit them, set their tablet PIN and
/// remove them. Members sync to every device; only the owner may write them.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authProvider).session;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final isOwner = session?.active.role == 'owner';

    return Scaffold(
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              backgroundColor: HomeColors.mangga,
              foregroundColor: HomeColors.narra,
              onPressed: () => _edit(context, ref, null),
              icon: const Icon(Icons.person_add_alt),
              label: Text(l10n.memberAdd),
            )
          : null,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: l10n.membersCount(members.length),
            caption: l10n.membersCaption,
            color: HomeColors.dagat,
            leading: const BackButton(color: Colors.white),
          ),
          if (!isOwner)
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.membersOwnerOnly))
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Card(
                child: Column(
                  children: [
                    for (final m in members)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: memberColor(m.color),
                          foregroundColor: Colors.white,
                          child: Text(m.name.isEmpty ? '?' : m.name.characters.first.toUpperCase()),
                        ),
                        title: Text(m.name),
                        subtitle: Text(
                          '${roleLabel(l10n, m.role)} · ${m.pinHash == null ? l10n.memberNoPin : l10n.memberHasPin}',
                        ),
                        trailing: SyncMarker(entity: 'members', id: m.id),
                        onTap: () => _actions(context, ref, m, isSelf: m.id == session!.active.memberId),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, Member m, {required bool isSelf}) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(m.name, style: Theme.of(sheet).textTheme.titleMedium)),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.memberEdit),
              onTap: () => Navigator.pop(sheet, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: Text(m.pinHash == null ? l10n.memberSetPin : l10n.memberChangePin),
              onTap: () => Navigator.pop(sheet, 'pin'),
            ),
            if (m.pinHash != null)
              ListTile(
                leading: const Icon(Icons.backspace_outlined),
                title: Text(l10n.memberClearPin),
                onTap: () => Navigator.pop(sheet, 'clear'),
              ),
            if (!isSelf)
              ListTile(
                leading: const Icon(Icons.person_remove_outlined, color: HomeColors.gumamela),
                title: Text(l10n.memberRemove),
                onTap: () => Navigator.pop(sheet, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    final writer = ref.read(servicesProvider).writer;
    switch (choice) {
      case 'edit':
        await _edit(context, ref, m, isSelf: isSelf);
      case 'pin':
        final pin = await askNewPin(context, title: l10n.enterPinFor(m.name));
        if (pin != null) await writer.update('members', m.id, {'pin_hash': hashPin(pin)});
      case 'clear':
        await writer.update('members', m.id, {'pin_hash': null});
      case 'remove':
        final ok = await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            content: Text(l10n.memberRemoveConfirm(m.name)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l10n.cancel)),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: HomeColors.gumamela, minimumSize: const Size(0, 44)),
                onPressed: () => Navigator.pop(d, true),
                child: Text(l10n.memberRemove),
              ),
            ],
          ),
        );
        if (ok == true) await writer.delete('members', m.id);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Member? m, {bool isSelf = false}) async {
    final result = await showModalBottomSheet<MemberDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MemberForm(initial: m, lockRole: isSelf || m?.role == 'owner'),
    );
    if (result == null) return;
    final writer = ref.read(servicesProvider).writer;
    final fields = {'name': result.name, 'role': result.role, 'color': result.color};
    if (m == null) {
      await writer.insert('members', fields);
    } else {
      fields.removeWhere((k, v) => switch (k) {
        'name' => v == m.name,
        'role' => v == m.role,
        _ => v == m.color,
      });
      if (fields.isNotEmpty) await writer.update('members', m.id, fields);
    }
  }
}

/// Asks for a new 4-digit PIN twice. Returns it, or null if cancelled.
Future<String?> askNewPin(BuildContext context, {required String title}) async {
  final l10n = AppLocalizations.of(context);
  Future<String?> ask(String t, {String? mustMatch}) => showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: PinPad(
        title: t,
        onComplete: (pin) async {
          if (mustMatch != null && pin != mustMatch) return l10n.pinsDontMatch;
          if (sheet.mounted) Navigator.of(sheet).pop(pin);
          return null;
        },
      ),
    ),
  );
  final first = await ask(title);
  if (first == null || !context.mounted) return null;
  return ask(l10n.confirmPinTitle, mustMatch: first);
}

class MemberDraft {
  const MemberDraft(this.name, this.role, this.color);
  final String name;
  final String role;
  final String color;
}

class MemberForm extends StatefulWidget {
  const MemberForm({super.key, this.initial, this.lockRole = false});

  final Member? initial;

  /// The owner can't change their own role.
  final bool lockRole;

  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late String _role = widget.initial?.role ?? 'adult';
  late String _color = widget.initial?.color ?? memberPalette.first;
  bool _tried = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _tried = true);
      return;
    }
    Navigator.pop(context, MemberDraft(name, _role, _color));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.initial == null ? l10n.memberAdd : l10n.memberEdit, style: text.titleLarge),
          const SizedBox(height: 16),
          TextField(
            key: const Key('member-name'),
            controller: _name,
            autofocus: widget.initial == null,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            decoration: InputDecoration(
              labelText: l10n.memberName,
              errorText: _tried && _name.text.trim().isEmpty ? l10n.memberNameRequired : null,
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 8),
          Text(l10n.memberRole, style: text.titleMedium),
          const SizedBox(height: 8),
          if (widget.lockRole)
            Text(roleLabel(l10n, _role))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in assignableRoles)
                  ChoiceChip(
                    label: Text(roleLabel(l10n, r)),
                    selected: _role == r,
                    onSelected: (_) => setState(() => _role = r),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Text(l10n.memberColor, style: text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              for (final c in memberPalette)
                Semantics(
                  button: true,
                  selected: _color == c,
                  label: c,
                  child: GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: memberColor(c),
                      child: _color == c ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
