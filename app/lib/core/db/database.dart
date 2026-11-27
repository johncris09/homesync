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
    Chores,
    ChoreCompletions,
    Events,
    Debts,
    DebtPayments,
    Budgets,
    Transactions,
    VaultKeys,
    VaultItems,
    VaultFiles,
    VaultBlobs,
    HealthProfiles,
    Medicines,
    MedDoses,
    Checkups,
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
  int get schemaVersion => 13;

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
      if (from < 4) {
        // Chores
        await m.createTable(chores);
        await m.createTable(choreCompletions);
      }
      if (from < 5) await m.createTable(events); // Calendar
      if (from < 6) {
        // Debts & Loans
        await m.createTable(debts);
        await m.createTable(debtPayments);
      }
      if (from < 7) await m.addColumn(groceryItems, groceryItems.clearedAt); // Grocery history
      if (from < 8) await m.addColumn(groceryItems, groceryItems.plannedOn); // Planned shopping day
      // Multi-day events; databases older than 5 got events with ends_on above.
      if (from >= 5 && from < 9) await m.addColumn(events, events.endsOn);
      if (from >= 5 && from < 10) await m.addColumn(events, events.color); // event colours
      if (from < 11) {
        // Document Vault
        await m.createTable(vaultKeys);
        await m.createTable(vaultItems);
        await m.createTable(vaultFiles);
        await m.createTable(vaultBlobs);
      }
      if (from < 13) {
        // Health (new tables only, so this step can be renumbered freely)
        await m.createTable(healthProfiles);
        await m.createTable(medicines);
        await m.createTable(medDoses);
        await m.createTable(checkups);
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
