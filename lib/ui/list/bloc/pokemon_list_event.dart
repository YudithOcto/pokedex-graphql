part of 'pokemon_list_bloc.dart';

abstract class PokemonListEvent extends Equatable {
  const PokemonListEvent();
  @override
  List<Object?> get props => [];
}

class LoadPokemonList extends PokemonListEvent {
  final int first;
  const LoadPokemonList(this.first);
  @override
  List<Object?> get props => [first];
}

class LoadMorePokemon extends PokemonListEvent {
  const LoadMorePokemon();
}