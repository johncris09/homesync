# Deploying HomeSync

| Part | Where | How it updates |
| --- | --- | --- |
| Sync hub (`api/`) | Hostinger shared hosting, e.g. `https://api.example.com` | `.github/workflows/deploy-api.yml` on every push to `main` that touches `api/` |
| Web app (`app/`) | Cloudflare Pages, e.g. `https://homesync.pages.dev` | `.github/workflows/deploy-web.yml` on every push to `main` that touches `app/` |
| Tests | GitHub Actions | `.github/workflows/ci.yml` on every pull request and push to `develop` |

Both deploy workflows run the tests first and use the GitHub environment **production**. Each can also be run by hand from the Actions tab (**Run workflow**).

Everything below is done once. Keep passwords, keys and tokens in hPanel, Cloudflare and GitHub secrets only. Never commit them.

---

## 1. Hostinger: the hub

You need a plan with **SSH access** (Premium or higher). PHP 8.2 or newer.

1. **Domain.** In hPanel, add a subdomain such as `api.example.com` and turn on its free SSL certificate.
2. **PHP version.** In hPanel go to **Advanced > PHP Configuration** and pick 8.2 or newer for that domain.
3. **Database.** In **Databases > Management**, create a MySQL database and user. Note the database name, user and password.
4. **SSH.**
   - In **Advanced > SSH Access**, turn SSH on and note the host, port (usually `65002`) and username.
   - Make a key just for deploys on your own computer:
     ```powershell
     ssh-keygen -t ed25519 -f homesync-deploy -C homesync-deploy -N '""'
     ```
   - Add `homesync-deploy.pub` under **SSH Access > SSH keys**.
5. **App folder.** Sign in over SSH and make a folder for the app outside the web root:
   ```sh
   mkdir -p ~/homesync-api
   ```
   Its full path (`echo ~/homesync-api`, e.g. `/home/u123456789/homesync-api`) is `HOSTINGER_APP_DIR`.
6. **Web root.** Point the subdomain at the app's `public/` folder.
   - Find the subdomain's folder (hPanel shows it, e.g. `~/domains/api.example.com/public_html`).
   - Replace that folder with a link to `public/`:
     ```sh
     rm -rf ~/domains/api.example.com/public_html
     ln -s ~/homesync-api/public ~/domains/api.example.com/public_html
     ```
7. **First upload.** Set up GitHub (section 3), then run **Deploy API (Hostinger)** from the Actions tab. It uploads the code. It fails at the migrate step because there is no `.env` yet; that is expected.
8. **Server `.env`.** Over SSH:
   ```sh
   cd ~/homesync-api
   cp .env.production.example .env
   nano .env        # APP_URL, DB_*, CORS_ALLOWED_ORIGINS
   php artisan key:generate
   php artisan migrate --force
   php artisan optimize
   php artisan up
   php artisan homesync:setup     # one time: the household and the owner's account
   ```
   - `CORS_ALLOWED_ORIGINS` is the Pages address from section 2, e.g. `https://homesync.pages.dev`.
   - If `php -v` shows an old version, use the full path instead, e.g. `/opt/alt/php82/usr/bin/php`, and set it as the `HOSTINGER_PHP` variable in GitHub.
9. **Cron.** In **Advanced > Cron Jobs**, add a job that runs every minute:
   ```
   /usr/bin/php /home/u123456789/homesync-api/artisan schedule:run
   ```
   Use the same PHP path as above. The scheduler drains the queue each minute (`routes/console.php`); nothing needs to run all the time.
10. **Check.** Open `https://api.example.com/up`. It should say the application is up.

Later deploys put the hub in maintenance mode (devices retry), upload the code (leaving `.env` and `storage/` alone), migrate, cache and bring it back up.

## 2. Cloudflare Pages: the web app

1. In the Cloudflare dashboard, go to **Workers & Pages > Create > Pages > Upload assets**. Create a project named, for example, `homesync`, with production branch `main`. Upload any placeholder file; the workflow replaces it. Its address is `https://<project>.pages.dev`; a custom domain can be added under the project's **Custom domains**.
2. **API token.** Under **My Profile > API Tokens > Create token**, choose **Custom token** with permission **Account > Cloudflare Pages > Edit** for your account.
3. **Account ID.** Copy it from **Workers & Pages** (right-hand side).

`app/web/_headers` (COOP/COEP, needed for offline storage) and `_redirects` (deep links) are part of the build.

## 3. GitHub: secrets and variables

Go to **Settings > Environments > New environment** and create `production`. You can require your approval before each deploy there. Then add:

| Kind | Name | Value |
| --- | --- | --- |
| Secret | `HOSTINGER_SSH_HOST` | SSH host from hPanel |
| Secret | `HOSTINGER_SSH_PORT` | SSH port, usually `65002` |
| Secret | `HOSTINGER_SSH_USER` | SSH username |
| Secret | `HOSTINGER_SSH_KEY` | Contents of the private key `homesync-deploy` |
| Secret | `HOSTINGER_KNOWN_HOSTS` | Output of `ssh-keyscan -p <port> <host>`, checked against hPanel |
| Variable | `HOSTINGER_APP_DIR` | e.g. `/home/u123456789/homesync-api` |
| Variable | `HOSTINGER_PHP` | Optional: PHP path if `php` is too old |
| Secret | `CLOUDFLARE_API_TOKEN` | Token from section 2 |
| Secret | `CLOUDFLARE_ACCOUNT_ID` | Account ID from section 2 |
| Variable | `CLOUDFLARE_PAGES_PROJECT` | Pages project name, e.g. `homesync` |
| Variable | `API_BASE_URL` | The hub address, e.g. `https://api.example.com` |

The web build stops if `API_BASE_URL` is missing or not `https://`.

## 4. Android

Release builds talk to the hub over HTTPS only:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

## Not covered yet

- Tombstone pruning after 90 days (`docs/sync-protocol.md` §6) has no scheduled job yet.
- Database backups: use Hostinger's backups. `mysqldump` may not be available to PHP.
