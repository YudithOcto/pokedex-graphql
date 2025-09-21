import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemondex/core/network/custom_http_client.dart';
import 'package:pokemondex/domain/entity/pokemon_spec.dart';
import 'package:pokemondex/domain/repository/pokemon_repository.dart';
import 'package:pokemondex/ui/list/bloc/pokemon_list_bloc.dart';

class _MockRepo extends Mock implements PokemonRepository {}

void main() {
  group('PokemonListBloc', () {
    late PokemonRepository repo;
    late PokemonListBloc bloc;

    setUp(() {
      repo = _MockRepo();
      bloc = PokemonListBloc(repo);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Loaded] on successful initial load',
      build: () {
        when(() => repo.fetchPokemonList(20)).thenAnswer((_) async => [
          PokemonSpec(
              id: '1',
              name: 'Bulbasaur',
              number: '001',
              image: 'u1',
              types: const ['Grass']),
        ]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPokemonList(20)),
      expect: () => [
        PokemonListLoading(),
        isA<PokemonListLoaded>()
            .having((s) => s.pokemons.length, 'count', 1)
            .having((s) => s.pokemons.first.name, 'first name', 'Bulbasaur'),
      ],
      verify: (_) => verify(() => repo.fetchPokemonList(20)).called(1),
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Loaded(empty)] when repo returns empty list',
      build: () {
        when(() => repo.fetchPokemonList(20)).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPokemonList(20)),
      expect: () => [
        PokemonListLoading(),
        isA<PokemonListLoaded>().having((s) => s.pokemons, 'empty list', isEmpty),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Error] when repo throws during initial load',
      build: () {
        when(() => repo.fetchPokemonList(20))
            .thenThrow(const NetworkFailure('offline'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPokemonList(20)),
      expect: () => [
        PokemonListLoading(),
        isA<PokemonListError>().having((s) => s.message, 'msg', contains('offline')),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'ignores LoadMorePokemon if state is not Loaded',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadMorePokemon()),
      expect: () => [], // no state changes
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loaded(loadingMore), Loaded(merged)] on successful load more',
      build: () {
        // first fetch: 1 item
        when(() => repo.fetchPokemonList(20)).thenAnswer((_) async => [
          PokemonSpec(
              id: '1',
              name: 'Bulbasaur',
              number: '001',
              image: 'u1',
              types: const ['Grass']),
        ]);
        // second fetch: 2 items
        when(() => repo.fetchPokemonList(40)).thenAnswer((_) async => [
          PokemonSpec(
              id: '1',
              name: 'Bulbasaur',
              number: '001',
              image: 'u1',
              types: const ['Grass']),
          PokemonSpec(
              id: '2',
              name: 'Ivysaur',
              number: '002',
              image: 'u2',
              types: const ['Grass']),
        ]);
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadPokemonList(20));
        await Future.delayed(Duration.zero);
        bloc.add(LoadMorePokemon());
      },
      expect: () => [
        PokemonListLoading(),
        isA<PokemonListLoaded>().having((s) => s.pokemons.length, 'count', 1),
        isA<PokemonListLoaded>().having((s) => s.isLoadingMore, 'loading more', true),
        isA<PokemonListLoaded>().having((s) => s.pokemons.length, 'count', 2),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loaded(loadingMore), Error] when repo throws on load more',
      build: () {
        when(() => repo.fetchPokemonList(20)).thenAnswer((_) async => [
          PokemonSpec(
              id: '1',
              name: 'Bulbasaur',
              number: '001',
              image: 'u1',
              types: const ['Grass']),
        ]);
        when(() => repo.fetchPokemonList(40))
            .thenThrow(const TimeoutFailure('Request timed out'));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadPokemonList(20));
        await Future.delayed(Duration.zero);
        bloc.add(LoadMorePokemon());
      },
      expect: () => [
        PokemonListLoading(),
        isA<PokemonListLoaded>().having((s) => s.pokemons.length, 'count', 1),
        isA<PokemonListLoaded>().having((s) => s.isLoadingMore, 'loading more', true),
        isA<PokemonListError>().having((s) => s.message, 'msg', contains('timed out')),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'propagates generic Exception during load more',
      build: () {
        when(() => repo.fetchPokemonList(20)).thenAnswer((_) async => [
          PokemonSpec(
              id: '1',
              name: 'Bulbasaur',
              number: '001',
              image: 'u1',
              types: const ['Grass']),
        ]);
        when(() => repo.fetchPokemonList(40)).thenThrow(Exception('unexpected'));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadPokemonList(20));
        await Future.delayed(Duration.zero);
        bloc.add(LoadMorePokemon());
      },
      expect: () => [
        PokemonListLoading(),
        isA<PokemonListLoaded>().having((s) => s.pokemons.length, 'count', 1),
        isA<PokemonListLoaded>().having((s) => s.isLoadingMore, 'loading more', true),
        isA<PokemonListError>().having((s) => s.message, 'msg', contains('unexpected')),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Error] when initial load throws generic Exception',
      build: () {
        when(() => repo.fetchPokemonList(20))
            .thenThrow(Exception('unexpected failure'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPokemonList(20)),
      expect: () => [
        PokemonListLoading(),
        isA<PokemonListError>()
            .having((s) => s.message, 'message', contains('unexpected failure')),
      ],
    );
  });
}
