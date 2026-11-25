import 'package:dio/dio.dart';

import '../sync/sync_api.dart';

/// Base URL of the sync hub, set at build time:
/// `--dart-define=API_BASE_URL=https://api.example.com`.
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');

/// Dio client with the protocol header and the device's bearer token.
Dio createApiClient({required Future<String?> Function() token, String baseUrl = apiBaseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'X-HomeSync-Protocol': '$syncProtocolVersion',
      },
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final t = await token();
        if (t != null) options.headers['Authorization'] = 'Bearer $t';
        handler.next(options);
      },
    ),
  );
  return dio;
}

class DioSyncApi implements SyncApi {
  DioSyncApi(this._dio);

  final Dio _dio;

  @override
  Future<PushResponse> push(String deviceId, List<Map<String, Object?>> ops) async {
    final res = await _call(
      () => _dio.post<Map<String, Object?>>(
        '/sync/push',
        data: {'protocol': syncProtocolVersion, 'device_id': deviceId, 'ops': ops},
      ),
    );
    return PushResponse.fromJson(res);
  }

  @override
  Future<PullResponse> pull(int cursor, int limit) async {
    final res = await _call(
      () => _dio.get<Map<String, Object?>>(
        '/sync/pull',
        queryParameters: {'cursor': cursor, 'limit': limit},
      ),
    );
    return PullResponse.fromJson(res);
  }

  Future<Map<String, Object?>> _call(Future<Response<Map<String, Object?>>> Function() send) async {
    try {
      final res = await send();
      return res.data ?? const {};
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 426) {
        final body = e.response?.data;
        final min = body is Map ? (body['min_protocol'] as num?)?.toInt() : null;
        throw UpgradeRequired(min ?? syncProtocolVersion + 1);
      }
      if (status == 401) throw const SignedOut();
      throw SyncUnavailable(status == null ? e.type.name : 'HTTP $status');
    }
  }
}
