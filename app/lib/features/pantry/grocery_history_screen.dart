import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../sync/sync_widgets.dart';
import 'grocery_dates.dart';
import 'pantry_providers.dart';
import 'pantry_repository.dart';

/// Past groceries: everything bought (cleared or not), grouped by the day it
/// was bought, newest first. Items can be put back on the list from here.
class GroceryHistoryScreen extends ConsumerWidget {
  const GroceryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final items = ref.watch(groceryHistoryProvider).value ?? const <GroceryItem>[];
    final canEdit = ref.watch(canEditPantryProvider);
    final now = DateTime.now();
    final thisMonth = items.where((g) {
      final at = g.boughtAt?.toLocal();
      return at != null && at.year == now.year && at.month == now.month;
    }).length;
    final days = groupByDay(items);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            figure: l10n.groceryHistoryFigure(thisMonth),
            caption: l10n.groceryHistoryCaption(DateFormat.MMMM(locale).format(now)),
            color: HomeColors.ube,
            leading: const BackButton(color: Colors.white),
          ),
          Expanded(
            child: days.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l10n.groceryHistoryEmpty, textAlign: TextAlign.center),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      for (final d in days) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  boughtDayLabel(context, d.day, now),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(l10n.groceryDayCount(d.items.length), style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [for (final g in d.items) _HistoryTile(item: g, canEdit: canEdit)],
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

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.item, required this.canEdit});

  final GroceryItem item;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final details = [?item.quantityText, ?item.store].join(' · ');
    return ListTile(
      title: Text(item.name),
      subtitle: details.isEmpty ? null : Text(details),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SyncMarker(entity: 'grocery_items', id: item.id),
          if (canEdit)
            IconButton(
              tooltip: l10n.groceryBuyAgain,
              icon: const Icon(Icons.add_shopping_cart, color: HomeColors.ube),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final added = await ref.read(pantryRepoProvider).buyAgain(item);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(added ? l10n.pantryAddedToList : l10n.pantryAlreadyOnList)));
              },
            ),
        ],
      ),
    );
  }
}
