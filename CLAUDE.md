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
| **App sync engine** (steps 1–9) | Done — `feature/app-sync-core`: Drift DB (sqlite3mc), HLC, outbox (per-profile), sync engine, triggers + WorkManager, email/PIN-profile auth, app lock, synced conflicts + Conflict Inbox, sync status UI, owner Household members screen (add/edit/remove, set tablet PIN), bootstrap snapshot on first sync; 103 app tests, 30 API tests |
| Phase 0 leftovers | **Next**: test against a real hub (setup → sign in → add members/PINs → tablet profiles → two-device sync) |
| Phase 1 modules (Budget, Bills & Subscriptions, Chores, Calendar, Pantry & Grocery) | Not started |

### Phase 0 app notes (`feature/app-sync-core`)

- Features write synced data only through `LocalWriter` (`ref.read(servicesProvider).writer`; wire field names, Dart values). `EntitySpec` in `core/sync/entities.dart` mirrors `api/config/homesync.php` — keep both in step.
- Show `SyncMarker(entity:, id:)` next to records in module lists (pending / needs review).
- Shared tablet: each PIN profile is its own device + token; outbox ops carry `member_id`/`device_id` and push with that token; the tablet pulls with the account that set it up. Limit what each profile sees by `session.active.role` in module screens.
- `pin_hash` is written by the app with `hashPin()` (bcrypt `$2y$`, cost 10) when the owner sets a member's PIN.
- Widget tests that use Drift streams must end with `finish(tester, services)` (see `test/app_test.dart`), or a pending timer fails the test.
- `app/web/sqlite3.wasm` and `drift_worker.js` come from the `drift-2.34.4` GitHub release; replace both together whenever `drift` is upgraded. Web storage runs on OPFS when served with the `_headers` COOP/COEP.
- Font: Bricolage Grotesque variable font in `app/assets/fonts/` (OFL, licence registered at startup). Use `fontVariations` (`FontVariation.weight` / `.width(75)` for big figures), not just `fontWeight`.

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
