import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/network/dio_sync_api.dart';
import 'package:homesync/core/sync/sync_state_store.dart';

import '../app_test.dart' as app;
import '../features/budget_screen_test.dart' show open;

/// Answers every request with [status] and the given headers.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.headers);

  final int status;
  final Map<String, List<String>> headers;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(
        jsonEncode({'min_protocol': 1}),
        status,
        headers: {
          ...headers,
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  group('hub version from responses', () {
    Future<List<String>> seen(int status, Map<String, List<String>> headers) async {
      final versions = <String>[];
      final dio = createApiClient(baseUrl: 'https://hub.test', onHubVersion: versions.add)
        ..httpClientAdapter = _Adapter(status, headers);
      try {
        await dio.get<dynamic>('/sync/pull');
      } on DioException catch (_) {}
      return versions;
    }

    test('read from a successful response', () async {
      expect(
        await seen(200, {
          'x-homesync-version': ['1.2.3'],
        }),
        ['1.2.3'],
      );
    });

    test('also read when the hub refuses an old app', () async {
      expect(
        await seen(426, {
          'x-homesync-version': ['2.0.0'],
        }),
        ['2.0.0'],
      );
    });

    test('nothing when the header is missing', () async {
      expect(await seen(200, const {}), isEmpty);
    });
  });

  testWidgets('home shows the app version, and the hub version once known', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(tester.widget<Text>(find.byKey(const Key('version-line'))).data, 'Version dev');

    await tester.runAsync(() => SyncStateStore(s.db).setHubVersion('1.2.3'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('version-line'))).data, 'Version dev · hub 1.2.3');
    await app.finish(tester, s);
  });
}
