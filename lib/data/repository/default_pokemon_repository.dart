import 'package:pokemondex/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemondex/data/model/pokemon_detail_dto.dart';
import 'package:pokemondex/data/model/pokemon_dto.dart';
import 'package:pokemondex/domain/repository/pokemon_repository.dart';

class DefaultPokemonRepository implements PokemonRepository {
  final PokemonRemoteDataSource remote;
  DefaultPokemonRepository(this.remote);

  @override
  Future<List<PokemonDto>> fetchPokemonList(int first) => remote.fetchPokemonList(first);

  @override
  Future<PokemonDetailDto> fetchPokemonDetail(String id) => remote.fetchPokemonDetail(id);
}