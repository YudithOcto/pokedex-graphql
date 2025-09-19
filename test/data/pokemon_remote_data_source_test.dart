import 'package:flutter_test/flutter_test.dart';
import 'package:pokemondex/core/network/custom_http_client.dart';
import 'package:pokemondex/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemondex/data/model/pokemon_detail_dto.dart';
import 'package:pokemondex/data/model/pokemon_dto.dart';

class _FakeHttpClient extends CustomHttpClient {
  Map<String, dynamic> payload;
  _FakeHttpClient(this.payload);

  @override
  Future<HttpResponse<T>> send<T>(HttpRequest req, {Decoder<T>? decode}) async {
    final data = decode != null ? decode(payload) : payload as T;
    return HttpResponse<T>(statusCode: 200, data: data);
  }
}

void main() {
  group('PokemonGraphqlDataSource', () {
    test('fetchPokemons returns list of PokemonDto', () async {
      final fakePayload = {
        'data': {
          'pokemons': [
            {
              'id': 'UG9rZW1vbjowMDE=',
              'number': '001',
              'name': 'Bulbasaur',
              'image': 'https://img.pokemondb.net/artwork/bulbasaur.jpg',
              'types': ['Grass', 'Poison'],
              'classification': 'Seed Pokémon',
            },
            {
              'id': 'UG9rZW1vbjowMDI=',
              'number': '002',
              'name': 'Ivysaur',
              'image': 'https://img.pokemondb.net/artwork/ivysaur.jpg',
              'types': ['Grass', 'Poison'],
              'classification': 'Seed Pokémon',
            },
          ]
        }
      };

      final http = _FakeHttpClient(fakePayload);
      final ds = DefaultPokemonRemoteDataSource(http);

      final result = await ds.fetchPokemonList(2);

      expect(result, isA<List<PokemonDto>>());
      expect(result.length, 2);
      expect(result.first.name, 'Bulbasaur');

      expect(() => result.first.types.add('X'), throwsUnsupportedError);
    });

    test('fetchPokemons throws Exception on GraphQL errors', () async {
      final fakePayload = {
        'errors': [
          {'message': 'Something went wrong'}
        ]
      };
      final http = _FakeHttpClient(fakePayload);
      final ds = DefaultPokemonRemoteDataSource(http);

      expect(
            () => ds.fetchPokemonList(1),
        throwsA(isA<Exception>()),
      );
    });

    test('fetchDetail returns PokemonDetailDto', () async {
      final fakePayload = {
        'data': {
          'pokemon': {
            'id': 'UG9rZW1vbjowMDQ=',
            'number': '004',
            'name': 'Charmander',
            'image': 'https://img.pokemondb.net/artwork/charmander.jpg',
            'types': ['Fire'],
            'classification': 'Lizard Pokémon',
            'height': {'minimum': '0.53m', 'maximum': '0.68m'},
            'weight': {'minimum': '7.44kg', 'maximum': '9.56kg'},
            'attacks': {
              'fast': [
                {'name': 'Ember', 'type': 'Fire', 'damage': 10},
                {'name': 'Scratch', 'type': 'Normal', 'damage': 6},
              ],
              'special': [
                {'name': 'Flamethrower', 'type': 'Fire', 'damage': 55},
              ],
            },
            'evolutions': [
              {
                'id': 'UG9rZW1vbjowMDU=',
                'number': '005',
                'name': 'Charmeleon',
                'image': 'https://img.pokemondb.net/artwork/charmeleon.jpg',
                'types': ['Fire'],
                'classification': 'Flame Pokémon',
              },
            ],
          }
        }
      };

      final http = _FakeHttpClient(fakePayload);
      final ds = DefaultPokemonRemoteDataSource(http);

      final detail = await ds.fetchPokemonDetail('Charmander');

      expect(detail, isA<PokemonDetailDto>());
      expect(detail.name, 'Charmander');
      expect(detail.fastAttacks.first.name, 'Ember');
      expect(() => detail.types.add('X'), throwsUnsupportedError);
    });
  });
}
