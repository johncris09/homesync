import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/app_version.dart';
import '../../core/db/database.dart';
import '../../core/auth/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/pin_pad.dart';
import '../../shared/money.dart';
import '../bills/bills_providers.dart';
import '../budget/budget_providers.dart';
import '../calendar/calendar_providers.dart';
import '../calendar/calendar_screen.dart' show dayLabel;
import '../chores/chores_providers.dart';
import '../debts/debts_providers.dart';
import '../pantry/pantry_providers.dart';
import '../pantry/pantry_repository.dart' show isLow;
import '../sync/sync_widgets.dart';
import '../vault/vault_providers.dart';

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
    final hub = ref.watch(hubVersionProvider).value;
    final adult = session.active.isAdult;
    final toBuy = ref.watch(toBuyProvider).value?.length ?? 0;
    final low = ref.watch(pantryItemsProvider).value?.where(isLow).length ?? 0;
    final canRecord = ref.watch(canRecordSpendingProvider);
    final money = ref.watch(currentMonthSummaryProvider).value;
    final locale = Localizations.localeOf(context).toString();
    String peso(int minor) => formatPeso(minor, locale: locale, whole: true);
    final budgetCaption = !adult || money == null
        ? l10n.budgetTileRecord
        : money.hasBudget
        ? (money.left >= 0 ? l10n.budgetTileLeft(peso(money.left)) : l10n.budgetTileOver(peso(-money.left)))
        : l10n.budgetTileSpent(peso(money.spent));
    final bills = adult ? ref.watch(billsSummaryProvider) : null;
    final debts = adult ? ref.watch(debtsSummaryProvider) : null;
    final vaultItems = adult ? (ref.watch(vaultItemsProvider).value ?? const <VaultItem>[]) : const <VaultItem>[];
    final vaultReady = adult && ref.watch(vaultKeyRowProvider).value != null;
    final vaultRenew = adult ? vaultItems.where(ref.watch(vaultRepoProvider).renewSoon).length : 0;
    final chores = ref.watch(choreBoardProvider);
    final choresCaption = chores.today.isEmpty
        ? l10n.choresTileNone
        : chores.left == 0
        ? l10n.choresTileDone
        : !adult && chores.mineLeft > 0
        ? l10n.choresTileMine(chores.mineLeft)
        : l10n.choresTileLeft(chores.left);
    final agenda = ref.watch(upcomingAgendaProvider);
    final today = ref.watch(calendarRepoProvider).today;
    final todays = agenda.on(today).length;
    final nextDay = agenda.daysAfter(today).firstOrNull;
    final calendarCaption = todays > 0
        ? l10n.calendarTileToday(todays)
        : nextDay != null
        ? l10n.calendarTileNext(nextDay.$2.first.title, dayLabel(context, nextDay.$1, today))
        : l10n.calendarTileNone;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: l10n.homeGreeting(session.active.name),
            caption: l10n.homeCaption,
            color: HomeColors.dahon,
          ),
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
                      if (canRecord)
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: HomeColors.dahon,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          title: Text(l10n.budgetModule),
                          subtitle: Text(budgetCaption),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.budget),
                        ),
                      if (bills != null)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: bills.overdue > 0 ? HomeColors.gumamela : HomeColors.mangga,
                            foregroundColor: bills.overdue > 0 ? Colors.white : HomeColors.narra,
                            child: const Icon(Icons.receipt_long_outlined),
                          ),
                          title: Text(l10n.billsModule),
                          subtitle: Text(
                            bills.overdue > 0
                                ? l10n.billsTileOverdue(bills.overdue)
                                : bills.due > 0
                                ? l10n.billsTileDue(peso(bills.due))
                                : l10n.billsTileClear,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.bills),
                        ),
                      if (debts != null)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: debts.overdue > 0 ? HomeColors.gumamela : HomeColors.narra,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.account_balance_outlined),
                          ),
                          title: Text(l10n.debtsModule),
                          subtitle: Text(
                            debts.overdue > 0
                                ? l10n.debtsTileOverdue(debts.overdue)
                                : debts.owed > 0
                                ? l10n.debtsTileOwed(peso(debts.owed))
                                : l10n.debtsTileNone,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.debts),
                        ),
                      if (adult)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: vaultRenew > 0 ? HomeColors.mangga : HomeColors.narra,
                            foregroundColor: vaultRenew > 0 ? HomeColors.narra : Colors.white,
                            child: const Icon(Icons.lock_outline),
                          ),
                          title: Text(l10n.vaultModule),
                          subtitle: Text(
                            !vaultReady
                                ? l10n.vaultTileSetUp
                                : vaultRenew > 0
                                ? l10n.vaultTileRenew(vaultRenew)
                                : l10n.vaultTileDocs(vaultItems.length),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.vault),
                        ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: HomeColors.dagat,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.cleaning_services_outlined),
                        ),
                        title: Text(l10n.choresModule),
                        subtitle: Text(choresCaption),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.chores),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: HomeColors.ube,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.event_outlined),
                        ),
                        title: Text(l10n.calendarModule),
                        subtitle: Text(calendarCaption),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.calendar),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: HomeColors.ube,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.kitchen_outlined),
                        ),
                        title: Text(l10n.pantryModule),
                        subtitle: Text(l10n.pantryModuleCaption(toBuy, low)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.pantry),
                      ),
                    ],
                  ),
                ),
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
                      if (session.active.role == 'owner')
                        ListTile(
                          leading: const Icon(Icons.group_outlined, color: HomeColors.dagat),
                          title: Text(l10n.membersTitle),
                          onTap: () => context.push(Routes.members),
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
                const SizedBox(height: 8),
                Text(
                  hub == null ? l10n.versionLineNoHub(appVersion) : l10n.versionLine(appVersion, hub),
                  key: const Key('version-line'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
      biometrics =
          await showDialog<bool>(
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
