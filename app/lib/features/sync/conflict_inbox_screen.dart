import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';

class ConflictInboxScreen extends ConsumerWidget {
  const ConflictInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final conflicts = ref.watch(openConflictsProvider).value ?? const [];
    final names = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m.name};

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: '${conflicts.length}',
            caption: l10n.conflictInboxCaption(conflicts.length),
            color: HomeColors.mangga,
            leading: const BackButton(color: Colors.white),
          ),
          for (final c in conflicts)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _ConflictCard(conflict: c, names: names),
            ),
        ],
      ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict, required this.names});

  final ConflictRecord conflict;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final inbox = ref.read(conflictInboxProvider);
    String who(String? id) => names[id] ?? l10n.someone;
    String value(String? json) =>
        formatConflictValue(conflict.field, json, l10n.emptyValue, Localizations.localeOf(context).toString());

    // Vault values are ciphertext: compare them inside the vault, where only
    // the owner chooses (sync-protocol §6).
    if (conflict.entity.startsWith('vault_')) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(l10n.vaultModule),
          subtitle: Text(l10n.vaultInboxNote),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => GoRouter.of(context).push(Routes.vault),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.conflictSummary(_label(conflict.field), _label(conflict.entity)), style: text.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.conflictKept(value(conflict.keptValue), who(conflict.keptBy))),
            Text(
              l10n.conflictLost(value(conflict.lostValue), who(conflict.lostBy)),
              style: text.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => inbox.revert(conflict), child: Text(l10n.revert)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(onPressed: () => inbox.keep(conflict), child: Text(l10n.keep)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// `amount_minor` -> `Amount`, `bills` -> `Bills`. Module screens will
  /// supply proper localized labels once they exist.
  static String _label(String name) {
    final words = name.replaceAll('_minor', '').replaceAll('_', ' ');
    return words.isEmpty ? name : words[0].toUpperCase() + words.substring(1);
  }
}

/// Shows a JSON value from a conflict; `*_minor` money fields as pesos.
String formatConflictValue(String field, String? json, String empty, String locale) {
  final v = json == null ? null : jsonDecode(json);
  if (v == null) return empty;
  if (field.endsWith('_minor') && v is num) {
    return NumberFormat.currency(locale: locale, symbol: '₱').format(v / 100);
  }
  return '$v';
}
