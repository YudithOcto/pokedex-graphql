import 'package:pokemondex/core/network/custom_http_client.dart';
import 'package:pokemondex/data/model/pokemon_dto.dart';

abstract class PokemonRemoteDataSource {
  Future<List<PokemonDto>> fetchPokemonList(int first);

  Future<PokemonDto> fetchPokemonDetail(String id);
}

class DefaultPokemonRemoteDataSource implements PokemonRemoteDataSource {
  final CustomHttpClient _http;

  DefaultPokemonRemoteDataSource(this._http);

  static const _listQuery = r'''
    query GetPokemons($first: Int!) {
      pokemons(first: $first) {
        id number name image types number
      }
    }
  ''';

  static const _detailByIdQuery = r'''
  query GetPokemonById($id: String!) {
    pokemon(id: $id) {
      name
    number
    types
    image
    classification
    weight {
      maximum
      minimum
    }
    height {
      maximum
      minimum
    }
    types
    resistant
    attacks {
      fast {
        name
        type
        damage
      }
      special {
        name
        type
        damage
      }
    }
    weaknesses
    evolutions {
      name
      image
    }
    evolutionRequirements {
      name
      amount
    }
    maxHP
    }
  }
''';

  @override
  Future<List<PokemonDto>> fetchPokemonList(int first) async {
    final res = await _http.post<Map<String, dynamic>>(
      '/',
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        'query': _listQuery,
        'variables': {'first': first},
      },
      decode: (d) => d as Map<String, dynamic>,
    );
    _throwIfGraphQLErrors(res.data);
    final items = res.data['data']?['pokemons'];
    if (items == null) {
      throw Exception("Pokemons list not found or response malformed");
    }

    return (items as List)
        .map((e) => PokemonDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<PokemonDto> fetchPokemonDetail(String id) async {
    final res = await _http.post<Map<String, dynamic>>(
      '/',
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        'query': _detailByIdQuery,
        'variables': {'id': id},
      },
      decode: (d) => d as Map<String, dynamic>,
    );
    _throwIfGraphQLErrors(res.data);
    return fromGraphQLResponse(res.data);
  }

  void _throwIfGraphQLErrors(Map<String, dynamic> root) {
    final errs = root['errors'] as List?;
    if (errs != null && errs.isNotEmpty) {
      throw Exception(errs.map((e) => (e as Map)['message']).join('; '));
    }
  }

  PokemonDto fromGraphQLResponse(Map<String, dynamic> root) {
    _throwIfGraphQLErrors(root);

    final pokemon = root['data']?['pokemon'];
    if (pokemon == null) {
      throw Exception("Pokemon not found or response malformed");
    }

    return PokemonDto.fromJson(Map<String, dynamic>.from(pokemon));
  }
}
