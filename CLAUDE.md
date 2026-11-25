# HomeSync — notes for Claude

Offline-first household management app for **one household** (the owner's own family). Every member records data on their own device without internet; changes sync when a connection returns.

- Plan doc: https://claude.ai/artifact/TEisk7tpv4UUWMfarzkiGD
- Design canvas (all screens): https://claude.ai/artifact/PEDRNvy7baEfxNF5gfbkcx
- Sync contract: `docs/sync-protocol.md` — read it before touching sync code on either side
- Decisions log: `docs/decisions.md` — add a row for every new decision

## Working rules (from the owner)

- **Never work on `main`.** `main` is releasable; `develop` collects finished features.
- **One branch per unit of work**, off `develop` (or off the current feature branch when it depends on it): `feature/<name>`, `fix/<name>`.
- **Always commit your work**, small and often, with clear messages. Push the branch when a piece is done.
- Schema or protocol change → update `docs/sync-protocol.md` and `api/config/homesync.php` in the same commit as the code.
- English UI for now, but all user-facing strings go through Flutter localization (ARB) so Filipino can be added later.

## Repository layout

| Folder | What | Stack |
| --- | --- | --- |
| `app/` | Mobile + web app | Flutter (Android and web only, no iOS), Riverpod, Drift (SQLite; SQLCipher on Android, WASM/OPFS on web), go_router, dio |
| `api/` | Sync hub | Laravel 12, Sanctum, MySQL 8 (SQLite in tests) |
| `docs/` | Contract and decisions | Markdown |

## Commands

```bash
# API (from api/)
php artisan migrate
php artisan homesync:setup        # one-time: household + owner account
php artisan test                  # must stay green
./vendor/bin/pint                 # format before committing

# App (from app/)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift / Riverpod codegen
flutter test
flutter run -d chrome             # or an Android device/emulator
```

## Architecture in one paragraph

The UI reads and writes only the local Drift database. Every local write updates the row **and** appends an op to an outbox in one transaction. Sync = push the outbox (`POST /api/sync/push`, ≤200 ops, idempotent by `op_id`), then pull changes since a cursor (`GET /api/sync/pull`). IDs are UUIDv7 made on the device. Conflicts are resolved per field by a hybrid logical clock (HLC) with special rules: append-only ledgers, counters as increments, forward-only "done/paid/bought", reviewed money changes go to a conflict inbox, delete vs edit by newest HLC. Vault files and sensitive fields are encrypted on the device (AES-256-GCM); the server stores ciphertext only.

## Status

| Area | State |
| --- | --- |
| Plan, design, decisions | Done |
| Repo scaffold (Flutter + Laravel generated) | Done — `feature/repo-scaffold` |
| API sync engine: push/pull/bootstrap, all conflict rules, device tokens, email + PIN login, protocol check, setup command, 28 tests | Done — `feature/sync-core` |
| **App sync engine** — core (steps 1–5, 9) | Done — `feature/app-sync-core`: Drift DB (sqlite3mc), HLC, outbox writer, sync engine, Dio transport, scheduler with backoff, 3-device convergence test (68 tests) |
| **App sync engine** — triggers wiring, auth, sync UI (steps 6–8) | **Next** |
| Phase 1 modules (Budget, Bills & Subscriptions, Chores, Calendar, Pantry & Grocery) | Not started |

### Next: app side of Phase 0 (`feature/app-sync-core`)

Steps 1–5 and 9 are done (see `app/lib/core/sync/`, `app/test/core/sync/`). Notes for what's left:
- Features write synced data only through `LocalWriter` (wire field names, Dart values); `EntitySpec` in `core/sync/entities.dart` mirrors `api/config/homesync.php` — keep both in step.
- `SyncScheduler` already does debounce, periodic and backoff; step 6 is wiring it to app resume (`AppLifecycleListener`), `connectivity_plus` and WorkManager (needs the token from step 7).
- Web needs `sqlite3.wasm` + `drift_worker.js` in `app/web/` before the DB opens in the browser.


1. Add packages from `app/README.md` (drift, drift_flutter, sqlcipher_flutter_libs, flutter_riverpod, go_router, dio, flutter_secure_storage, connectivity_plus, workmanager, cryptography, uuid, flutter_local_notifications).
2. `core/db`: Drift database with a sync-columns mixin (`id, household_id, created_at, updated_at, deleted_at, hlc, server_version, updated_by, device_id`), an `outbox` table, a `field_clocks` table, a `sync_state` table (cursor, last synced) and a `sync_errors` table. Start with the same reference tables as the API: `members`, `grocery_items`, `pantry_items`, `bills`, `transactions`.
3. `core/sync/hlc.dart`: format `<13-digit ms>-<4 hex counter>-<8 hex node>`; tick on local change, merge on remote, keep the max server time seen. Unit-test ordering and a wrong phone clock.
4. `core/sync/outbox.dart`: write row + op in one transaction; merge repeated edits to one record into one op; counters as summed increments.
5. `core/sync/sync_client.dart`: push batches, then pull pages, apply pulled rows in one transaction per page, store the cursor; handle `applied/duplicate/merged/rejected`, 426 → "Update the app", backoff 5 s → 30 s → 2 min → 10 min.
6. Triggers: app start/resume, connectivity regained, 3 s after a local write, WorkManager every ~15 min on Android, every 3 min on web while open.
7. Auth: email login (store token in secure storage), shared-tablet PIN profiles (verify PIN against synced `pin_hash` offline, one token per profile), app lock with PIN/biometrics.
8. Sync status UI: per-record pending/conflict marker, "Last synced …" header, Conflict Inbox.
9. Tests: a simulated two-device test (two in-memory databases + a fake server) that edits offline, syncs in random order and converges.

## Design system (from the design canvas)

Grounded in a Filipino home, not a generic app kit. One family: **Bricolage Grotesque** (heavy, 75% width for big figures; normal width elsewhere).

| Name | Hex | Use |
| --- | --- | --- |
| Capiz | `#E9EEE7` | Background |
| Narra | `#2A1E17` | Text, primary buttons, bottom bar (instead of black) |
| Dahon | `#2F6B3A` | Money, home, done |
| Mangga | `#F2B630` | Due soon, active tab marker, FAB |
| Dagat | `#2B5C8A` | Chores, health, vehicles |
| Ube | `#5B3F7A` | Calendar, inventory |
| Gumamela | `#C2332B` | Emergencies and overdue only |

Each module screen opens with a solid colour header holding one large figure (e.g. "₱11,550 left") and a one-line caption. Sentence-case section headings (no all-caps labels), round icons, cards `#FBFCF8` radius 18, no borders. No woven/checkered band (removed by the owner).

## Hosting constraints

- API on **Hostinger shared hosting**: no long-running workers. One cron entry runs `php artisan schedule:run` every minute; the database queue is drained with `queue:work --stop-when-empty`. `exec()` may be disabled — don't rely on `storage:link` or `mysqldump`.
- Web app on **Cloudflare Pages**, built in GitHub Actions (`flutter build web` + `wrangler pages deploy`). Needs `_redirects` and `_headers` (COOP/COEP) in `app/web/`. API CORS allows only the Pages origin; auth is bearer tokens, never cookies.
