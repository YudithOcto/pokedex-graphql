typedef Decoder<T> = T Function(dynamic data);

enum HttpMethod { get, post, put, patch, delete }

class HttpRequest {
  final HttpMethod method;
  final String path;
  final Map<String, dynamic>? query;
  final Map<String, String>? headers;
  final dynamic body;
  final Duration? timeout;

  const HttpRequest({
    required this.method,
    required this.path,
    this.query,
    this.headers,
    this.body,
    this.timeout,
  });

  HttpRequest copyWith({
    HttpMethod? method,
    String? path,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
  }) =>
      HttpRequest(
        method: method ?? this.method,
        path: path ?? this.path,
        query: query ?? this.query,
        headers: headers ?? this.headers,
        body: body ?? this.body,
        timeout: timeout ?? this.timeout,
      );
}

class HttpResponse<T> {
  final int statusCode;
  final T data;
  final Map<String, List<String>> headers;
  const HttpResponse({
    required this.statusCode,
    required this.data,
    this.headers = const {},
  });
}

sealed class HttpFailure implements Exception {
  final String message;
  final int? statusCode;
  const HttpFailure(this.message, {this.statusCode});
  @override
  String toString() => '$runtimeType($statusCode): $message';
}
class NetworkFailure extends HttpFailure { const NetworkFailure(super.message, {super.statusCode}); }
class TimeoutFailure extends HttpFailure { const TimeoutFailure(super.message, {super.statusCode}); }
class CancelledFailure extends HttpFailure { const CancelledFailure(super.message, {super.statusCode}); }
class UnauthorizedFailure extends HttpFailure { const UnauthorizedFailure(super.message, {super.statusCode}); }
class UnknownHttpFailure extends HttpFailure { const UnknownHttpFailure(super.message, {super.statusCode}); }

abstract class CustomHttpClient {
  Future<HttpResponse<T>> send<T>(
      HttpRequest request, {
        Decoder<T>? decode,
      });

  Future<HttpResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        Duration? timeout,
        Decoder<T>? decode,
      }) {
    return send<T>(
      HttpRequest(
        method: HttpMethod.get,
        path: path,
        query: query,
        headers: headers,
        timeout: timeout,
      ),
      decode: decode,
    );
  }

  Future<HttpResponse<T>> post<T>(
      String path, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        Duration? timeout,
        Decoder<T>? decode,
      }) {
    return send<T>(
      HttpRequest(
        method: HttpMethod.post,
        path: path,
        query: query,
        headers: headers,
        body: body,
        timeout: timeout,
      ),
      decode: decode,
    );
  }

  Future<HttpResponse<T>> put<T>(
      String path, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        Duration? timeout,
        Decoder<T>? decode,
      }) => send<T>(
    HttpRequest(
      method: HttpMethod.put,
      path: path,
      query: query,
      headers: headers,
      body: body,
      timeout: timeout,
    ),
    decode: decode,
  );

  Future<HttpResponse<T>> patch<T>(
      String path, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        Duration? timeout,
        Decoder<T>? decode,
      }) => send<T>(
    HttpRequest(
      method: HttpMethod.patch,
      path: path,
      query: query,
      headers: headers,
      body: body,
      timeout: timeout,
    ),
    decode: decode,
  );

  Future<HttpResponse<T>> delete<T>(
      String path, {
        dynamic body,
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        Duration? timeout,
        Decoder<T>? decode,
      }) => send<T>(
    HttpRequest(
      method: HttpMethod.delete,
      path: path,
      query: query,
      headers: headers,
      body: body,
      timeout: timeout,
    ),
    decode: decode,
  );
}
