import 'package:dio/dio.dart';

import '../network/dio_sync_api.dart';

/// Response of `POST /api/auth/login` and `/api/auth/pin` (sync-protocol §5.0).
class AuthResult {
  const AuthResult({
    required this.token,
    required this.deviceId,
    required this.isShared,
    required this.memberId,
    required this.memberName,
    required this.role,
    required this.householdId,
    required this.householdName,
    this.color,
  });

  factory AuthResult.fromJson(Map<String, Object?> j) {
    final device = (j['device'] as Map).cast<String, Object?>();
    final member = (j['member'] as Map).cast<String, Object?>();
    final household = (j['household'] as Map).cast<String, Object?>();
    return AuthResult(
      token: j['token'] as String,
      deviceId: device['id'] as String,
      isShared: device['is_shared'] == true || device['is_shared'] == 1,
      memberId: member['id'] as String,
      memberName: member['name'] as String,
      role: member['role'] as String,
      color: member['color'] as String?,
      householdId: household['id'] as String,
      householdName: household['name'] as String,
    );
  }

  final String token;
  final String deviceId;
  final bool isShared;
  final String memberId;
  final String memberName;
  final String role;
  final String? color;
  final String householdId;
  final String householdName;
}

/// Wrong email/password or PIN, or the account can't sign in here.
class InvalidCredentials implements Exception {
  const InvalidCredentials(this.message);
  final String message;
  @override
  String toString() => 'InvalidCredentials($message)';
}

abstract interface class AuthApi {
  Future<AuthResult> login({
    required String email,
    required String password,
    required String deviceId,
    required String deviceName,
    required String platform,
    required bool isShared,
  });

  /// PIN profile sign-in, called with the shared tablet's own token.
  Future<AuthResult> pinLogin({
    required String tabletToken,
    required String memberId,
    required String pin,
    required String deviceId,
  });

  Future<void> logout(String token);
}

class DioAuthApi implements AuthApi {
  DioAuthApi(this._dio);

  final Dio _dio;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    required String deviceId,
    required String deviceName,
    required String platform,
    required bool isShared,
  }) => _auth(
    () => _dio.post<Map<String, Object?>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'device_id': deviceId,
        'device_name': deviceName,
        'platform': platform,
        'is_shared': isShared,
      },
    ),
  );

  @override
  Future<AuthResult> pinLogin({
    required String tabletToken,
    required String memberId,
    required String pin,
    required String deviceId,
  }) => _auth(
    () => _dio.post<Map<String, Object?>>(
      '/auth/pin',
      data: {'member_id': memberId, 'pin': pin, 'device_id': deviceId},
      options: bearer(tabletToken),
    ),
  );

  @override
  Future<void> logout(String token) async {
    await guardApi(() => _dio.post<void>('/auth/logout', options: bearer(token)));
  }

  Future<AuthResult> _auth(Future<Response<Map<String, Object?>>> Function() send) async {
    final res = await guardApi(() async {
      try {
        return await send();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 422 || status == 403) throw InvalidCredentials(_message(e.response?.data));
        rethrow;
      }
    });
    return AuthResult.fromJson(res.data ?? const {});
  }

  static String _message(Object? body) {
    if (body is Map) {
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return '${first.first}';
      }
      if (body['message'] is String) return body['message'] as String;
    }
    return 'Sign-in failed.';
  }
}
