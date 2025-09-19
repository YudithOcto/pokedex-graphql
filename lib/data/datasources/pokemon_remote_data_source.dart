import 'package:pokemondex/core/network/custom_http_client.dart';
import 'package:pokemondex/data/model/pokemon_detail_dto.dart';
import 'package:pokemondex/data/model/pokemon_dto.dart';

abstract class PokemonRemoteDataSource {
  Future<List<PokemonDto>> fetchPokemonList(int first);
  Future<PokemonDetailDto> fetchPokemonDetail(String id);
}

class DefaultPokemonRemoteDataSource implements PokemonRemoteDataSource {
  final CustomHttpClient _http;
  DefaultPokemonRemoteDataSource(this._http);

  static const _listQuery = r'''
    query GetPokemons($first: Int!) {
      pokemons(first: $first) {
        id number name image types classification
      }
    }
  ''';

  static const _detailByIdQuery = r'''
  query GetPokemonById($id: String!) {
    pokemon(id: $id) {
      id number name image types classification
      height { minimum maximum } weight { minimum maximum }
      attacks { fast { name type damage } special { name type damage } }
      evolutions { id number name image types classification }
    }
  }
''';
  @override
  Future<List<PokemonDto>> fetchPokemonList(int first) async {
    final res = await _http.post<Map<String, dynamic>>(
      '/',
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: {'query': _listQuery, 'variables': {'first': first}},
      decode: (d) => d as Map<String, dynamic>,
    );
    _throwIfGraphQLErrors(res.data);
    final items = (res.data['data']['pokemons'] as List);
    return items
        .map((e) => PokemonDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<PokemonDetailDto> fetchPokemonDetail(String id) async {
    final res = await _http.post<Map<String, dynamic>>(
      '/',
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: {'query': _detailByIdQuery, 'variables': {'id': id}},
      decode: (d) => d as Map<String, dynamic>,
    );
    _throwIfGraphQLErrors(res.data);
    return PokemonDetailDto.fromJson(Map<String, dynamic>.from(res.data['data']['pokemon']));
  }

  void _throwIfGraphQLErrors(Map<String, dynamic> root) {
    final errs = root['errors'] as List?;
    if (errs != null && errs.isNotEmpty) {
      throw Exception(errs.map((e) => (e as Map)['message']).join('; '));
    }
  }
}