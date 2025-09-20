import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemondex/domain/repository/pokemon_repository.dart';
import 'package:pokemondex/ui/detail/bloc/pokemon_detail_event.dart';
import 'package:pokemondex/ui/detail/bloc/pokemon_detail_state.dart';

class PokemonDetailBloc extends Bloc<PokemonDetailEvent, PokemonDetailState> {
  final PokemonRepository repository;

  PokemonDetailBloc(this.repository) : super(PokemonDetailInitial()) {
    on<LoadPokemonDetail>((event, emit) async {
      emit(PokemonDetailLoading());
      try {
        final detail = await repository.fetchPokemonDetail(event.name);
        emit(PokemonDetailLoaded(detail));
      } catch (e) {
        emit(PokemonDetailError(e.toString()));
      }
    });
  }
}


