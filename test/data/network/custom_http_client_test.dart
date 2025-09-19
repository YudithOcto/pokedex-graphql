import 'package:flutter_test/flutter_test.dart';

import 'package:pokemondex/core/network/custom_http_client.dart';

class _SpyHttpClient extends CustomHttpClient {
  HttpRequest? lastRequest;
  Decoder<dynamic>? lastDecode;

  // What "raw" payload `send` should see from the transport layer.
  dynamic nextRawData;
  int nextStatusCode = 200;

  // Optional error to throw from `send` (to test propagation).
  HttpFailure? nextFailure;

  @override
  Future<HttpResponse<T>> send<T>(HttpRequest request, {Decoder<T>? decode}) async {
    if (nextFailure != null) throw nextFailure!;
    lastRequest = request;
    lastDecode = decode as Decoder<dynamic>?;
    final T data = decode != null ? decode(nextRawData) : (nextRawData as T);
    return HttpResponse<T>(statusCode: nextStatusCode, data: data);
  }
}

void main() {
  group('CustomHttpClient helpers', () {
    late _SpyHttpClient client;

    setUp(() {
      client = _SpyHttpClient();
    });

    test('GET delegates to send with correct fields + decode is forwarded', () async {
      client.nextRawData = {'ok': true};

      final res = await client.get<Map<String, dynamic>>(
        '/poke',
        query: {'first': 20},
        headers: {'X-Test': '1'},
        timeout: const Duration(seconds: 9),
        decode: (d) => Map<String, dynamic>.from(d as Map),
      );

      expect(res.statusCode, 200);
      expect(res.data['ok'], true);

      final r = client.lastRequest!;
      expect(r.method, HttpMethod.get);
      expect(r.path, '/poke');
      expect(r.query, {'first': 20});
      expect(r.headers, {'X-Test': '1'});
      expect(r.timeout, const Duration(seconds: 9));
      expect(client.lastDecode, isNotNull);
    });

    test('POST delegates to send with body + decode', () async {
      client.nextRawData = ['a', 'b'];

      final res = await client.post<List<String>>(
        '/poke',
        body: {'query': 'Q'},
        headers: {'Content-Type': 'application/json'},
        decode: (d) => (d as List).map((e) => e.toString()).toList(),
      );

      expect(res.data, ['a', 'b']);

      final r = client.lastRequest!;
      expect(r.method, HttpMethod.post);
      expect(r.path, '/poke');
      expect(r.body, {'query': 'Q'});
      expect(r.headers, {'Content-Type': 'application/json'});
    });

    test('PUT/PATCH/DELETE delegate with correct HttpMethod + body', () async {
      client.nextRawData = 204;

      await client.put<int>('/p', body: {'x': 1}, decode: (d) => d as int);
      expect(client.lastRequest!.method, HttpMethod.put);
      expect(client.lastRequest!.body, {'x': 1});

      await client.patch<int>('/p', body: {'y': 2}, decode: (d) => d as int);
      expect(client.lastRequest!.method, HttpMethod.patch);
      expect(client.lastRequest!.body, {'y': 2});

      await client.delete<int>('/p', body: {'z': 3}, decode: (d) => d as int);
      expect(client.lastRequest!.method, HttpMethod.delete);
      expect(client.lastRequest!.body, {'z': 3});
    });

    test('Works without decode (raw type cast path)', () async {
      client.nextRawData = 'ok';
      final res = await client.get<String>('/ping'); // no decode
      expect(res.data, 'ok');
      expect(client.lastDecode, isNull);
    });

    test('Failures from send propagate unchanged (e.g., Timeout)', () async {
      client.nextFailure = const TimeoutFailure('Request timed out');
      expect(
            () => client.get('/will-fail'),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('Unauthorized/Network/Unknown propagate unchanged', () async {
      final cases = const [
        UnauthorizedFailure('401'),
        NetworkFailure('offline'),
        UnknownHttpFailure('boom'),
      ];

      for (final f in cases) {
        client.nextFailure = f;
        await expectLater(
          client.post('/x'),                       // pass the Future
          throwsA(isA<HttpFailure>()
              .having((e) => e.runtimeType, 'type', f.runtimeType)
              .having((e) => e.message, 'message', f.message)),
        );
      }
    });
  });

  group('HttpRequest.copyWith', () {
    test('returns a new instance but preserves all fields when no overrides', () {
      final req = HttpRequest(
        method: HttpMethod.get,
        path: '/a',
        query: const {'q': 1},
        headers: const {'H': '1'},
        body: const {'x': 1},
        timeout: const Duration(seconds: 3),
      );

      final copy = req.copyWith();

      expect(identical(copy, req), isFalse);
      expect(copy.method, req.method);
      expect(copy.path, req.path);
      expect(copy.query, req.query);
      expect(copy.headers, req.headers);
      expect(copy.body, req.body);
      expect(copy.timeout, req.timeout);
    });

    test('overrides only provided fields and keeps the rest intact', () {
      final req = HttpRequest(
        method: HttpMethod.get,
        path: '/a',
        query: const {'q': 1},
        headers: const {'H': '1'},
        body: const {'x': 1},
        timeout: const Duration(seconds: 3),
      );

      final copy = req.copyWith(
        method: HttpMethod.post,
        path: '/b',
        query: const {'p': 2},
        headers: const {'H': '2'},
        body: const {'y': 2},
        timeout: const Duration(seconds: 10),
      );

      expect(copy.method, HttpMethod.post);
      expect(copy.path, '/b');
      expect(copy.query, {'p': 2});
      expect(copy.headers, {'H': '2'});
      expect(copy.body, {'y': 2});
      expect(copy.timeout, const Duration(seconds: 10));
    });
  });

  group('CustomHttpClient failures', () {
    test('CancelledFailure propagates unchanged from send()', () async {
      final client = _SpyHttpClient()..nextFailure = const CancelledFailure('Request cancelled');
      await expectLater(client.get('/cancel'), throwsA(isA<CancelledFailure>()));
    });

    test('toString includes type and message (smoke)', () {
      const f = NetworkFailure('offline', statusCode: 0);
      final s = f.toString();
      expect(s, contains('NetworkFailure'));
      expect(s, contains('offline'));
    });
  });
}
