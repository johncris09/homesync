import 'package:drift/drift.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Members,
    GroceryItems,
    PantryItems,
    Bills,
    Subscriptions,
    Budgets,
    Transactions,
    Conflicts,
    Outbox,
    FieldClocks,
    SyncState,
    SyncErrors,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await m.createIndex(
        Index(
          'outbox_entity',
          'CREATE INDEX outbox_entity ON outbox (entity, entity_id, seq)',
        ),
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(budgets); // Budget module
      if (from < 3) {
        // Bills & Subscriptions
        await m.addColumn(bills, bills.category);
        await m.addColumn(bills, bills.repeat);
        await m.addColumn(bills, bills.seriesId);
        await m.createTable(subscriptions);
      }
    },
  );

  /// Synced table by its wire name (e.g. `grocery_items`), or null.
  TableInfo<Table, dynamic>? syncedTable(String entity) {
    for (final t in allTables) {
      if (t.actualTableName == entity) return t;
    }
    return null;
  }
}
