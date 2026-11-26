import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/auth/auth_api.dart';
import '../../core/auth/pin_hash.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/pin_pad.dart';
import '../members/members_screen.dart' show memberColor;

/// Shared tablet: pick who is using it, then enter that person's PIN.
class ProfilePickerScreen extends ConsumerWidget {
  const ProfilePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final members = ref.watch(membersProvider).value ?? const [];
    final session = ref.watch(authProvider).session;
    final active = session?.active.memberId;
    // The setup person always has the tablet PIN kept on this install.
    bool canPick(Member m) => m.pinHash != null || m.id == session?.main.memberId;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: l10n.switchProfile,
            caption: l10n.profilesTitle,
            color: HomeColors.dagat,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                      subtitle: canPick(m) ? null : Text(l10n.profileNoPin),
                      trailing: m.id == active ? const Icon(Icons.check_circle, color: HomeColors.dahon) : null,
                      enabled: canPick(m),
                      onTap: () => _enterPin(context, ref, m),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enterPin(BuildContext context, WidgetRef ref, Member m) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: PinPad(
          title: l10n.enterPinFor(m.name),
          onComplete: (pin) async {
            try {
              await ref.read(authProvider).switchProfile(m, pin);
              if (sheet.mounted) Navigator.of(sheet).pop(true);
              return null;
            } on InvalidCredentials {
              return l10n.wrongPin;
            } on TooManyPinAttempts catch (e) {
              return l10n.tooManyTries(secondsUntil(e.until));
            }
          },
        ),
      ),
    );
    if (ok == true && context.mounted) context.go('/');
  }
}
