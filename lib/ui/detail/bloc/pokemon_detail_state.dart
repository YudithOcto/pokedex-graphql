import 'package:equatable/equatable.dart';
import 'package:pokemondex/domain/entity/pokemon_detail_spec.dart';

abstract class PokemonDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PokemonDetailInitial extends PokemonDetailState {}
class PokemonDetailLoading extends PokemonDetailState {}
class PokemonDetailLoaded extends PokemonDetailState {
  final PokemonDetailSpec detail;
  PokemonDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}
class PokemonDetailError extends PokemonDetailState {
  final String message;
  PokemonDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
