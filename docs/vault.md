# Document Vault — key handling

How the vault keeps IDs, certificates, titles, contracts, warranties and pawn tickets readable only by the household's adults. The hub and its backups hold ciphertext only. Sync rules are in `sync-protocol.md` (§2.1, §6, §7); this file covers the keys.

## Who can open it

Owner and adults (`read`/`write` in `api/config/homesync.php`). The hub never sends vault rows or files to teens, children, helpers or viewers. On the shared tablet only an adult profile sees the vault. Per-item visibility (owner-only documents) is not built yet.

## Crypto

All primitives come from the `cryptography` package (Web Crypto in the browser, its Dart implementation on Android). Nothing is hand-rolled.

| What | How |
| --- | --- |
| Vault key (VK) | 32 random bytes, made once by the owner when they set up the vault |
| Sealing | AES-256-GCM, a random 96-bit nonce each time. Stored as base64 of `0x01 ‖ nonce ‖ ciphertext ‖ tag`. The additional data is `homesync/<entity>/<id>/<field>`, so a sealed value can't be moved to another record or field |
| Passphrase key | PBKDF2-HMAC-SHA256, 600,000 iterations, 16-byte random salt → 32 bytes. Salt and iterations live in `vault_keys`, so the cost can go up later |
| Recovery code | 120 random bits shown as 24 Crockford base32 characters (`K7QM-3XRT-9WHD-PC2E-VN6A-YB4F`). Its key is HKDF-SHA256(code, `recovery_salt`, `homesync vault recovery`). The code is random and long, so it needs no slow hash |
| Documents | `vault_items.sealed` = JSON `{title, number, issuer, issued_on, note}` sealed with VK. `kind`, `member_id` and `expires_on` stay plain so reminders and the locked screen ("14 documents, 2 to renew") work without the key |
| Files | Each photo or PDF gets its own random 32-byte file key. The bytes are sealed with it, and `key_wrap` is that key sealed with VK. `sealed` holds the file name and type. A future key change only re-wraps keys and does not re-encrypt files |

PBKDF2 is used here, not Argon2id (which the plan named): the browser runs PBKDF2 natively through Web Crypto in under a second. Argon2id would run as compiled JavaScript there, too slowly at safe settings.

## The `vault_keys` row

There is one per household, with an id derived from `vault_keys/<household>/household` (§2.1). Only the owner writes it.

- `passphrase_wrap`: VK sealed with the passphrase key. `kdf_salt` and `kdf_iterations` go with it.
- `recovery_wrap`: VK sealed with the recovery key. `recovery_salt` goes with it.

The wraps are authenticated, so a wrong passphrase or code fails to decrypt. That is the check, and nothing else is stored to compare against.

## Setting up (owner)

1. The owner opens the vault before anyone has set it up. The app syncs first and won't continue offline. That way two devices can't each make a different key without noticing (if it happens anyway, the never-auto-merged rule keeps the other wraps in `conflicts`).
2. The owner chooses the household vault passphrase (at least 10 characters, typed twice).
3. The app shows the recovery code once. The owner writes it down or prints it, then types its last group to confirm. The app says plainly that if the passphrase and the code are both lost, the documents can't be recovered by anyone.
4. VK is made, wrapped twice, and the row is written through `LocalWriter`.

The owner tells the other adults the passphrase in person.

## Opening the vault

| Device | First time | After that |
| --- | --- | --- |
| Android phone with app lock on | Passphrase. VK is then kept in secure storage (Android Keystore) as `vault_key_<household>` | App PIN or fingerprint each time the vault opens |
| Android without app lock | Passphrase. VK is kept in memory only | Passphrase again after the app restarts. The vault suggests turning on app lock |
| Shared tablet | Passphrase, adult profiles only. VK in memory only | Locks when the profile changes or the app restarts |
| Web | Passphrase. VK in memory only, never in the browser's storage | Locked again when the tab closes, on sign-out, or with **Lock** |

Everyone gets a **Lock** button. Signing out removes the stored key.

## Losing access

- **A new phone, passphrase known:** type it once, and it works as above.
- **Passphrase forgotten (owner):** use **Use recovery code** on the locked screen. The app unwraps VK, then the owner must choose a new passphrase (re-wrapped, salt renewed). Other devices that already hold VK keep working, and other adults need the new passphrase on their next new device or browser session.
- **Change passphrase (owner, vault unlocked):** re-wraps VK. Documents are not re-encrypted.
- **New recovery code (owner, vault unlocked):** re-wraps VK with a new code, and the old one stops working.
- **Every device lost and both secrets lost:** the documents are gone. The hub can't help, by design.

## When an adult leaves

The owner removes the member, which revokes their sign-in, so the hub stops sending them anything. Then the owner changes the passphrase. A device that already held VK still has it, though, and so could read documents it had already downloaded. Making a new VK and re-wrapping every file key is a follow-up ("rotate vault key").

## Files on the hub

Shared hosting allows no symlinks, `exec()` or object storage, so files live on the hub's private disk (`storage/app/private/vault/<household>/<aa>/<sha256>`), named by the SHA-256 of their ciphertext:

1. When a document is saved, the app seals the file and stores the ciphertext locally (`vault_blobs`, flagged `needs_upload`). Then it writes the `vault_files` row.
2. After each sync, the app uploads pending blobs in 1 MiB chunks: `PUT /api/files/{sha256}/chunks/{i}` (raw bytes, so PHP's `upload_max_filesize` doesn't apply), then `POST /api/files/{sha256}/complete {chunks}`. The hub joins the chunks and keeps the file only if its SHA-256 matches. `GET /api/files/{sha256}/chunks` reports what it already has, so an interrupted upload resumes.
3. Other devices download a file when it is opened: `GET /api/files/{sha256}`, streamed by PHP after checking the role and that a live `vault_files` row in the household names it. They cache the ciphertext in `vault_blobs` and decrypt it in memory to show it.

The limit is 20 MB per file. Photos are scaled to at most 2400 px before sealing.
