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

# Android emulator against a local hub (php artisan serve on :8000)
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Debug builds allow plain HTTP (`android/app/src/debug/AndroidManifest.xml`) so they can reach a local hub; release builds are HTTPS-only.

## Architecture in one paragraph

The UI reads and writes only the local Drift database. Every local write updates the row **and** appends an op to an outbox in one transaction. Sync = push the outbox (`POST /api/sync/push`, ≤200 ops, idempotent by `op_id`), then pull changes since a cursor (`GET /api/sync/pull`). IDs are UUIDv7 made on the device. Conflicts are resolved per field by a hybrid logical clock (HLC) with special rules: append-only ledgers, counters as increments, forward-only "done/paid/bought", reviewed money changes go to a conflict inbox, delete vs edit by newest HLC. Vault files and sensitive fields are encrypted on the device (AES-256-GCM); the server stores ciphertext only.

## Status

| Area | State |
| --- | --- |
| Plan, design, decisions | Done |
| Repo scaffold (Flutter + Laravel generated) | Done — `feature/repo-scaffold` |
| API sync engine: push/pull/bootstrap, all conflict rules, device tokens, email + PIN login, protocol check, setup command, 28 tests | Done — `feature/sync-core` |
| **App sync engine** (steps 1–9) | Done — `feature/app-sync-core`: Drift DB (sqlite3mc), HLC, outbox (per-profile), sync engine, triggers + WorkManager, email/PIN-profile auth, app lock, synced conflicts + Conflict Inbox, sync status UI, owner Household members screen (add/edit/remove, set tablet PIN), bootstrap snapshot on first sync, tablet PIN for the setup person; 107 app tests, 30 API tests |
| Phase 0 real-hub test | Done (web + Android emulator); merged to `develop` (PR #1) |
| Phase 1: Pantry & Grocery | Done — `feature/pantry-grocery`: grocery list (quick add, bought, clear) and pantry (stock +/-, stock-take, running low, expiry, add to list); tested on web + emulator against a local hub; 124 app tests |
| Phase 1: Budget | Done — `feature/budget`: `budgets` entity (derived id per category, reviewed limit), ledger entries (append-only), month view with category progress, money in/out; non-adults record and see only their own; 139 app tests, 33 API tests |
| Phase 1: Bills & Subscriptions | Done — `feature/bills`: bills (one row per due date, monthly series, pay with the actual amount, undo by the payer), subscriptions (monthly/yearly, pay moves the date on); payments post to the ledger (`source_type` `bill`/`subscription`) with derived ids; adults only; 153 app tests, 35 API tests |
| Phase 1: Chores | Done — `feature/chores`: chores (daily, weekly on a day, once on a date; assigned or anyone; adults manage), today's list + coming up, tick off by whoever did it (`chore_completions`, append-only; undo by the doer); everyone but viewers ticks; 162 app tests, 36 API tests |
| Phase 1: Calendar | Done — `feature/calendar`: events (all day or timed; once, weekly, monthly, yearly), month view with dots, the picked day and coming up; adults also see bills and subscriptions due; everyone but viewers adds, non-adults change only their own; 172 app tests, 37 API tests |
| Deployment | Ready — `feature/deploy`: CI, Hostinger and Cloudflare Pages workflows, CORS by origin, scheduler, `docs/deploy.md`; live at Cloudflare Pages and Hostinger |
| Releases | Ready — `feature/android-release`: one version for the whole system; a `v1.2.3` tag on `main` runs `release.yml` (hub, then web + signed APK on a GitHub Release); Home shows app and hub versions (`X-HomeSync-Version`); APKs signed with the upload key (`android/key.properties`) |
| Phase 2: Debts & Loans | Done — `feature/debts-loans`: one `debts` table (loan, card, pawn ticket, money lent) and append-only `debt_payments` (payment, interest, charge); balance worked out on the device; payments on what the household owes post to the ledger (category `debt`); monthly due dates move on when paid; paid off at zero, reopen by the closer; adults only; 190 app tests, 42 API tests |
| Calendar: multi-day events and colours | Done — `feature/calendar-date-range`: `events.ends_on` (app schema 9); Several days switch + Until in the event sheet, Ube band in the month view, each day in the picked-day list, coming up once with its range; a repeat copies the span (weekly ≤ 7 days, monthly ≤ 28, yearly ≤ 365); timed ranges start on the first day and end on the last; event colours (`events.color`, schema 10): colour row in the sheet, paints icon, dots and band; overlapping ranges stack as thin bands (up to 3, then +); 205 app tests, 42 API tests |

### Phase 0 app notes (`feature/app-sync-core`)

- Features write synced data only through `LocalWriter` (`ref.read(servicesProvider).writer`; wire field names, Dart values). `EntitySpec` in `core/sync/entities.dart` mirrors `api/config/homesync.php` — keep both in step.
- Show `SyncMarker(entity:, id:)` next to records in module lists (pending / needs review).
- Shared tablet: each PIN profile is its own device + token; outbox ops carry `member_id`/`device_id` and push with that token; the tablet pulls with the account that set it up. Limit what each profile sees by `session.active.role` in module screens.
- `pin_hash` is written by the app with `hashPin()` (bcrypt `$2y$`, cost 10) when the owner sets a member's PIN.
- Shared tablet: the setup person picks a tablet PIN right after sign-in (`TabletPinScreen`, router guard `auth.needsTabletPin`); kept on the device as `tablet_main_pin_hash`, and synced as the owner's `pin_hash` when they are the owner.
- New installs bootstrap from `/sync/bootstrap` while the cursor is 0.
- New synced table: migration + `config/homesync.php` (API), table in `tables.dart` + `onUpgrade` step with a `schemaVersion` bump + `entities.dart` (app), `dart run build_runner build`, and `docs/sync-protocol.md`. One row per natural key → derived id (protocol §2.1, `budgetId()`).
- Money: integer centavos; `shared/money.dart` (`formatPeso`, `parsePeso`). Ledger sign: expenses negative, income positive.
- Modules that pay for something post a ledger entry with `source_type`/`source_id` and a derived id (see `features/bills/bills_repository.dart`), so a payment made on two devices offline is recorded once (the hub keeps the first insert of an append-only record). Calendar dates: `shared/dates.dart`; bottom sheets: `shared/sheet_body.dart`.
- Module pattern (see `features/pantry/`): a repository over the local DB + `LocalWriter`, providers, one screen with a solid header figure. Counters change only through `increment` (a stock-take sends the difference). Hide edit controls for roles not in the entity's `write` list. Use one-off `.get()` queries inside actions, not `watch().first`. Don't wrap `LocalWriter` calls in `db.transaction` (each is its own transaction; nesting hung on web while native tests passed).
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

Setup and releases: `docs/deploy.md` (a version tag on `main` releases hub, web and APK together; merging alone deploys nothing; CI runs tests on PRs). Android and web only — no Windows or iOS app.


- API on **Hostinger shared hosting**: no long-running workers. One cron entry runs `php artisan schedule:run` every minute; the database queue is drained with `queue:work --stop-when-empty`. `exec()` may be disabled — don't rely on `storage:link` or `mysqldump`.
- Web app on **Cloudflare Pages**, built in GitHub Actions (`flutter build web` + `wrangler pages deploy`). Needs `_redirects` and `_headers` (COOP/COEP) in `app/web/`. API CORS allows only the Pages origin; auth is bearer tokens, never cookies.
