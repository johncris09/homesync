import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../network/dio_sync_api.dart';
import '../sync/sync_api.dart';

/// Chunk size for uploads (`file_chunk_bytes` on the hub).
const vaultChunkBytes = 1024 * 1024;

/// Largest file the hub accepts (`file_max_bytes`).
const vaultMaxFileBytes = 20 * 1024 * 1024;

/// Encrypted vault files on the hub (sync-protocol §7).
abstract interface class VaultFilesApi {
  /// Chunk indexes the hub already has, or null when the file is complete.
  Future<Set<int>?> status(String sha256);
  Future<void> putChunk(String sha256, int index, Uint8List bytes);
  Future<void> complete(String sha256, int chunks);

  /// The ciphertext, or null when the hub doesn't have it (yet).
  Future<Uint8List?> download(String sha256);
}

class DioVaultFilesApi implements VaultFilesApi {
  DioVaultFilesApi(this._dio, {required this.token});

  final Dio _dio;

  /// The main sign-in's token (the account that set up a shared tablet).
  final Future<String?> Function() token;

  Future<Options> _auth([Options? base]) async {
    final t = await token();
    if (t == null) throw const SignedOut();
    final o = base ?? Options();
    return o.copyWith(headers: {...?o.headers, 'Authorization': 'Bearer $t'});
  }

  @override
  Future<Set<int>?> status(String sha256) async {
    final res = await guardApi(
      () async => _dio.get<Map<String, Object?>>('/files/$sha256/chunks', options: await _auth()),
    );
    final data = res.data ?? const {};
    if (data['complete'] == true) return null;
    return {for (final i in (data['chunks'] as List? ?? const [])) (i as num).toInt()};
  }

  @override
  Future<void> putChunk(String sha256, int index, Uint8List bytes) => guardApi(
    () async => _dio.put<void>(
      '/files/$sha256/chunks/$index',
      data: bytes,
      options: await _auth(Options(contentType: 'application/octet-stream')),
    ),
  );

  @override
  Future<void> complete(String sha256, int chunks) => guardApi(
    () async => _dio.post<void>('/files/$sha256/complete', data: {'chunks': chunks}, options: await _auth()),
  );

  @override
  Future<Uint8List?> download(String sha256) async {
    try {
      final res = await _dio.get<List<int>>(
        '/files/$sha256',
        options: await _auth(Options(responseType: ResponseType.bytes)),
      );
      return Uint8List.fromList(res.data ?? const []);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      return guardApi<Uint8List?>(() => Future.error(e));
    }
  }
}

/// Uploads ciphertext this device holds that the hub doesn't have yet.
/// Runs after each sync; resumes from the chunks the hub already has.
class VaultUploader {
  VaultUploader(this.db, this.api);

  final AppDatabase db;
  final VaultFilesApi api;

  /// Returns how many files were uploaded.
  Future<int> uploadPending() async {
    final pending = await (db.select(db.vaultBlobs)..where((b) => b.needsUpload.equals(true))).get();
    var done = 0;
    for (final blob in pending) {
      final have = await api.status(blob.sha256);
      if (have != null) {
        final count = (blob.data.length / vaultChunkBytes).ceil();
        for (var i = 0; i < count; i++) {
          if (have.contains(i)) continue;
          final end = (i + 1) * vaultChunkBytes;
          await api.putChunk(
            blob.sha256,
            i,
            blob.data.sublist(i * vaultChunkBytes, end > blob.data.length ? blob.data.length : end),
          );
        }
        await api.complete(blob.sha256, count);
      }
      await (db.update(
        db.vaultBlobs,
      )..where((b) => b.sha256.equals(blob.sha256))).write(const VaultBlobsCompanion(needsUpload: Value(false)));
      done++;
    }
    return done;
  }
}
