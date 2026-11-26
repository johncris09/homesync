# Deploying HomeSync

| Part | Where | How it updates |
| --- | --- | --- |
| Sync hub (`api/`) | Hostinger shared hosting, e.g. `https://api.example.com` | `.github/workflows/release.yml` when a version tag such as `v1.0.0` is pushed on `main` |
| Web app (`app/`) | Cloudflare Pages, e.g. `https://homesync.pages.dev` | Same release, after the hub |
| Android app | GitHub Releases (signed APK) | Same release, after the hub |
| Tests | GitHub Actions | `.github/workflows/ci.yml` on every pull request and push to `develop` |

A release ships the whole system with one version (section 5). Each part runs its tests first and uses the GitHub environment **production**. Merging to `main` alone deploys nothing.

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
7. **First upload.** Set up GitHub (section 3), then make the first release (section 5). The hub job uploads the code and fails at the migrate step because there is no `.env` yet; that is expected. After step 8, rerun the release from the Actions tab (**Release > Run workflow**, on the tag).
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

Later releases put the hub in maintenance mode (devices retry), upload the code (leaving `.env` and `storage/` alone), migrate, cache and bring it back up.

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
| Secret | `ANDROID_KEYSTORE_BASE64` | The signing key file, base64 (section 4) |
| Secret | `ANDROID_KEYSTORE_PASSWORD` | The signing key's password (section 4) |
| Variable | `ANDROID_KEY_ALIAS` | Optional: key alias if not `upload` |

The web build stops if `API_BASE_URL` is missing or not `https://`.

## 4. Android

Release builds talk to the hub over HTTPS only.

### Signing key (once)

Android only installs an update signed with the same key as the installed app. If the key is lost, everyone must uninstall and reinstall, which deletes anything on their phone that has not synced yet. Make one key, keep it outside the repo, and back up the key file and its password (e.g. in a password manager).

1. Create the key. `keytool` comes with Android Studio's Java (`C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`):
   ```powershell
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v -keystore $HOME\.android\homesync-upload.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   It asks for a password and your name; the name is stored in the certificate.
2. Create `app/android/key.properties` (ignored by git):
   ```properties
   storeFile=C:/Users/<you>/.android/homesync-upload.jks
   storePassword=<the password>
   keyAlias=upload
   keyPassword=<the password>
   ```

Without `key.properties` the build falls back to the debug key. Such APKs can't update ones signed with the release key.

### Releases on GitHub

Each release (section 5) builds a signed APK in GitHub Actions and publishes it as a GitHub Release (`homesync-1.2.3.apk`), with notes listing the merged pull requests. Share the release page with the family.

Once, give GitHub the signing key (from `E:\homesync`, with the GitHub CLI signed in):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\.android\homesync-upload.jks")) | gh secret set ANDROID_KEYSTORE_BASE64
```
```powershell
gh secret set ANDROID_KEYSTORE_PASSWORD
```

The second command asks for the password, so it stays out of your shell history.

The release stops before publishing if a secret is missing or the APK came out signed with the debug key.

### Build on this PC

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

The APK is `app/build/app/outputs/flutter-apk/app-release.apk`. It shows "Version dev" and has the build number in `pubspec.yaml` (`1`), lower than any release, so it can't update a phone that has a release installed; use it only for testing. A phone with an APK signed by a different key (e.g. an earlier debug-key build) must uninstall it first; sync before uninstalling.

## 5. Releases

One version for the whole system, `MAJOR.MINOR.PATCH`: raise PATCH for fixes, MINOR for new features, MAJOR for big changes.

1. Merge `develop` into `main` (release pull request).
2. Tag `main` with the next version and push the tag:
   ```powershell
   git fetch origin; git tag v1.0.0 origin/main; git push origin v1.0.0
   ```
3. **Release** in the Actions tab runs:
   - **version**: checks the tag and that it is on `main`.
   - **hub**: tests, uploads to Hostinger with the version in `api/VERSION`, migrates.
   - then, only if the hub succeeded, **web** (tests, build, Cloudflare Pages) and **android** (tests, signed APK, GitHub Release), side by side.

What carries the version:

| Where | Shows |
| --- | --- |
| Home screen, at the bottom (web and Android) | `Version 1.2.3 · hub 1.2.3`: this app's version and the hub version it last heard from |
| Hub | Header `X-HomeSync-Version` on every API response (`config('homesync.version')`) |
| Android app info | versionName `1.2.3`, versionCode `10203` |
| GitHub | Tag `v1.2.3` and the release page |

The build number is worked out from the version (`1.2.3` is `10203`), so each release must have a higher version than the last, and MINOR and PATCH stay below 100.

The **sync protocol version** (`protocol` in `api/config/homesync.php`, `syncProtocolVersion` in the app) is separate: it changes only when older apps can no longer sync with the new hub (`docs/sync-protocol.md` §5.4).

To redeploy a release (for example after fixing a secret), open **Actions > Release > Run workflow** and pick its tag. The APK on an existing release is replaced.

## Not covered yet

- Tombstone pruning after 90 days (`docs/sync-protocol.md` §6) has no scheduled job yet.
- Database backups: use Hostinger's backups. `mysqldump` may not be available to PHP.
