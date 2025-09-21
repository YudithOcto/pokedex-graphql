import 'package:pokemondex/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemondex/domain/entity/pokemon_detail_spec.dart';
import 'package:pokemondex/domain/entity/pokemon_spec.dart';
import 'package:pokemondex/domain/repository/pokemon_repository.dart';

class DefaultPokemonRepository implements PokemonRepository {
  final PokemonRemoteDataSource remote;
  DefaultPokemonRepository(this.remote);

  @override
  Future<List<PokemonSpec>> fetchPokemonList(int first) async {
    final dtos = await remote.fetchPokemonList(first);
    return dtos.map((dto) {
      return PokemonSpec(
        name: dto.name,
        number: dto.number,
        image: dto.image,
        types: dto.types,
        id: dto.id,
      );
    }).toList();
  }

  @override
  Future<PokemonDetailSpec> fetchPokemonDetail(String id) async {
    final dtos = await remote.fetchPokemonDetail(id);
    return dtos.toEntity();
  }
}