# HomeSync Sync Protocol — v1 (draft)

The contract between the Flutter app (`app/`) and the Laravel API (`api/`). Any change to a synced table, an op shape or a conflict rule updates this file first, in the same pull request as the code.

- **Protocol version:** `1`
- **Transport:** HTTPS, JSON, gzip allowed both ways
- **Auth:** Laravel Sanctum bearer token, one token per device

---

## 1. Principles

1. The device's local database is the source of truth for its UI. The server is a relay and merge point.
2. Every record ID is generated on the device (UUIDv7). The server never assigns IDs.
3. Every local write appends an op to the device **outbox** in the same transaction as the row change.
4. Sync = **push** (send outbox) then **pull** (receive changes since cursor). Always in that order.
5. Every op is idempotent by `op_id`. Re-sending a batch is always safe.

---

## 2. Sync columns (every synced table, app and server)

| Column | Type | Notes |
| --- | --- | --- |
| `id` | UUIDv7 (string, 36) | Generated on device |
| `household_id` | UUID | Scope of all access checks |
| `created_at` | timestamp (UTC) | Set by device on insert |
| `updated_at` | timestamp (UTC) | Set by device on every change |
| `deleted_at` | timestamp (UTC), nullable | Soft delete = tombstone |
| `hlc` | string | Hybrid logical clock of the last change (see §4) |
| `server_version` | bigint, nullable | Change-log `seq` of the last server-applied change; null until first sync |
| `updated_by` | UUID | Member who made the last change |
| `device_id` | UUID | Device that made the last change |

Server-only tables: `change_log`, `processed_ops`, `device_cursors`.

Per-field HLCs for field-level merge are stored server-side in `change_log` payloads and on the device in a `field_clocks` table (`entity`, `entity_id`, `field`, `hlc`).

---

## 3. Op format (outbox entry)

```json
{
  "op_id": "0193a1f2-7c4e-7b2a-9d11-3f6c2a9e8b10",
  "entity": "grocery_items",
  "entity_id": "0193a1f0-1111-7aaa-8bbb-cccccccccccc",
  "op": "update",
  "fields": { "is_bought": true, "bought_at": "2026-11-25T06:31:00Z" },
  "hlc": "1795586684123-0003-3f6c2a9e",
  "base_version": 1842
}
```

| `op` | Meaning | `fields` |
| --- | --- | --- |
| `insert` | New record | All columns except server-managed ones |
| `update` | Change some fields | Changed fields only |
| `delete` | Soft delete | `{ "deleted_at": "<ts>" }` |
| `increment` | Add to a counter-type quantity | `{ "<field>": <signed number> }`, e.g. `{ "quantity": -1 }` |

Rules:
- Edits to the same record before a push are merged on the device into one op (latest value per field, increments summed).
- `increment` is only allowed on fields listed as counters in §6.
- Money is always integer minor units (`amount_minor`, centavos) with `currency`.

---

## 4. Hybrid logical clock (HLC)

Format: `<physical_ms>-<counter 4 hex>-<node 8 hex>`, compared as a tuple (physical, counter, node). The string sorts correctly when compared lexicographically because each part is fixed-width (physical_ms is 13 digits until the year 2286).

- **On local change:** `physical = max(now_ms, last.physical)`; counter = 0 if physical advanced, else `last.counter + 1`.
- **On receiving a remote HLC:** `physical = max(now_ms, last.physical, remote.physical)`; counter advanced accordingly.
- `node` = first 8 hex chars of `device_id`.
- The server returns its own time in every response (`server_time_ms`); the device keeps the max seen, so a phone with a wrong date still orders changes correctly after one sync.

---

## 5. Endpoints

### 5.1 `POST /api/sync/push`

Request:

```json
{
  "protocol": 1,
  "device_id": "…",
  "ops": [ { …op… }, … ]
}
```

- Max 200 ops per request. The device sends batches until the outbox is empty.
- The server applies the whole batch in one DB transaction, in the order given.

Response `200`:

```json
{
  "server_time_ms": 1795586690000,
  "results": [
    { "op_id": "…", "status": "applied",   "server_version": 1851 },
    { "op_id": "…", "status": "duplicate", "server_version": 1790 },
    { "op_id": "…", "status": "merged",    "server_version": 1852, "conflict_id": "…" },
    { "op_id": "…", "status": "rejected",  "error": "forbidden" }
  ]
}
```

| `status` | Device action |
| --- | --- |
| `applied` | Remove from outbox |
| `duplicate` | Already applied earlier (retry after a dropped connection); remove from outbox |
| `merged` | Applied with a conflict rule; remove from outbox; final state arrives on pull; a conflict record may exist |
| `rejected` | Remove from outbox, keep in a local `sync_errors` table and show it to the user |

Rejection `error` codes: `forbidden` (role may not write this entity), `validation` (with `details`), `unknown_entity`, `not_counter`, `household_mismatch`.

### 5.2 `GET /api/sync/pull?cursor=<seq>&limit=500`

Response `200`:

```json
{
  "server_time_ms": 1795586690000,
  "changes": [
    {
      "seq": 1852,
      "entity": "grocery_items",
      "entity_id": "…",
      "op": "update",
      "row": { …full current row… }
    }
  ],
  "cursor": 1852,
  "has_more": false
}
```

- `row` is always the full merged row (including tombstones), so the device simply upserts it.
- The device applies a page in one transaction, then stores `cursor`. Repeat while `has_more`.
- Changes are filtered by the member's role (a Helper never receives vault rows).

### 5.3 `GET /api/sync/bootstrap`

For a new device or reinstall. Returns a gzip JSON snapshot of every table the member may read, plus the `cursor` it is valid from. The device then switches to normal pulls.

### 5.4 Version check

Every request sends header `X-HomeSync-Protocol: 1`. If the server no longer supports it, it responds `426 Upgrade Required` with `{ "min_protocol": 2 }`. The app pauses sync and shows "Update the app"; local data is untouched.

---

## 6. Conflict rules

Applied by the server when an incoming op's field HLC is older than or concurrent with the stored field HLC, or the record changed since `base_version`.

| Kind | Entities / fields | Rule |
| --- | --- | --- |
| Default | All fields not listed below | Field-level last-writer-wins by HLC |
| Append-only | `transactions`, `bill_payments`, `chore_completions`, `med_doses`, `fuel_logs`, `rent_payments`, `stock_movements`, `safety_checkins`, `activity_log` | Inserts only; updates allowed only to `note` and `deleted_at`. Never conflict |
| Counters | `pantry_items.quantity`, `medicines.stock`, `go_bag_items.quantity` | `increment` ops summed; absolute `update` of a counter is rejected (`not_counter`) |
| Forward-only status | `bills.is_paid`, `chores.is_done`, `grocery_items.is_bought` | `true` wins over `false`, unless the `false` has a newer HLC **and** the same `updated_by` as the `true` |
| Reviewed money | `budgets.limit_minor`, `bills.amount_minor`, `leases.rent_minor` | LWW, and the losing value is stored in `conflicts` for an Adult/Owner to confirm or revert |
| Delete vs edit | All | Delete wins unless the edit's HLC is newer than the delete's |
| Never auto-merged | `vault_items`, `vault_files`, `health_profiles` | Both versions kept; the newer is live, the older stored in `conflicts`; Owner chooses |

Tombstones are kept 90 days, then pruned by the nightly job.

---

## 7. Attachments

1. Device stores the file locally, named by SHA-256 of its (encrypted, for vault) bytes.
2. The `attachments` row syncs like any record (`sha256`, `size`, `mime`, `entity`, `entity_id`, `uploaded`=false).
3. Upload queue: `POST /api/files/{sha256}/chunks/{index}` with 1 MB chunks, then `POST /api/files/{sha256}/complete`. `HEAD /api/files/{sha256}` tells which chunks the server already has (resume).
4. Download: `GET /api/files/{sha256}` (auth-checked, served from object storage via a short-lived signed URL redirect).
5. Vault files are encrypted on the device (AES-256-GCM with the household vault key) before hashing and upload. The server only ever sees ciphertext.

---

## 8. Sync triggers (device)

- App open / resume
- Connectivity regained
- 3 s after a local write (debounced), if online
- Android: WorkManager every ~15 min; Web: every 3 min while a tab is open
- FCM data message `{"type":"pull"}` (Android)
- Pull-to-refresh

Backoff on failure: 5 s, 30 s, 2 min, 10 min (cap). Reset after a success.

---

## 9. Open items for v1

- [ ] Final list of counter fields once Pantry and Health schemas are written
- [ ] Bootstrap snapshot size limit and paging
- [ ] Change-log pruning rule (min cursor across active devices vs fixed 180 days)
