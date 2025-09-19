import 'package:dio/dio.dart';
import 'package:pokemondex/core/constants.dart';
import 'custom_http_client.dart';

Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
      responseType: ResponseType.json,
    ),
  );
  return dio;
}

class DioHttpClient extends CustomHttpClient {
  final Dio _dio;

  DioHttpClient(this._dio);

  @override
  Future<HttpResponse<T>> send<T>(HttpRequest req, {Decoder<T>? decode}) async {
    try {
      final options = Options(
        method: switch (req.method) {
          HttpMethod.get => 'GET',
          HttpMethod.post => 'POST',
          HttpMethod.put => 'PUT',
          HttpMethod.patch => 'PATCH',
          HttpMethod.delete => 'DELETE',
        },
        headers: req.headers,
        sendTimeout: req.timeout,
        receiveTimeout: req.timeout,
      );

      final res = await _dio.request(
        req.path,
        data: req.body,
        queryParameters: req.query,
        options: options,
      );

      final headers = <String, List<String>>{};
      res.headers.forEach((k, v) => headers[k] = v);

      final T data = decode != null ? decode(res.data) : (res.data as T);

      return HttpResponse<T>(
        statusCode: res.statusCode ?? 0,
        data: data,
        headers: headers,
      );
    } on DioException catch (e) {
      final sc = e.response?.statusCode;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw TimeoutFailure('Request timed out', statusCode: sc);
        case DioExceptionType.cancel:
          throw CancelledFailure('Request cancelled', statusCode: sc);
        case DioExceptionType.badResponse:
          if (sc == 401) {
            throw UnauthorizedFailure('Unauthorized', statusCode: sc);
          }
          throw NetworkFailure('HTTP $sc', statusCode: sc);
        case DioExceptionType.badCertificate:
        case DioExceptionType.connectionError:
          throw NetworkFailure('Network error: ${e.message}', statusCode: sc);
        case DioExceptionType.unknown:
          throw UnknownHttpFailure(
            e.message ?? 'Unknown error',
            statusCode: sc,
          );
      }
    } catch (e) {
      throw UnknownHttpFailure(e.toString());
    }
  }
}
