import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../core/vault/vault_crypto.dart';
import '../../core/vault/vault_files_api.dart';
import '../../core/vault/vault_session.dart';
import '../../shared/dates.dart';
import '../budget/budget_repository.dart' show derivedIdNamespace;

/// Kinds of document, in the order the list groups them.
const vaultKinds = ['id', 'certificate', 'property', 'contract', 'insurance', 'warranty', 'vehicle', 'pawn', 'other'];

/// Days before expiry that a document shows under "Renew soon".
const renewSoonDays = 60;

/// Shortest vault passphrase the app accepts.
const minPassphraseLength = 10;

/// The household's one `vault_keys` row (sync-protocol §2.1).
String vaultKeyId(String householdId) => const Uuid().v5(derivedIdNamespace, 'vault_keys/$householdId/household');

const _passphraseAad = 'homesync/vault_keys/passphrase_wrap';
const _recoveryAad = 'homesync/vault_keys/recovery_wrap';
String _itemAad(String id) => 'homesync/vault_items/$id/sealed';
String _fileKeyAad(String id) => 'homesync/vault_files/$id/key_wrap';
String _fileMetaAad(String id) => 'homesync/vault_files/$id/sealed';
String _fileAad(String id) => 'homesync/vault_files/$id';

/// What is sealed inside a document.
class VaultFields {
  const VaultFields({required this.title, this.number = '', this.issuer = '', this.issuedOn, this.note = ''});

  factory VaultFields.fromJson(Map<String, Object?> j) => VaultFields(
    title: j['title'] as String? ?? '',
    number: j['number'] as String? ?? '',
    issuer: j['issuer'] as String? ?? '',
    issuedOn: j['issued_on'] as String?,
    note: j['note'] as String? ?? '',
  );

  final String title;
  final String number;
  final String issuer;

  /// `YYYY-MM-DD`.
  final String? issuedOn;
  final String note;

  Map<String, Object?> toJson() => {
    'title': title,
    'number': number,
    'issuer': issuer,
    'issued_on': issuedOn,
    'note': note,
  };
}

/// A document opened with the vault key. [fields] is null when it can't be
/// read (sealed with another key, or damaged).
class VaultDoc {
  const VaultDoc(this.item, this.fields);

  final VaultItem item;
  final VaultFields? fields;

  String get title => fields?.title ?? '';
}

/// A file's sealed name and type.
class VaultFileMeta {
  const VaultFileMeta(this.file, {required this.name, required this.mime});

  final VaultFile file;
  final String name;
  final String mime;

  bool get isImage => mime.startsWith('image/');
}

/// Masks all but the last [visible] letters and digits: `P1234542B` → `P•••••42B`
/// keeps the first character when the number is long enough.
String maskNumber(String number, {int visible = 3}) {
  final n = number.trim();
  if (n.length <= visible) return n;
  // A leading letter (passport "P", license "N01") is not secret.
  final keepFirst = n.length >= 8 && RegExp('[A-Za-z]').hasMatch(n[0]);
  final buf = StringBuffer();
  for (var i = 0; i < n.length; i++) {
    final c = n[i];
    final shown = i >= n.length - visible || (keepFirst && i == 0) || !RegExp(r'[A-Za-z0-9]').hasMatch(c);
    buf.write(shown ? c : '•');
  }
  return buf.toString();
}

/// Document Vault (docs/vault.md): every secret is sealed with the household
/// vault key before it reaches [LocalWriter]; files are sealed with their own
/// key and kept as ciphertext in `vault_blobs` until the hub has them.
class VaultRepository {
  VaultRepository({
    required this.db,
    required this.writer,
    required this.session,
    required this.crypto,
    required this.files,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalWriter writer;
  final VaultSession session;
  final VaultCrypto crypto;
  final VaultFilesApi files;
  final DateTime Function() _now;
  static const _uuid = Uuid();

  DateTime get today {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  String get _household => writer.identity.householdId;

  Uint8List get _key {
    final k = session.key;
    if (k == null) throw StateError('the vault is locked');
    return k;
  }

  // ------------------------------------------------------------------ keys

  Stream<VaultKey?> watchKeyRow() => (db.select(
    db.vaultKeys,
  )..where((k) => k.id.equals(vaultKeyId(_household)) & k.deletedAt.isNull())).watchSingleOrNull();

  Future<VaultKey?> keyRow() => (db.select(
    db.vaultKeys,
  )..where((k) => k.id.equals(vaultKeyId(_household)) & k.deletedAt.isNull())).getSingleOrNull();

  /// First set-up by the owner: makes the vault key, wraps it with the
  /// passphrase and a new recovery code, and opens the vault. Returns the
  /// recovery code to show once.
  Future<RecoveryCode> setUp(String passphrase, {bool saveKey = false}) async {
    if (await keyRow() != null) throw StateError('the vault is already set up');
    final key = crypto.newKey();
    final code = RecoveryCode.random(crypto);
    await writer.insert('vault_keys', {
      ...await _passphraseFields(key, passphrase),
      ...await _recoveryFields(key, code),
      'created_by': writer.identity.memberId,
    }, id: vaultKeyId(_household));
    await session.open(key, saveFor: saveKey ? _household : null);
    return code;
  }

  /// False for a wrong passphrase.
  Future<bool> unlockWithPassphrase(String passphrase, {bool saveKey = false}) async {
    final row = await keyRow();
    if (row == null) return false;
    try {
      final kek = await crypto.passphraseKey(passphrase, base64.decode(row.kdfSalt), iterations: row.kdfIterations);
      final key = await crypto.unwrapKey(kek, row.passphraseWrap, _passphraseAad);
      await session.open(key, saveFor: saveKey ? _household : null);
      return true;
    } on VaultDecryptError {
      return false;
    }
  }

  /// False for a wrong or mistyped code. The caller then asks for a new
  /// passphrase ([changePassphrase]).
  Future<bool> unlockWithRecovery(String typed, {bool saveKey = false}) async {
    final code = RecoveryCode.tryParse(typed);
    final row = await keyRow();
    if (code == null || row == null) return false;
    try {
      final kek = await crypto.recoveryKey(code, base64.decode(row.recoverySalt));
      final key = await crypto.unwrapKey(kek, row.recoveryWrap, _recoveryAad);
      await session.open(key, saveFor: saveKey ? _household : null);
      return true;
    } on VaultDecryptError {
      return false;
    }
  }

  /// Owner, vault open: wraps the vault key with a new passphrase. Documents
  /// are not re-encrypted.
  Future<void> changePassphrase(String passphrase) async {
    await writer.update('vault_keys', vaultKeyId(_household), await _passphraseFields(_key, passphrase));
  }

  /// Owner, vault open: a new recovery code; the old one stops working.
  Future<RecoveryCode> newRecoveryCode() async {
    final code = RecoveryCode.random(crypto);
    await writer.update('vault_keys', vaultKeyId(_household), await _recoveryFields(_key, code));
    return code;
  }

  Future<Map<String, Object?>> _passphraseFields(Uint8List key, String passphrase) async {
    final salt = crypto.randomBytes(16);
    final kek = await crypto.passphraseKey(passphrase, salt);
    return {
      'passphrase_wrap': await crypto.wrapKey(kek, key, _passphraseAad),
      'kdf_salt': base64.encode(salt),
      'kdf_iterations': crypto.iterations,
    };
  }

  Future<Map<String, Object?>> _recoveryFields(Uint8List key, RecoveryCode code) async {
    final salt = crypto.randomBytes(16);
    final kek = await crypto.recoveryKey(code, salt);
    return {'recovery_wrap': await crypto.wrapKey(kek, key, _recoveryAad), 'recovery_salt': base64.encode(salt)};
  }

  // ------------------------------------------------------------- documents

  Stream<List<VaultItem>> watchItems() => (db.select(db.vaultItems)..where((i) => i.deletedAt.isNull())).watch();

  Stream<VaultItem?> watchItem(String id) =>
      (db.select(db.vaultItems)..where((i) => i.id.equals(id) & i.deletedAt.isNull())).watchSingleOrNull();

  /// Opens [items] with the vault key, sorted by title.
  Future<List<VaultDoc>> openAll(List<VaultItem> items) async {
    final docs = [for (final i in items) VaultDoc(i, await openFields(i.id, i.sealed))];
    docs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return docs;
  }

  /// [sealed] of document [id], or null if this key can't open it.
  Future<VaultFields?> openFields(String id, String sealed) async {
    try {
      final json = await crypto.openJson(_key, sealed, _itemAad(id));
      return json is Map ? VaultFields.fromJson(json.cast()) : null;
    } on VaultDecryptError {
      return null;
    }
  }

  /// Adds a document, or changes it when [id] is given. Returns its id.
  ///
  /// An edit sends only what changed: the vault is never auto-merged, so a
  /// field sent unchanged could clash with someone else's edit of it.
  Future<String> saveDoc({
    String? id,
    required String kind,
    String? memberId,
    String? expiresOn,
    required VaultFields fields,
  }) async {
    final docId = id ?? _uuid.v7();
    Future<String> seal() => crypto.sealJson(_key, fields.toJson(), _itemAad(docId));
    if (id == null) {
      await writer.insert('vault_items', {
        'kind': kind,
        'member_id': memberId,
        'expires_on': expiresOn,
        'sealed': await seal(),
        'created_by': writer.identity.memberId,
      }, id: docId);
      return docId;
    }
    final current = await (db.select(db.vaultItems)..where((i) => i.id.equals(id))).getSingle();
    final before = await openFields(id, current.sealed);
    await writer.update('vault_items', id, {
      if (current.kind != kind) 'kind': kind,
      if (current.memberId != memberId) 'member_id': memberId,
      if (current.expiresOn != expiresOn) 'expires_on': expiresOn,
      if (before == null || jsonEncode(before.toJson()) != jsonEncode(fields.toJson())) 'sealed': await seal(),
    });
    return docId;
  }

  Future<void> deleteDoc(String id) async {
    for (final f in await (db.select(db.vaultFiles)..where((f) => f.itemId.equals(id) & f.deletedAt.isNull())).get()) {
      await writer.delete('vault_files', f.id);
    }
    await writer.delete('vault_items', id);
  }

  /// Days until [item] expires (negative once expired), or null.
  int? daysLeft(VaultItem item) {
    final on = parseIsoDate(item.expiresOn);
    return on == null ? null : daysUntil(on, today);
  }

  bool renewSoon(VaultItem item) {
    final d = daysLeft(item);
    return d != null && d <= renewSoonDays;
  }

  // ----------------------------------------------------------------- files

  Stream<List<VaultFile>> watchFiles(String itemId) =>
      (db.select(db.vaultFiles)
            ..where((f) => f.itemId.equals(itemId) & f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.asc(f.position), (f) => OrderingTerm.asc(f.createdAt)]))
          .watch();

  Future<List<VaultFileMeta>> openMeta(List<VaultFile> rows) async => [
    for (final f in rows)
      await () async {
        try {
          final m = (await crypto.openJson(_key, f.sealed, _fileMetaAad(f.id)) as Map).cast<String, Object?>();
          return VaultFileMeta(f, name: m['name'] as String? ?? '', mime: m['mime'] as String? ?? '');
        } on VaultDecryptError {
          return VaultFileMeta(f, name: '', mime: '');
        }
      }(),
  ];

  /// Seals [bytes] with a new file key and keeps the ciphertext here until
  /// it is uploaded after the next sync.
  Future<String> addFile(String itemId, Uint8List bytes, {required String name, required String mime}) async {
    if (bytes.length > vaultMaxFileBytes) throw const VaultFileTooBig();
    final id = _uuid.v7();
    final fileKey = crypto.newKey();
    final cipher = await crypto.sealBytes(fileKey, bytes, _fileAad(id));
    final sha = await crypto.sha256Hex(cipher);
    await db
        .into(db.vaultBlobs)
        .insertOnConflictUpdate(VaultBlobsCompanion.insert(sha256: sha, data: cipher, needsUpload: const Value(true)));
    final existing = await (db.select(
      db.vaultFiles,
    )..where((f) => f.itemId.equals(itemId) & f.deletedAt.isNull())).get();
    await writer.insert('vault_files', {
      'item_id': itemId,
      'sha256': sha,
      'size': cipher.length,
      'key_wrap': await crypto.wrapKey(_key, fileKey, _fileKeyAad(id)),
      'sealed': await crypto.sealJson(_key, {'name': name, 'mime': mime}, _fileMetaAad(id)),
      'position': existing.length,
    }, id: id);
    return id;
  }

  /// The file's bytes, from this device or the hub. Null when the device that
  /// added it hasn't uploaded it yet. Throws [VaultDecryptError] if it can't
  /// be opened, and sync errors when the hub can't be reached.
  Future<Uint8List?> readFile(VaultFile f) async {
    var blob = await (db.select(db.vaultBlobs)..where((b) => b.sha256.equals(f.sha256))).getSingleOrNull();
    var cipher = blob?.data;
    if (cipher == null) {
      cipher = await files.download(f.sha256);
      if (cipher == null) return null;
      if (await crypto.sha256Hex(cipher) != f.sha256) throw const VaultDecryptError();
      await db.into(db.vaultBlobs).insertOnConflictUpdate(VaultBlobsCompanion.insert(sha256: f.sha256, data: cipher));
    }
    final fileKey = await crypto.unwrapKey(_key, f.keyWrap, _fileKeyAad(f.id));
    return crypto.openBytes(fileKey, cipher, _fileAad(f.id));
  }

  Future<void> removeFile(String id) => writer.delete('vault_files', id);
}

class VaultFileTooBig implements Exception {
  const VaultFileTooBig();
}
