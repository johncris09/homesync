/// App-side mirror of `api/config/homesync.php`: which tables sync, which
/// fields a device may send, and which conflict rule each field follows.
/// Keep both files in step (docs/sync-protocol.md §6).
library;

class EntitySpec {
  const EntitySpec({
    required this.name,
    required this.fields,
    this.counters = const {},
    this.forwardOnly = const {},
    this.reviewed = const {},
    this.appendOnly = false,
    this.mutable = const {},
    this.jsonFields = const {},
    this.serverCreated = false,
  });

  /// Wire and table name, e.g. `grocery_items`.
  final String name;

  /// Writable fields (wire names). Sync columns are not listed.
  final Set<String> fields;

  /// Counter fields: changed only with `increment` ops after insert.
  final Set<String> counters;

  /// "Done" flags where true wins over false.
  final Set<String> forwardOnly;

  /// Money fields whose overwritten value goes to the conflict inbox.
  final Set<String> reviewed;

  /// Inserts only; afterwards only [mutable] fields and deletion may change.
  final bool appendOnly;
  final Set<String> mutable;

  /// Fields holding any JSON value; stored locally as JSON text.
  final Set<String> jsonFields;

  /// Rows only the hub creates; devices may not insert them.
  final bool serverCreated;

  bool canUpdate(String field) =>
      fields.contains(field) &&
      !counters.contains(field) &&
      (!appendOnly || mutable.contains(field));
}

const syncedEntities = <String, EntitySpec>{
  'members': EntitySpec(
    name: 'members',
    fields: {'name', 'role', 'color', 'pin_hash', 'user_id'},
  ),
  'grocery_items': EntitySpec(
    name: 'grocery_items',
    fields: {
      'name',
      'quantity_text',
      'store',
      'is_bought',
      'bought_at',
      'requested_by',
      'note',
    },
    forwardOnly: {'is_bought'},
  ),
  'pantry_items': EntitySpec(
    name: 'pantry_items',
    fields: {'name', 'unit', 'quantity', 'min_quantity', 'location', 'expires_on'},
    counters: {'quantity'},
  ),
  'budgets': EntitySpec(
    name: 'budgets',
    fields: {'category', 'limit_minor', 'currency'},
    reviewed: {'limit_minor'},
  ),
  'bills': EntitySpec(
    name: 'bills',
    fields: {
      'name',
      'provider',
      'amount_minor',
      'currency',
      'due_on',
      'is_paid',
      'paid_at',
    },
    forwardOnly: {'is_paid'},
    reviewed: {'amount_minor'},
  ),
  'transactions': EntitySpec(
    name: 'transactions',
    fields: {
      'account_id',
      'category',
      'amount_minor',
      'currency',
      'occurred_at',
      'member_id',
      'source_type',
      'source_id',
      'note',
    },
    appendOnly: true,
    mutable: {'note'},
  ),
  'conflicts': EntitySpec(
    name: 'conflicts',
    fields: {
      'entity',
      'entity_id',
      'field',
      'kept_value',
      'kept_by',
      'lost_value',
      'lost_by',
      'resolved_at',
      'resolved_by',
    },
    appendOnly: true,
    mutable: {'resolved_at', 'resolved_by'},
    jsonFields: {'kept_value', 'lost_value'},
    serverCreated: true,
  ),
};

EntitySpec specFor(String entity) {
  final spec = syncedEntities[entity];
  if (spec == null) throw ArgumentError.value(entity, 'entity', 'not a synced entity');
  return spec;
}
