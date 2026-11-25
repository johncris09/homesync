# HomeSync app (Flutter — Android + web)

## Generate the project (one time)

Run inside this `app/` folder, on a machine with Flutter installed:

```bash
flutter create . --project-name homesync --org com.johncris09 --platforms=android,web
```

`flutter create .` keeps this README and adds the Flutter files around it.

## Planned packages

| Purpose | Package |
| --- | --- |
| State management | `flutter_riverpod`, `riverpod_annotation` |
| Local database | `drift`, `drift_flutter`, `sqlite3_flutter_libs` (Android), `sqlcipher_flutter_libs` (Android) |
| Routing | `go_router` |
| HTTP | `dio` |
| Secure storage | `flutter_secure_storage` |
| Connectivity / background | `connectivity_plus`, `workmanager` (Android) |
| Notifications | `flutter_local_notifications`, `firebase_messaging` |
| Crypto | `cryptography` (AES-GCM, Argon2id) |
| IDs | `uuid` (v7) |
| Dev | `build_runner`, `drift_dev`, `riverpod_generator`, `flutter_lints` |

Web needs the Drift WASM files (`sqlite3.wasm`, `drift_worker.js`) in `web/` — see the Drift web setup guide.

## Folder structure

```
lib/
├── main.dart
├── app.dart                 # MaterialApp.router, theme
├── core/
│   ├── db/                  # Drift database, sync columns mixin, migrations
│   ├── sync/                # outbox, HLC, push/pull client, conflict apply, triggers
│   ├── auth/                # login, token storage, PIN / biometric lock
│   ├── crypto/              # vault key, AES-GCM, recovery code
│   ├── notifications/       # local reminders, FCM
│   └── network/             # dio client, connectivity
├── shared/                  # widgets, money (centavos), recurrence rules, attachments
└── features/
    └── <module>/
        ├── data/            # Drift tables, repository
        ├── domain/          # models, rules
        └── presentation/    # screens, Riverpod providers
```

Rule: features talk to each other only through repositories, never through screens.
