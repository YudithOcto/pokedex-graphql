import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pokemondex/domain/entity/pokemon_spec.dart';
import 'package:pokemondex/domain/repository/pokemon_repository.dart';

part 'pokemon_list_event.dart';
part 'pokemon_list_state.dart';

class PokemonListBloc extends Bloc<PokemonListEvent, PokemonListState> {
  final PokemonRepository repo;
  int _currentLimit = 20;

  PokemonListBloc(this.repo) : super(PokemonListLoading()) {
    on<LoadPokemonList>(_onLoadInitial);
    on<LoadMorePokemon>(_onLoadMore);
  }

  Future<void> _onLoadInitial(
      LoadPokemonList event, Emitter<PokemonListState> emit) async {
    emit(PokemonListLoading());
    try {
      _currentLimit = event.first;
      final pokemons = await repo.fetchPokemonList(_currentLimit);
      emit(PokemonListLoaded(pokemons));
    } catch (e) {
      emit(PokemonListError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMorePokemon event, Emitter<PokemonListState> emit) async {
    if (state is! PokemonListLoaded) return;
    final currentState = state as PokemonListLoaded;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      _currentLimit += 20;
      final newPokemons = await repo.fetchPokemonList(_currentLimit);

      final merged = [
        ...currentState.pokemons,
        ...newPokemons.skip(currentState.pokemons.length)
      ];

      emit(PokemonListLoaded(merged));
    } catch (e) {
      emit(PokemonListError(e.toString()));
    }
  }
}
