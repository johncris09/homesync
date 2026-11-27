import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../auth/secure_store.dart';

/// Holds the household vault key while the vault is open (docs/vault.md).
///
/// The key lives in memory. On an Android phone with app lock on it is also
/// kept in secure storage, so later opens need only the app PIN or a
/// fingerprint; on web, shared tablets and phones without app lock it is
/// never stored, and the passphrase is asked again after a restart.
class VaultSession extends ChangeNotifier {
  VaultSession({required this.store});

  final SecureStore store;
  Uint8List? _key;

  /// The vault key, or null while locked.
  Uint8List? get key => _key;
  bool get unlocked => _key != null;

  static String _storeKey(String householdId) => 'vault_key_$householdId';

  Future<bool> hasSavedKey(String householdId) async => await store.read(_storeKey(householdId)) != null;

  /// Opens with the key kept on this device. Call only after the app PIN or
  /// fingerprint was checked. False when there is no saved key.
  Future<bool> openSaved(String householdId) async {
    final saved = await store.read(_storeKey(householdId));
    if (saved == null) return false;
    _key = base64.decode(saved);
    notifyListeners();
    return true;
  }

  /// Opens with [key]; [saveFor] keeps it on this device for that household.
  Future<void> open(Uint8List key, {String? saveFor}) async {
    _key = Uint8List.fromList(key);
    if (saveFor != null) await store.write(_storeKey(saveFor), base64.encode(key));
    notifyListeners();
  }

  void lock() {
    if (_key == null) return;
    _key!.fillRange(0, _key!.length, 0);
    _key = null;
    notifyListeners();
  }

  /// Locks and removes the saved key (sign-out, app lock turned off).
  Future<void> forget(String householdId) async {
    lock();
    await store.delete(_storeKey(householdId));
  }
}
