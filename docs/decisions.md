# Decisions

Newest first. Each entry: what was decided, and what it changes in the build.

| Date | Decision | Effect |
| --- | --- | --- |
| 2026-11-25 | One repo (`app/`, `api/`, `docs/`) | Protocol changes land in app and API in the same pull request |
| 2026-11-25 | Platforms: Android and web (Flutter for both); no iOS for now | Flutter project created with `--platforms=android,web`; web uses Drift on SQLite WASM (OPFS) |
| 2026-11-25 | Hosting: Hostinger shared hosting only; background jobs via cron | One cron entry runs `schedule:run` every minute; database queue drained with `queue:work --stop-when-empty`; no websockets |
| 2026-11-25 | Document vault: strong end-to-end encryption | AES-256-GCM on device; server stores ciphertext only; owner recovery code; on web the key is derived from a vault passphrase each session |
| 2026-11-25 | Audience: this household only | No public sign-up, subscriptions or store listing; owner invites members |
| 2026-11-25 | Offline-first with outbox + push/pull sync, HLC-based conflict rules | See `sync-protocol.md` |

## Still open

- Shared household tablet with PIN profiles (Phase 0 or later)
- UI language: English only, or English + Filipino
- Subdomain for API and web app
- Final app name
