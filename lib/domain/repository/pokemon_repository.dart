import 'package:pokemondex/domain/entity/pokemon_detail_spec.dart';
import 'package:pokemondex/domain/entity/pokemon_spec.dart';

abstract class PokemonRepository {
  Future<List<PokemonSpec>> fetchPokemonList(int first);
  Future<PokemonDetailSpec> fetchPokemonDetail(String id);
}