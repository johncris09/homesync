# Decisions

Newest first. Each entry: what was decided, and what it changes in the build.

| Date | Decision | Effect |
| --- | --- | --- |
| 2026-11-25 | `conflicts` is a synced, server-created entity (adults read/resolve) | Conflict Inbox works offline from synced rows; revert = an ordinary newer update of the field, then mark resolved; protocol §6.1 |
| 2026-11-25 | Shared tablet: each PIN profile pushes with its own token; the tablet pulls with the account that set it up | The outbox records `member_id`/`device_id` per op; a profile first used offline keeps its ops queued until its token is fetched; what each profile may see on the tablet is limited in the app by role |
| 2026-11-25 | Members' `pin_hash` is bcrypt `$2y$` cost 10, written by the app | Same hash checked offline on the tablet and by Laravel `Hash::check` on `/auth/pin`; ~80 ms per check |
| 2026-11-25 | App database: SQLite3MultipleCiphers (`sqlite3` hook `source: sqlite3mc`) instead of `sqlcipher_flutter_libs` (end-of-life) | Android database encrypted with `PRAGMA key` (key in secure storage); the same engine has a WASM build, so web encryption can be added later without changing engines; web database is unencrypted for now (vault fields are encrypted on their own) |
| 2026-11-25 | Add Debts & Loans module (loans, credit cards, prenda tickets, money lent) and a Subscriptions tab in Bills | 14 modules; payments are append-only and post to the expense ledger; prenda ticket photos go to the Vault; Debts & Loans ships in Phase 2, Subscriptions in Phase 1 |
| 2026-11-25 | Web app on Cloudflare Pages, API on Hostinger (`app.` and `api.` subdomains) | CORS limited to the Pages origin; Sanctum bearer tokens (no cookies); GitHub Actions builds Flutter web and runs `wrangler pages deploy`; `_headers` (COOP/COEP) and `_redirects` in `app/web/` |
| 2026-11-25 | Shared household tablet with PIN profiles for kids and helpers | Built in Phase 0 with auth and roles |
| 2026-11-25 | UI language: English for now | Strings still go through Flutter localization (ARB) files so Filipino can be added later |
| 2026-11-25 | App name: HomeSync | Package id `com.johncris09.homesync` |
| 2026-11-25 | One repo (`app/`, `api/`, `docs/`) | Protocol changes land in app and API in the same pull request |
| 2026-11-25 | Platforms: Android and web (Flutter for both); no iOS for now | Flutter project created with `--platforms=android,web`; web uses Drift on SQLite WASM (OPFS) |
| 2026-11-25 | Hosting: Hostinger shared hosting only; background jobs via cron | One cron entry runs `schedule:run` every minute; database queue drained with `queue:work --stop-when-empty`; no websockets |
| 2026-11-25 | Document vault: strong end-to-end encryption | AES-256-GCM on device; server stores ciphertext only; owner recovery code; on web the key is derived from a vault passphrase each session |
| 2026-11-25 | Audience: this household only | No public sign-up, subscriptions or store listing; owner invites members |
| 2026-11-25 | Offline-first with outbox + push/pull sync, HLC-based conflict rules | See `sync-protocol.md` |
| 2026-11-26 | Members are managed by the owner in the app; the owner role is not assignable there | Household members screen (owner only, matches `members.write = ['owner']`): add/edit name, role (adult/teen/child/helper/viewer), colour as `#RRGGBB`; set/change/remove tablet PIN (entered twice); remove = soft delete; the owner can't remove themself or change their own role |
