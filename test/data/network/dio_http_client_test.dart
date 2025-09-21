import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:pokemondex/common/constants.dart';
import 'package:pokemondex/core/network/custom_http_client.dart';
import 'package:pokemondex/core/network/dio_client.dart';


class _MockDio extends Mock implements Dio {}

Response<T> _res<T>(
    T data, {
      int status = 200,
      Map<String, List<String>> headers = const {},
    }) =>
    Response<T>(
      requestOptions: RequestOptions(path: '/'),
      data: data,
      statusCode: status,
      headers: Headers.fromMap(headers),
    );

DioException _dioErr({
  required DioExceptionType type,
  int? status,
  String? message,
}) =>
    DioException(
      requestOptions: RequestOptions(path: '/'),
      type: type,
      response: status == null
          ? null
          : Response(requestOptions: RequestOptions(path: '/'), statusCode: status),
      message: message,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(Options());
  });

  group('buildDio', () {
    test('sets baseUrl, timeouts, headers and responseType', () {
      final dio = buildDio();
      expect(dio.options.baseUrl, kBaseUrl);
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
      expect(dio.options.responseType, ResponseType.json);
      expect(dio.options.headers['Accept'], 'application/json');
    });
  });

  group('DioHttpClient.send', () {
    late _MockDio dio;
    late DioHttpClient client;

    setUp(() {
      dio = _MockDio();
      client = DioHttpClient(dio);
    });

    test('passes path/query/body/headers & applies decode, collects headers', () async {
      when(() => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => _res({'ok': true}, headers: {
        'x-test': ['a', 'b']
      }));

      final res = await client.send<Map<String, dynamic>>(
        HttpRequest(
          method: HttpMethod.post,
          path: '/poke',
          query: {'first': 20},
          headers: {'H': '1'},
          body: {'query': 'Q'},
          timeout: const Duration(seconds: 9),
        ),
        decode: (d) => Map<String, dynamic>.from(d as Map),
      );

      // response
      expect(res.statusCode, 200);
      expect(res.data['ok'], true);
      expect(res.headers['x-test'], ['a', 'b']);

      // verify request + capture Options (to check method/timeout)
      final captured = verify(() => dio.request<dynamic>(
        captureAny(), // path
        data: captureAny(named: 'data'),
        queryParameters: captureAny(named: 'queryParameters'),
        options: captureAny(named: 'options'),
      )).captured;

      expect(captured[0], '/poke');
      expect(captured[1], {'query': 'Q'});
      expect(captured[2], {'first': 20});
      final opts = captured[3] as Options;
      expect(opts.method, 'POST');
      expect(opts.headers, {'H': '1'});
      expect(opts.sendTimeout, const Duration(seconds: 9));
      expect(opts.receiveTimeout, const Duration(seconds: 9));
    });

    test('works without decode (casts raw data to T)', () async {
      when(() => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => _res('pong'));

      final res = await client.send<String>(
        HttpRequest(method: HttpMethod.get, path: '/ping'),
      );

      expect(res.data, 'pong');
    });

    test('maps method GET/PUT/PATCH/DELETE correctly', () async {
      when(() => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => _res(true));

      // GET
      await client.send(HttpRequest(method: HttpMethod.get, path: '/g'));
      var opts = verify(() => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: captureAny(named: 'options'),
      )).captured.last as Options;
      expect(opts.method, 'GET');

      // PUT
      await client.send(HttpRequest(method: HttpMethod.put, path: '/p'));
      opts = verify(() => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: captureAny(named: 'options'),
      )).captured.last as Options;
      expect(opts.method, 'PUT');

      // PATCH
      await client.send(HttpRequest(method: HttpMethod.patch, path: '/pa'));
      opts = verify(() => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: captureAny(named: 'options'),
      )).captured.last as Options;
      expect(opts.method, 'PATCH');

      // DELETE
      await client.send(HttpRequest(method: HttpMethod.delete, path: '/d'));
      opts = verify(() => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: captureAny(named: 'options'),
      )).captured.last as Options;
      expect(opts.method, 'DELETE');
    });

    // ---- Failure mappings ----

    test('connection/send/receive timeout => TimeoutFailure', () async {
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.connectionTimeout));

      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/t')),
        throwsA(isA<TimeoutFailure>()),
      );

      // sendTimeout
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.sendTimeout));
      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/t')),
        throwsA(isA<TimeoutFailure>()),
      );

      // receiveTimeout
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.receiveTimeout));
      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/t')),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('cancel => CancelledFailure', () async {
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.cancel));

      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/c')),
        throwsA(isA<CancelledFailure>()),
      );
    });

    test('badResponse 401 => UnauthorizedFailure, other status => NetworkFailure', () async {
      // 401
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.badResponse, status: 401));
      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/u')),
        throwsA(isA<UnauthorizedFailure>()),
      );

      // 500
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.badResponse, status: 500));
      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/n')),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('badCertificate/connectionError => NetworkFailure', () async {
      // badCertificate
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.badCertificate, message: 'cert'));
      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/bc')),
        throwsA(isA<NetworkFailure>()),
      );

      // connectionError
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.connectionError, message: 'conn'));
      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/ce')),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('unknown => UnknownHttpFailure', () async {
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(_dioErr(type: DioExceptionType.unknown, message: 'boom'));

      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/x')),
        throwsA(isA<UnknownHttpFailure>()),
      );
    });

    test('non-Dio exception => UnknownHttpFailure', () async {
      when(() => dio.request<dynamic>(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options')))
          .thenThrow(StateError('weird'));

      await expectLater(
        client.send(HttpRequest(method: HttpMethod.get, path: '/x')),
        throwsA(isA<UnknownHttpFailure>()),
      );
    });
  });
}