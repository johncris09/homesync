<?php

/*
|--------------------------------------------------------------------------
| HomeSync sync configuration
|--------------------------------------------------------------------------
|
| The contract lives in docs/sync-protocol.md. This file is its server-side
| registry: every table the app may sync, which fields a device may send,
| which roles may read or write it, and which conflict rule applies.
|
| Field types: string, text, int, bool, decimal, date, datetime, uuid, json.
| Roles: owner, adult, teen, child, helper, viewer.
|
*/

$everyone = ['owner', 'adult', 'teen', 'child', 'helper', 'viewer'];
$household = ['owner', 'adult', 'teen', 'child', 'helper'];
$adults = ['owner', 'adult'];

return [

    'protocol' => 1,
    'min_protocol' => 1,

    // Release version (e.g. "1.2.3"), written to the VERSION file by the
    // release workflow; "dev" elsewhere. Sent as X-HomeSync-Version.
    'version' => is_file(base_path('VERSION')) ? trim((string) file_get_contents(base_path('VERSION'))) : 'dev',

    'push_max_ops' => 200,
    'pull_max_limit' => 500,

    // Encrypted vault files (/api/files): uploaded in chunks of at most
    // file_chunk_bytes, up to file_max_bytes per file.
    'file_chunk_bytes' => 1024 * 1024,
    'file_max_bytes' => 20 * 1024 * 1024,

    'entities' => [

        // Household members and PIN profiles. Owner manages them.
        'members' => [
            'table' => 'members',
            'fields' => [
                'name' => 'string',
                'role' => 'string',
                'color' => 'string',
                'pin_hash' => 'string',
                'user_id' => 'int',
            ],
            'read' => $everyone,
            'write' => ['owner'],
        ],

        // Shared grocery list. "Bought" only moves forward (see sync-protocol §6).
        // "Clear bought" sets cleared_at (kept for history), it does not delete.
        'grocery_items' => [
            'table' => 'grocery_items',
            'fields' => [
                'name' => 'string',
                'quantity_text' => 'string',
                'store' => 'string',
                'is_bought' => 'bool',
                'bought_at' => 'datetime',
                'cleared_at' => 'datetime',
                'planned_on' => 'date',
                'requested_by' => 'uuid',
                'note' => 'text',
            ],
            'forward_only' => ['is_bought'],
            'read' => $household,
            'write' => $household,
        ],

        // Pantry stock. Quantity changes arrive as increments so offline use merges.
        'pantry_items' => [
            'table' => 'pantry_items',
            'fields' => [
                'name' => 'string',
                'unit' => 'string',
                'quantity' => 'decimal',
                'min_quantity' => 'decimal',
                'location' => 'string',
                'expires_on' => 'date',
            ],
            'counters' => ['quantity'],
            'read' => $household,
            'write' => $household,
        ],

        // One bill per due date. Paid only moves forward; amount changes are
        // reviewed. Monthly bills share a series_id; the next occurrence's id is
        // derived from the series and due date (sync-protocol §2.1).
        'bills' => [
            'table' => 'bills',
            'fields' => [
                'name' => 'string',
                'provider' => 'string',
                'amount_minor' => 'int',
                'currency' => 'string',
                'due_on' => 'date',
                'is_paid' => 'bool',
                'paid_at' => 'datetime',
                'category' => 'string',
                'repeat' => 'string',
                'series_id' => 'uuid',
            ],
            'forward_only' => ['is_paid'],
            'reviewed' => ['amount_minor'],
            'read' => $adults,
            'write' => $adults,
        ],

        // Subscriptions (streaming, apps, memberships). Paying posts to the
        // ledger and moves next_due_on one cycle on; price changes are reviewed.
        'subscriptions' => [
            'table' => 'subscriptions',
            'fields' => [
                'name' => 'string',
                'price_minor' => 'int',
                'currency' => 'string',
                'cycle' => 'string',
                'next_due_on' => 'date',
                'category' => 'string',
            ],
            'reviewed' => ['price_minor'],
            'read' => $adults,
            'write' => $adults,
        ],

        // Monthly limit per spending category. The id is derived from the
        // household and category (sync-protocol §2.1); limit changes are reviewed.
        'budgets' => [
            'table' => 'budgets',
            'fields' => [
                'category' => 'string',
                'limit_minor' => 'int',
                'currency' => 'string',
            ],
            'reviewed' => ['limit_minor'],
            'read' => $adults,
            'write' => $adults,
        ],

        // Household chores: daily, weekly on one weekday (1 = Monday), or once
        // on a date. Adults manage them; doing one is a chore_completions row.
        'chores' => [
            'table' => 'chores',
            'fields' => [
                'name' => 'string',
                'assigned_to' => 'uuid',
                'repeat' => 'string',
                'weekday' => 'int',
                'due_on' => 'date',
            ],
            'read' => $everyone,
            'write' => $adults,
        ],

        // Who did a chore on which day. Append-only: undo is a delete.
        'chore_completions' => [
            'table' => 'chore_completions',
            'fields' => [
                'chore_id' => 'uuid',
                'member_id' => 'uuid',
                'done_on' => 'date',
            ],
            'append_only' => true,
            'mutable' => [],
            'read' => $everyone,
            'write' => $household,
        ],

        // Calendar events: all day or at a local "HH:MM" time, once or
        // repeating weekly, monthly or yearly from starts_on. ends_on is the
        // last day of a multi-day event (null = one day); a repeat copies the
        // whole span. color is a palette name (null = default). member_id is
        // who it is for (null = the whole family). Everyone but viewers adds them.
        'events' => [
            'table' => 'events',
            'fields' => [
                'title' => 'string',
                'starts_on' => 'date',
                'ends_on' => 'date',
                'start_time' => 'string',
                'end_time' => 'string',
                'repeat' => 'string',
                'color' => 'string',
                'member_id' => 'uuid',
                'location' => 'string',
                'note' => 'text',
                'created_by' => 'uuid',
            ],
            'read' => $everyone,
            'write' => $household,
        ],

        // Debts & Loans: kind is loan, card, pawn (a pawn ticket; next_due_on is
        // its maturity) or lent (money owed to the household). The balance is
        // principal_minor plus charges minus payments in debt_payments. Paid off
        // only moves forward; principal changes are reviewed.
        'debts' => [
            'table' => 'debts',
            'fields' => [
                'kind' => 'string',
                'name' => 'string',
                'counterparty' => 'string',
                'reference' => 'string',
                'principal_minor' => 'int',
                'currency' => 'string',
                'installment_minor' => 'int',
                'next_due_on' => 'date',
                'repeat' => 'string',
                'started_on' => 'date',
                'is_closed' => 'bool',
                'closed_at' => 'datetime',
                'closed_by' => 'uuid',
                'note' => 'text',
            ],
            'forward_only' => ['is_closed'],
            'reviewed' => ['principal_minor'],
            'read' => $adults,
            'write' => $adults,
        ],

        // What happened to a debt: kind payment (lowers the balance), interest
        // (paid, balance unchanged, e.g. renewing a pawn ticket) or charge
        // (raises it). amount_minor is positive. Append-only: undo is a delete.
        'debt_payments' => [
            'table' => 'debt_payments',
            'fields' => [
                'debt_id' => 'uuid',
                'kind' => 'string',
                'amount_minor' => 'int',
                'currency' => 'string',
                'paid_on' => 'date',
                'member_id' => 'uuid',
                'note' => 'text',
            ],
            'append_only' => true,
            'mutable' => ['note'],
            'read' => $adults,
            'write' => $adults,
        ],

        // Vehicles: kind is car or motorcycle. Due dates for LTO registration
        // and insurance (yearly) and PMS / change oil by date and/or odometer
        // (pms_due_km); pms_every_* set the next PMS when one is logged.
        'vehicles' => [
            'table' => 'vehicles',
            'fields' => [
                'kind' => 'string',
                'name' => 'string',
                'plate' => 'string',
                'color' => 'string',
                'registration_due_on' => 'date',
                'insurance_due_on' => 'date',
                'pms_due_on' => 'date',
                'pms_due_km' => 'int',
                'pms_every_months' => 'int',
                'pms_every_km' => 'int',
                'note' => 'text',
            ],
            'read' => $adults,
            'write' => $adults,
        ],

        // What happened to a vehicle: kind fuel, repair, pms, registration,
        // insurance (costs, amount_minor positive) or odometer (a reading
        // only). The odometer is the highest odometer_km. Append-only.
        'vehicle_logs' => [
            'table' => 'vehicle_logs',
            'fields' => [
                'vehicle_id' => 'uuid',
                'kind' => 'string',
                'amount_minor' => 'int',
                'currency' => 'string',
                'logged_on' => 'date',
                'odometer_km' => 'int',
                'litres' => 'decimal',
                'member_id' => 'uuid',
                'note' => 'text',
            ],
            'append_only' => true,
            'mutable' => ['note'],
            'read' => $adults,
            'write' => $adults,
        ],

        // The money ledger. Append-only: only note and deletion can change later.
        'transactions' => [
            'table' => 'transactions',
            'fields' => [
                'account_id' => 'uuid',
                'category' => 'string',
                'amount_minor' => 'int',
                'currency' => 'string',
                'occurred_at' => 'datetime',
                'member_id' => 'uuid',
                'source_type' => 'string',
                'source_id' => 'uuid',
                'note' => 'text',
            ],
            'append_only' => true,
            'mutable' => ['note'],
            'read' => $adults,
            'write' => $household,
        ],

        // Document Vault (docs/vault.md). The household vault key, wrapped by
        // the vault passphrase (PBKDF2) and by the owner's recovery code. One
        // row per household, id derived from the household (sync-protocol
        // §2.1). Only the owner sets it up or changes the passphrase.
        'vault_keys' => [
            'table' => 'vault_keys',
            'fields' => [
                'passphrase_wrap' => 'text',
                'kdf_salt' => 'string',
                'kdf_iterations' => 'int',
                'recovery_wrap' => 'text',
                'recovery_salt' => 'string',
                'created_by' => 'uuid',
            ],
            'never_merged' => true,
            'read' => $adults,
            'write' => ['owner'],
        ],

        // A document: kind, whose it is and when it expires are plain so
        // reminders work while the vault is locked; the title, number,
        // issuer and note are one encrypted `sealed` blob.
        'vault_items' => [
            'table' => 'vault_items',
            'fields' => [
                'kind' => 'string',
                'member_id' => 'uuid',
                'expires_on' => 'date',
                'sealed' => 'text',
                'created_by' => 'uuid',
            ],
            'never_merged' => true,
            'read' => $adults,
            'write' => $adults,
        ],

        // A photo or PDF of a document. The bytes are encrypted on the device
        // with their own key (key_wrap, wrapped by the vault key) and uploaded
        // to /api/files/{sha256}; sha256 is of the ciphertext. The file name
        // and type are in `sealed`.
        'vault_files' => [
            'table' => 'vault_files',
            'fields' => [
                'item_id' => 'uuid',
                'sha256' => 'string',
                'size' => 'int',
                'key_wrap' => 'text',
                'sealed' => 'text',
                'position' => 'int',
            ],
            'never_merged' => true,
            'read' => $adults,
            'write' => $adults,
        ],

        // Reviewed-money and never-auto-merged losers, for the Conflict Inbox.
        // Created only by the server; devices may only mark them resolved.
        'conflicts' => [
            'table' => 'conflicts',
            'fields' => [
                'entity' => 'string',
                'entity_id' => 'uuid',
                'field' => 'string',
                'kept_value' => 'json',
                'kept_by' => 'uuid',
                'lost_value' => 'json',
                'lost_by' => 'uuid',
                'resolved_at' => 'datetime',
                'resolved_by' => 'uuid',
            ],
            'server_created' => true,
            'append_only' => true,
            'mutable' => ['resolved_at', 'resolved_by'],
            'read' => $adults,
            'write' => $adults,
        ],
    ],
];
