# Decisions

Newest first. Each entry: what was decided, and what it changes in the build.

| Date | Decision | Effect |
| --- | --- | --- |
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
