import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/auth/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/pin_pad.dart';
import '../sync/sync_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authProvider).session;
    if (session == null) return const SizedBox.shrink();
    final lock = ref.watch(appLockProvider);
    final conflicts = ref.watch(openConflictsProvider).value?.length ?? 0;
    final errors = ref.watch(syncErrorsProvider).value?.length ?? 0;
    final adult = session.active.isAdult;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(figure: l10n.homeGreeting(session.active.name), caption: l10n.homeCaption, color: HomeColors.dahon),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SyncStatusCard(),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      if (adult)
                        ListTile(
                          leading: const Icon(Icons.rule, color: HomeColors.mangga),
                          title: Text(l10n.conflictInboxTitle),
                          subtitle: Text(l10n.conflictInboxCaption(conflicts)),
                          onTap: () => context.push(Routes.conflicts),
                        ),
                      ListTile(
                        leading: Icon(Icons.sync_problem, color: errors > 0 ? HomeColors.gumamela : HomeColors.narra),
                        title: Text(l10n.syncErrorsTitle),
                        subtitle: Text(l10n.syncErrorsCaption(errors)),
                        onTap: () => context.push(Routes.syncProblems),
                      ),
                      if (session.isShared)
                        ListTile(
                          leading: const Icon(Icons.switch_account, color: HomeColors.dagat),
                          title: Text(l10n.switchProfile),
                          onTap: () => context.push(Routes.profiles),
                        ),
                      if (!session.isShared)
                        ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: Text(l10n.appLockTitle),
                          subtitle: Text(lock.enabled ? l10n.appLockOn : l10n.appLockOff),
                          onTap: () => lock.enabled ? _turnOffLock(context, ref) : _turnOnLock(context, ref),
                        ),
                      if (adult || !session.isShared)
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: Text(l10n.signOut),
                          onTap: () => _signOut(context, ref),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.modulesComingSoon, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _turnOnLock(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final first = await _askPin(context, l10n.setPinTitle);
    if (first == null || !context.mounted) return;
    final second = await _askPin(context, l10n.confirmPinTitle, mustMatch: first);
    if (second == null || !context.mounted) return;
    final services = ref.read(servicesProvider);
    var biometrics = false;
    if (await services.appLock.biometricAuth.available() && context.mounted) {
      biometrics = await showDialog<bool>(
            context: context,
            builder: (d) => AlertDialog(
              content: Text(l10n.unlockWithBiometrics),
              actions: [
                TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l10n.cancel)),
                FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l10n.save)),
              ],
            ),
          ) ??
          false;
    }
    await services.appLock.enable(second, biometrics: biometrics);
  }

  Future<void> _turnOffLock(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final lock = ref.read(appLockProvider);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: PinPad(
          title: l10n.turnOff,
          onComplete: (pin) async {
            try {
              if (!await lock.unlockWithPin(pin)) return l10n.wrongPin;
            } on TooManyPinAttempts catch (e) {
              return l10n.tooManyTries(secondsUntil(e.until));
            }
            if (sheet.mounted) Navigator.of(sheet).pop(true);
            return null;
          },
        ),
      ),
    );
    if (ok == true) await lock.disable();
  }

  Future<String?> _askPin(BuildContext context, String title, {String? mustMatch}) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: PinPad(
          title: title,
          onComplete: (pin) async {
            if (mustMatch != null && pin != mustMatch) return l10n.pinsDontMatch;
            if (sheet.mounted) Navigator.of(sheet).pop(pin);
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l10n.signOut)),
        ],
      ),
    );
    if (ok == true) await ref.read(authProvider).signOut();
  }
}
