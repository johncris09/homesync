import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// Vault encryption (docs/vault.md). Every primitive comes from the
/// `cryptography` package: Web Crypto in the browser, its Dart
/// implementation on Android and in tests.
///
/// A sealed value is `0x01 ‖ nonce(12) ‖ ciphertext ‖ tag(16)`, AES-256-GCM,
/// with additional data naming where it belongs, so it can't be moved to
/// another record or field.
class VaultCrypto {
  VaultCrypto({this.iterations = defaultIterations, Random? random}) : _random = random ?? Random.secure();

  /// PBKDF2-HMAC-SHA256 cost for new passphrase wraps.
  static const defaultIterations = 600000;
  static const _version = 1;
  static const _nonceLength = 12;
  static const _tagLength = 16;
  static const _recoveryInfo = 'homesync vault recovery';

  final int iterations;
  final Random _random;
  final _aes = AesGcm.with256bits();

  Uint8List randomBytes(int n) => Uint8List.fromList(List.generate(n, (_) => _random.nextInt(256)));

  /// A new 256-bit key (the vault key, or a file key).
  Uint8List newKey() => randomBytes(32);

  // ------------------------------------------------------------- sealing

  Future<Uint8List> sealBytes(List<int> key, List<int> clear, String aad) async {
    final box = await _aes.encrypt(
      clear,
      secretKey: SecretKey(key),
      nonce: randomBytes(_nonceLength),
      aad: utf8.encode(aad),
    );
    return Uint8List.fromList([_version, ...box.nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  /// Throws [VaultDecryptError] for a wrong key, wrong [aad] or tampering.
  Future<Uint8List> openBytes(List<int> key, List<int> sealed, String aad) async {
    if (sealed.length < 1 + _nonceLength + _tagLength || sealed[0] != _version) {
      throw const VaultDecryptError();
    }
    final box = SecretBox(
      sealed.sublist(1 + _nonceLength, sealed.length - _tagLength),
      nonce: sealed.sublist(1, 1 + _nonceLength),
      mac: Mac(sealed.sublist(sealed.length - _tagLength)),
    );
    try {
      return Uint8List.fromList(await _aes.decrypt(box, secretKey: SecretKey(key), aad: utf8.encode(aad)));
    } on SecretBoxAuthenticationError {
      throw const VaultDecryptError();
    }
  }

  /// Seals [value] as JSON and returns base64 text for a synced field.
  Future<String> sealJson(List<int> key, Object? value, String aad) async =>
      base64.encode(await sealBytes(key, utf8.encode(jsonEncode(value)), aad));

  Future<Object?> openJson(List<int> key, String sealed, String aad) async {
    final Uint8List bytes;
    try {
      bytes = base64.decode(sealed);
    } on FormatException {
      throw const VaultDecryptError();
    }
    return jsonDecode(utf8.decode(await openBytes(key, bytes, aad)));
  }

  Future<String> wrapKey(List<int> kek, List<int> key, String aad) async =>
      base64.encode(await sealBytes(kek, key, aad));

  Future<Uint8List> unwrapKey(List<int> kek, String wrapped, String aad) async {
    try {
      return openBytes(kek, base64.decode(wrapped), aad);
    } on FormatException {
      throw const VaultDecryptError();
    }
  }

  // ---------------------------------------------------------- key derivation

  /// Key from the household vault passphrase.
  ///
  /// Slow on purpose. On Android it runs in a background isolate so the
  /// screen keeps moving; the browser runs it natively through Web Crypto.
  Future<Uint8List> passphraseKey(String passphrase, List<int> salt, {int? iterations}) {
    final args = (passphrase.trim(), Uint8List.fromList(salt), iterations ?? this.iterations);
    return !kIsWeb && args.$3 >= 100000 ? compute(_pbkdf2, args) : _pbkdf2(args);
  }

  /// Key from a recovery code (random and long, so HKDF is enough).
  Future<Uint8List> recoveryKey(RecoveryCode code, List<int> salt) async {
    final kdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final key = await kdf.deriveKey(secretKey: SecretKey(code.bytes), nonce: salt, info: utf8.encode(_recoveryInfo));
    return Uint8List.fromList(await key.extractBytes());
  }

  Future<String> sha256Hex(List<int> bytes) async {
    final hash = await Sha256().hash(bytes);
    return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

Future<Uint8List> _pbkdf2((String, Uint8List, int) args) async {
  final (passphrase, salt, iterations) = args;
  final kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
  final key = await kdf.deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);
  return Uint8List.fromList(await key.extractBytes());
}

/// Wrong key, wrong passphrase, or data that was changed.
class VaultDecryptError implements Exception {
  const VaultDecryptError();
  @override
  String toString() => 'VaultDecryptError';
}

/// 120 random bits written as 24 Crockford base32 characters in groups of
/// four: `K7QM-3XRT-9WHD-PC2E-VN6A-YB4F`.
class RecoveryCode {
  RecoveryCode._(this.bytes);

  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static const length = 24;

  /// 15 bytes.
  final Uint8List bytes;

  factory RecoveryCode.random(VaultCrypto crypto) => RecoveryCode._(crypto.randomBytes(15));

  /// Reads a typed code: any case, spaces and dashes ignored, O read as 0
  /// and I/L as 1. Null when it isn't a whole code.
  static RecoveryCode? tryParse(String text) {
    final chars = text
        .toUpperCase()
        .replaceAll(RegExp(r'[\s-]'), '')
        .replaceAll('O', '0')
        .replaceAll(RegExp('[IL]'), '1');
    if (chars.length != length) return null;
    var acc = BigInt.zero;
    for (final c in chars.split('')) {
      final v = _alphabet.indexOf(c);
      if (v < 0) return null;
      acc = (acc << 5) | BigInt.from(v);
    }
    final out = Uint8List(15);
    for (var i = 14; i >= 0; i--) {
      out[i] = (acc & BigInt.from(0xff)).toInt();
      acc >>= 8;
    }
    return RecoveryCode._(out);
  }

  /// Groups of four joined by dashes.
  String get text {
    var acc = BigInt.zero;
    for (final b in bytes) {
      acc = (acc << 8) | BigInt.from(b);
    }
    final chars = List.filled(length, '');
    for (var i = length - 1; i >= 0; i--) {
      chars[i] = _alphabet[(acc & BigInt.from(31)).toInt()];
      acc >>= 5;
    }
    return [for (var i = 0; i < length; i += 4) chars.sublist(i, i + 4).join()].join('-');
  }

  /// The last group, typed back to confirm the code was kept.
  String get lastGroup => text.substring(text.length - 4);
}
