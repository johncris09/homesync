import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the app database.
///
/// On Android the file is encrypted with SQLite3MultipleCiphers using
/// [encryptionKey] (kept in secure storage). The web build is not encrypted
/// yet: vault data is encrypted field-by-field before it reaches the database.
QueryExecutor openAppDatabase({required String encryptionKey}) {
  // Hex keys only, so the key can never break out of the pragma string.
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(encryptionKey)) {
    throw ArgumentError('encryptionKey must be 64 lowercase hex characters');
  }

  return driftDatabase(
    name: 'homesync',
    native: DriftNativeOptions(
      // The WorkManager task opens the database in another isolate.
      shareAcrossIsolates: true,
      setup: (db) {
        db.execute("PRAGMA key = '$encryptionKey';");
      },
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
