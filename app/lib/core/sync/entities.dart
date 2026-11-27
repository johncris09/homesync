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
    this.neverMerged = false,
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

  /// Concurrent edits keep both versions; the older goes to conflicts.
  final bool neverMerged;

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
      'cleared_at',
      'planned_on',
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
      'category',
      'repeat',
      'series_id',
    },
    forwardOnly: {'is_paid'},
    reviewed: {'amount_minor'},
  ),
  'subscriptions': EntitySpec(
    name: 'subscriptions',
    fields: {'name', 'price_minor', 'currency', 'cycle', 'next_due_on', 'category'},
    reviewed: {'price_minor'},
  ),
  'chores': EntitySpec(
    name: 'chores',
    fields: {'name', 'assigned_to', 'repeat', 'weekday', 'due_on'},
  ),
  'chore_completions': EntitySpec(
    name: 'chore_completions',
    fields: {'chore_id', 'member_id', 'done_on'},
    appendOnly: true,
  ),
  'events': EntitySpec(
    name: 'events',
    fields: {
      'title',
      'starts_on',
      'ends_on',
      'start_time',
      'end_time',
      'repeat',
      'color',
      'member_id',
      'location',
      'note',
      'created_by',
    },
  ),
  'debts': EntitySpec(
    name: 'debts',
    fields: {
      'kind',
      'name',
      'counterparty',
      'reference',
      'principal_minor',
      'currency',
      'installment_minor',
      'next_due_on',
      'repeat',
      'started_on',
      'is_closed',
      'closed_at',
      'closed_by',
      'note',
    },
    forwardOnly: {'is_closed'},
    reviewed: {'principal_minor'},
  ),
  'debt_payments': EntitySpec(
    name: 'debt_payments',
    fields: {'debt_id', 'kind', 'amount_minor', 'currency', 'paid_on', 'member_id', 'note'},
    appendOnly: true,
    mutable: {'note'},
  ),
  'vehicles': EntitySpec(
    name: 'vehicles',
    fields: {
      'kind',
      'name',
      'plate',
      'color',
      'registration_due_on',
      'insurance_due_on',
      'pms_due_on',
      'pms_due_km',
      'pms_every_months',
      'pms_every_km',
      'note',
    },
  ),
  'vehicle_logs': EntitySpec(
    name: 'vehicle_logs',
    fields: {'vehicle_id', 'kind', 'amount_minor', 'currency', 'logged_on', 'odometer_km', 'litres', 'member_id', 'note'},
    appendOnly: true,
    mutable: {'note'},
  ),
  'rental_units': EntitySpec(name: 'rental_units', fields: {'name', 'note'}),
  'leases': EntitySpec(
    name: 'leases',
    fields: {
      'unit_id',
      'tenant_name',
      'phone',
      'rent_minor',
      'prev_rent_minor',
      'rent_since',
      'currency',
      'due_day',
      'starts_on',
      'ends_on',
      'deposit_minor',
      'deposit_returned_minor',
      'deposit_returned_on',
      'note',
    },
    reviewed: {'rent_minor'},
  ),
  'rent_payments': EntitySpec(
    name: 'rent_payments',
    fields: {'lease_id', 'kind', 'amount_minor', 'currency', 'paid_on', 'method', 'member_id', 'note'},
    appendOnly: true,
    mutable: {'note'},
  ),
  'emergency_contacts': EntitySpec(
    name: 'emergency_contacts',
    fields: {'name', 'kind', 'phone', 'note', 'position'},
  ),
  'emergency_plans': EntitySpec(
    name: 'emergency_plans',
    fields: {'meeting_point', 'meeting_point_far', 'evacuation_center', 'note'},
  ),
  'go_bag_items': EntitySpec(
    name: 'go_bag_items',
    fields: {'member_id', 'name', 'packed', 'expires_on', 'position'},
  ),
  'emergency_checks': EntitySpec(
    name: 'emergency_checks',
    fields: {'hazard', 'item', 'done', 'done_by', 'done_at'},
  ),
  'safety_checkins': EntitySpec(
    name: 'safety_checkins',
    fields: {'member_id', 'status', 'note', 'checked_at'},
    appendOnly: true,
  ),
  'inventory_items': EntitySpec(
    name: 'inventory_items',
    fields: {
      'name',
      'category',
      'room',
      'brand',
      'model',
      'serial_no',
      'bought_on',
      'price_minor',
      'currency',
      'warranty_until',
      'photo_sha256',
      'photo_size',
      'lent_to',
      'lent_on',
      'note',
    },
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
  'vault_keys': EntitySpec(
    name: 'vault_keys',
    fields: {'passphrase_wrap', 'kdf_salt', 'kdf_iterations', 'recovery_wrap', 'recovery_salt', 'created_by'},
    neverMerged: true,
  ),
  'vault_items': EntitySpec(
    name: 'vault_items',
    fields: {'kind', 'member_id', 'expires_on', 'sealed', 'created_by'},
    neverMerged: true,
  ),
  'vault_files': EntitySpec(
    name: 'vault_files',
    fields: {'item_id', 'sha256', 'size', 'key_wrap', 'sealed', 'position'},
    neverMerged: true,
  ),
  'health_profiles': EntitySpec(name: 'health_profiles', fields: {'member_id', 'sealed'}, neverMerged: true),
  'medicines': EntitySpec(
    name: 'medicines',
    fields: {
      'name',
      'strength',
      'member_id',
      'times',
      'dose_qty',
      'ends_on',
      'stock',
      'min_stock',
      'unit',
      'expires_on',
      'note',
    },
    counters: {'stock'},
  ),
  'med_doses': EntitySpec(
    name: 'med_doses',
    fields: {'medicine_id', 'member_id', 'given_by', 'taken_on', 'slot', 'taken_at', 'note'},
    appendOnly: true,
    mutable: {'note'},
  ),
  'checkups': EntitySpec(
    name: 'checkups',
    fields: {'member_id', 'kind', 'title', 'due_on', 'due_time', 'place', 'done_at', 'done_by', 'note'},
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
