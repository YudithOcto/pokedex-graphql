

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pokemondex/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemondex/data/repository/default_pokemon_repository.dart';
import 'package:pokemondex/domain/repository/pokemon_repository.dart';

import 'network/dio_client.dart';
import 'network/custom_http_client.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  sl.registerLazySingleton<Dio>(() => buildDio());

  // HttpClient abstraction
  sl.registerLazySingleton<CustomHttpClient>(() => DioHttpClient(sl<Dio>()));

  // data source
  sl.registerLazySingleton<PokemonRemoteDataSource>(() => DefaultPokemonRemoteDataSource(sl<CustomHttpClient>()));

  // repository
  sl.registerLazySingleton<PokemonRepository>(() => DefaultPokemonRepository(sl<PokemonRemoteDataSource>()));
}