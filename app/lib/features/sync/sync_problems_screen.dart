import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

/// Ops the hub rejected (sync-protocol §5.1), until the user dismisses them.
class SyncProblemsScreen extends ConsumerWidget {
  const SyncProblemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final errors = ref.watch(syncErrorsProvider).value ?? const [];
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: l10n.syncErrorsTitle,
            caption: l10n.syncErrorsCaption(errors.length),
            color: errors.isEmpty ? HomeColors.dahon : HomeColors.gumamela,
            leading: const BackButton(color: Colors.white),
          ),
          if (errors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  children: [
                    for (final e in errors)
                      ListTile(
                        title: Text(l10n.syncErrorLine(e.entity.replaceAll('_', ' '), e.error)),
                        subtitle: e.details == null ? null : Text(e.details!, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: TextButton(
                          onPressed: () => ref.read(syncStatusRepoProvider).dismissError(e.id),
                          child: Text(l10n.dismiss),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
