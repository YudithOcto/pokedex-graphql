import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemondex/core/network/custom_http_client.dart';
import 'package:pokemondex/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemondex/data/model/pokemon_detail_dto.dart';
import 'package:pokemondex/data/model/pokemon_dto.dart';
import 'package:pokemondex/data/repository/default_pokemon_repository.dart';

class _MockRemote extends Mock implements PokemonRemoteDataSource {}

void main() {
  group('DefaultPokemonRepository', () {
    late _MockRemote remote;
    late DefaultPokemonRepository repo;

    setUp(() {
      remote = _MockRemote();
      repo = DefaultPokemonRepository(remote);
    });

    test('fetchPokemonList delegates to data source and returns DTOs', () async {
      when(() => remote.fetchPokemonList(2)).thenAnswer(
            (_) async =>  [
          PokemonDto(id: 'id-1', name: 'Bulbasaur', image: 'u1', types: ['Grass', 'Poison'], number: "01"),
          PokemonDto(id: 'id-2', name: 'Ivysaur',  image: 'u2', types: ['Grass', 'Poison'], number: "02"),
        ],
      );

      final result = await repo.fetchPokemonList(2);

      expect(result, isA<List<PokemonDto>>());
      expect(result.length, 2);
      expect(result.first.name, 'Bulbasaur');
      verify(() => remote.fetchPokemonList(2)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('fetchPokemonList returns empty list when data source returns empty', () async {
      when(() => remote.fetchPokemonList(0)).thenAnswer((_) async => const []);
      final result = await repo.fetchPokemonList(0);
      expect(result, isEmpty);
      verify(() => remote.fetchPokemonList(0)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('fetchPokemonList propagates NetworkFailure', () async {
      when(() => remote.fetchPokemonList(10)).thenThrow(const NetworkFailure('offline'));
      expect(() => repo.fetchPokemonList(10), throwsA(isA<NetworkFailure>()));
      verify(() => remote.fetchPokemonList(10)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('fetchPokemonList propagates UnknownHttpFailure', () async {
      when(() => remote.fetchPokemonList(10)).thenThrow(const UnknownHttpFailure('boom'));
      expect(() => repo.fetchPokemonList(10), throwsA(isA<UnknownHttpFailure>()));
      verify(() => remote.fetchPokemonList(10)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('fetchPokemonDetail delegates to data source (by id)', () async {
      const id = 'UG9rZW1vbjowMTU';
      final dto = PokemonDetailDto(
        id: id,
        number: '015',
        name: 'Beedrill',
        image: 'url',
        types: const ['Bug', 'Poison'],
        classification: 'Poison Bee Pokémon',
        height: const RangeDto(minimum: '0.88m', maximum: '1.13m'),
        weight: const RangeDto(minimum: '25.81kg', maximum: '33.19kg'),
        fastAttacks: const [],
        specialAttacks: const [],
        evolutions: const [],
      );

      when(() => remote.fetchPokemonDetail(id)).thenAnswer((_) async => dto);

      final detail = await repo.fetchPokemonDetail(id);

      expect(detail.name, 'Beedrill');
      expect(() => detail.types.add('X'), throwsUnsupportedError); // immutability guard
      verify(() => remote.fetchPokemonDetail(id)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('fetchPokemonDetail propagates UnknownHttpFailure for GraphQL errors', () async {
      const id = 'UG9rZW1vbjowMTU';
      when(() => remote.fetchPokemonDetail(id))
          .thenThrow(const UnknownHttpFailure('Variable "name" is required', statusCode: 200));
      expect(() => repo.fetchPokemonDetail(id), throwsA(isA<UnknownHttpFailure>()));
      verify(() => remote.fetchPokemonDetail(id)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('fetchPokemonDetail propagates TimeoutFailure', () async {
      const id = 'UG9rZW1vbjowMTU';
      when(() => remote.fetchPokemonDetail(id)).thenThrow(const TimeoutFailure('Request timed out'));
      expect(() => repo.fetchPokemonDetail(id), throwsA(isA<TimeoutFailure>()));
      verify(() => remote.fetchPokemonDetail(id)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('fetchPokemonDetail propagates UnknownHttpFailure for not found', () async {
      const id = 'does-not-exist';
      when(() => remote.fetchPokemonDetail(id)).thenThrow(const UnknownHttpFailure('Pokemon not found'));
      expect(() => repo.fetchPokemonDetail(id), throwsA(isA<UnknownHttpFailure>()));
      verify(() => remote.fetchPokemonDetail(id)).called(1);
      verifyNoMoreInteractions(remote);
    });
  });
}
