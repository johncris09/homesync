import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/sync/sync_scheduler.dart';
import '../../l10n/app_localizations.dart';

/// "Last synced …" card with the sync state and a Sync now button.
class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final status = ref.watch(syncStatusProvider).value ?? const SyncStatus(SyncPhase.idle);
    final last = ref.watch(lastSyncedProvider).value;
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    String time(DateTime t) => DateFormat.MMMd(locale).add_jm().format(t.toLocal());

    final (IconData icon, Color color, String line) = switch (status.phase) {
      SyncPhase.syncing => (Icons.sync, HomeColors.dagat, l10n.syncSyncing),
      SyncPhase.waitingToRetry => (
        Icons.cloud_off_outlined,
        HomeColors.mangga,
        l10n.syncRetry(DateFormat.jm(locale).format(status.retryAt!.toLocal())),
      ),
      SyncPhase.upgradeRequired => (Icons.system_update, HomeColors.gumamela, l10n.syncUpgrade),
      SyncPhase.signedOut => (Icons.lock_outline, HomeColors.gumamela, l10n.syncSignedOut),
      SyncPhase.idle => (
        Icons.cloud_done_outlined,
        HomeColors.dahon,
        last == null ? l10n.syncNever : l10n.syncLast(time(last)),
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line, style: Theme.of(context).textTheme.bodyLarge),
                  if (pending > 0)
                    Text(l10n.syncPending(pending), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            TextButton(
              onPressed: status.phase == SyncPhase.syncing || status.phase == SyncPhase.upgradeRequired
                  ? null
                  : () => ref.read(servicesProvider).scheduler.requestSync(),
              child: Text(l10n.syncNow),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small marker for a record: open conflict (needs review) or local changes
/// not synced yet. Empty when the record is in sync.
class SyncMarker extends ConsumerWidget {
  const SyncMarker({super.key, required this.entity, required this.id});

  final String entity;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (ref.watch(conflictIdsProvider(entity)).value?.contains(id) ?? false) {
      return Tooltip(
        message: l10n.conflictMarker,
        child: Icon(Icons.error_outline, size: 18, color: HomeColors.mangga, semanticLabel: l10n.conflictMarker),
      );
    }
    if (ref.watch(pendingIdsProvider(entity)).value?.contains(id) ?? false) {
      return Tooltip(
        message: l10n.pendingMarker,
        child: Icon(Icons.cloud_upload_outlined, size: 18, color: HomeColors.narra.withValues(alpha: 0.6), semanticLabel: l10n.pendingMarker),
      );
    }
    return const SizedBox.shrink();
  }
}
