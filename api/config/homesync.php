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

    'push_max_ops' => 200,
    'pull_max_limit' => 500,

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
        'grocery_items' => [
            'table' => 'grocery_items',
            'fields' => [
                'name' => 'string',
                'quantity_text' => 'string',
                'store' => 'string',
                'is_bought' => 'bool',
                'bought_at' => 'datetime',
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

        // Recurring bills. Paid only moves forward; amount changes are reviewed.
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
            ],
            'forward_only' => ['is_paid'],
            'reviewed' => ['amount_minor'],
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
