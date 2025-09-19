import 'package:pokemondex/data/model/pokemon_detail_dto.dart';
import 'package:pokemondex/data/model/pokemon_dto.dart';

abstract class PokemonRepository {
  Future<List<PokemonDto>> fetchPokemonList(int first);
  Future<PokemonDetailDto> fetchPokemonDetail(String id);
}