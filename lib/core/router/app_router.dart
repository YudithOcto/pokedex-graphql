import 'package:go_router/go_router.dart';
import 'package:pokemondex/ui/detail/pokemon_detail_screen.dart';
import 'package:pokemondex/ui/list/pokemon_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'pokemon_list',
        builder: (context, state) => const PokemonListScreen(),
      ),
      GoRoute(
        path: '/pokemon/:id',
        name: 'pokemon_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PokemonDetailScreen(
            pokemonId: id,
          );
        },
      ),
    ],
  );
}
