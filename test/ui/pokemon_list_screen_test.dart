import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemondex/domain/entity/pokemon_spec.dart';
import 'package:pokemondex/ui/detail/pokemon_detail_screen.dart';
import 'package:pokemondex/ui/list/bloc/pokemon_list_bloc.dart';
import 'package:pokemondex/ui/list/pokemon_list_screen.dart';

class _MockPokemonListBloc extends Mock implements PokemonListBloc {}

class _FakePokemonListEvent extends Fake implements PokemonListEvent {}

class _FakePokemonListState extends Fake implements PokemonListState {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePokemonListEvent());
    registerFallbackValue(_FakePokemonListState());
  });

  group('PokemonListScreen Widget', () {
    late PokemonListBloc bloc;

    setUp(() {
      bloc = _MockPokemonListBloc();
    });

    Widget makeTestable(Widget child) {
      return MaterialApp(
        home: BlocProvider<PokemonListBloc>.value(value: bloc, child: child),
      );
    }

    testWidgets('shows CircularProgressIndicator when state is Loading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(PokemonListLoading());
      when(
        () => bloc.stream,
      ).thenAnswer((_) => Stream<PokemonListState>.empty());

      await tester.pumpWidget(makeTestable(const PokemonListWidget()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows list of pokemons when state is Loaded', (tester) async {
      final pokemons = [
        PokemonSpec(
          id: '1',
          name: 'Bulbasaur',
          number: '001',
          image: 'url',
          types: const ['Grass'],
        ),
        PokemonSpec(
          id: '2',
          name: 'Ivysaur',
          number: '002',
          image: 'url',
          types: const ['Grass'],
        ),
      ];

      when(() => bloc.state).thenReturn(PokemonListLoaded(pokemons));
      when(
        () => bloc.stream,
      ).thenAnswer((_) => Stream.value(PokemonListLoaded(pokemons)));

      await tester.pumpWidget(makeTestable(const PokemonListWidget()));

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Ivysaur'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('shows load more spinner when isLoadingMore is true', (
      tester,
    ) async {
      final pokemons = [
        PokemonSpec(
          id: '1',
          name: 'Bulbasaur',
          number: '001',
          image: 'url',
          types: const ['Grass'],
        ),
      ];

      when(
        () => bloc.state,
      ).thenReturn(PokemonListLoaded(pokemons, isLoadingMore: true));
      when(() => bloc.stream).thenAnswer(
        (_) => Stream.value(PokemonListLoaded(pokemons, isLoadingMore: true)),
      );

      await tester.pumpWidget(makeTestable(const PokemonListWidget()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is Error', (tester) async {
      when(() => bloc.state).thenReturn(const PokemonListError('offline'));
      when(
        () => bloc.stream,
      ).thenAnswer((_) => Stream.value(const PokemonListError('offline')));

      await tester.pumpWidget(makeTestable(const PokemonListWidget()));
      await tester.pumpAndSettle();

      expect(find.textContaining('offline'), findsOneWidget);
    });
  });
}
