part of 'pokemon_list_bloc.dart';

abstract class PokemonListState extends Equatable {
  const PokemonListState();
  @override
  List<Object?> get props => [];
}

class PokemonListLoading extends PokemonListState {}

class PokemonListLoaded extends PokemonListState {
  final List<PokemonSpec> pokemons;
  final bool isLoadingMore;

  const PokemonListLoaded(this.pokemons, {this.isLoadingMore = false});

  PokemonListLoaded copyWith({
    List<PokemonSpec>? pokemons,
    bool? isLoadingMore,
  }) {
    return PokemonListLoaded(
      pokemons ?? this.pokemons,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [pokemons, isLoadingMore];
}

class PokemonListError extends PokemonListState {
  final String message;
  const PokemonListError(this.message);
  @override
  List<Object?> get props => [message];
}
