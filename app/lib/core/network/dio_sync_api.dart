import 'package:dio/dio.dart';

import '../app_version.dart';
import '../sync/sync_api.dart';

/// Base URL of the sync hub, set at build time:
/// `--dart-define=API_BASE_URL=https://api.example.com`.
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');

/// Dio client with the protocol header. Bearer tokens are added per request
/// because a shared tablet holds one token per PIN profile. [onHubVersion]
/// gets the hub's release version from each response that names it.
Dio createApiClient({String baseUrl = apiBaseUrl, void Function(String version)? onHubVersion}) {
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
  if (onHubVersion != null) {
    void note(Response<dynamic>? res) {
      final v = res?.headers.value(hubVersionHeader)?.trim();
      if (v != null && v.isNotEmpty) onHubVersion(v);
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (res, handler) {
          note(res);
          handler.next(res);
        },
        onError: (e, handler) {
          note(e.response);
          handler.next(e);
        },
      ),
    );
  }
  return dio;
}

Options bearer(String token) => Options(headers: {'Authorization': 'Bearer $token'});

/// Maps transport failures to the sync exceptions the scheduler understands.
Future<T> guardApi<T>(Future<T> Function() send) async {
  try {
    return await send();
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

class DioSyncApi implements SyncApi {
  DioSyncApi(this._dio, {required this.tokenFor, required this.mainDeviceId});

  final Dio _dio;

  /// Token of a device id this install holds (main sign-in or PIN profile).
  final Future<String?> Function(String deviceId) tokenFor;

  /// Device whose token pulls. On the shared tablet that is the adult
  /// account that set the tablet up.
  final String Function() mainDeviceId;

  @override
  Future<PushResponse> push(String deviceId, List<Map<String, Object?>> ops) async {
    final token = await tokenFor(deviceId);
    if (token == null) throw ProfileTokenMissing(deviceId);
    final res = await guardApi(
      () => _dio.post<Map<String, Object?>>(
        '/sync/push',
        data: {'protocol': syncProtocolVersion, 'device_id': deviceId, 'ops': ops},
        options: bearer(token),
      ),
    );
    return PushResponse.fromJson(res.data ?? const {});
  }

  @override
  Future<PullResponse> pull(int cursor, int limit) async {
    final token = await tokenFor(mainDeviceId());
    if (token == null) throw const SignedOut();
    final res = await guardApi(
      () => _dio.get<Map<String, Object?>>(
        '/sync/pull',
        queryParameters: {'cursor': cursor, 'limit': limit},
        options: bearer(token),
      ),
    );
    return PullResponse.fromJson(res.data ?? const {});
  }

  @override
  Future<BootstrapResponse> bootstrap() async {
    final token = await tokenFor(mainDeviceId());
    if (token == null) throw const SignedOut();
    final res = await guardApi(
      () => _dio.get<Map<String, Object?>>('/sync/bootstrap', options: bearer(token)),
    );
    return BootstrapResponse.fromJson(res.data ?? const {});
  }
}
