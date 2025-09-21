import 'package:equatable/equatable.dart';

abstract class PokemonDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPokemonDetail extends PokemonDetailEvent {
  final String name;
  LoadPokemonDetail(this.name);

  @override
  List<Object?> get props => [name];
}
