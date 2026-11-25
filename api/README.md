# HomeSync API (Laravel — sync hub)

## Generate the project (one time)

Run from the repo root, on a machine with PHP 8.3+ and Composer:

```bash
composer create-project laravel/laravel api-tmp
cp -rn api-tmp/. api/ && rm -rf api-tmp
cd api && php artisan install:api   # adds Sanctum and routes/api.php
```

`composer create-project` needs an empty folder, so it goes to `api-tmp` first; `cp -n` keeps this README.

## Planned pieces

| Piece | Notes |
| --- | --- |
| Auth | Sanctum, one token per device; invite-only accounts |
| Sync | `POST /api/sync/push`, `GET /api/sync/pull`, `GET /api/sync/bootstrap` — see `../docs/sync-protocol.md` |
| Files | Chunked upload / resumable, S3-compatible disk |
| Push | FCM HTTP v1, sent inline after a push (no queue wait) |
| Database | MySQL 8 on Hostinger |
| Queue | `database` driver, drained by the scheduler |

## Cron on Hostinger (the only background process)

```
* * * * * cd ~/homesync/api && php artisan schedule:run >> /dev/null 2>&1
```

The scheduler runs `queue:work --stop-when-empty --max-time=50` every minute and the nightly pruning jobs.

## Shared-hosting notes

- `exec()` may be disabled: create the storage symlink manually instead of `php artisan storage:link`, and check before relying on `mysqldump` for backups.
- Point the subdomain's document root at `api/public`.

## CORS for the web app (Cloudflare Pages)

In `config/cors.php`: `paths` = `['api/*']`, `allowed_origins` = the Pages domain (e.g. `https://app.yourdomain.com`) plus `http://localhost:*` patterns for development, `supports_credentials` = `false` (auth uses bearer tokens, not cookies).
