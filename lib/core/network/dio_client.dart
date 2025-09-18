import 'package:dio/dio.dart';
import 'package:pokemondex/core/constants.dart';

Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: { 'Accept': 'application/json' },
      responseType: ResponseType.json,
    )
  );
  return dio;
}