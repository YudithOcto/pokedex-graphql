import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemondex/common/image_loader.dart';
import 'package:pokemondex/core/di.dart';
import 'package:pokemondex/domain/entity/pokemon_spec.dart';

import 'bloc/pokemon_list_bloc.dart';

class PokemonListScreen extends StatelessWidget {
  const PokemonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PokemonListBloc(sl())..add(const LoadPokemonList(20)),
      child: PokemonListWidget(),
    );
  }
}

class PokemonListWidget extends StatefulWidget {
  const PokemonListWidget({super.key});

  @override
  State<PokemonListWidget> createState() => _PokemonListWidgetState();
}

class _PokemonListWidgetState extends State<PokemonListWidget> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PokemonListBloc>().add(const LoadMorePokemon());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Creatures',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
        body: BlocBuilder<PokemonListBloc, PokemonListState>(
          builder: (context, state) {
            if (state is PokemonListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PokemonListLoaded) {
              final pokemons = state.pokemons;
              return ListView.builder(
                controller: _scrollController,
                itemCount: pokemons.length + 1,
                padding: const EdgeInsets.only(top: 0),
                itemBuilder: (context, index) {
                  if (index < pokemons.length) {
                    final pokemon = pokemons[index];
                    return InkWell(
                      onTap: () {
                        context.pushNamed(
                          'pokemon_detail',
                          pathParameters: {'id': pokemon.id},
                        );
                      },
                      child: _PokemonListTile(pokemon: pokemon),
                    );
                  } else {
                    return state.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                },
              );
            } else if (state is PokemonListError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _PokemonListTile extends StatelessWidget {
  final PokemonSpec pokemon;

  const _PokemonListTile({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ImageLoader(
          imageUrl: pokemon.image,
          width: 48.0,
          height: 48.0,
        ),
        title: Text(
          pokemon.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(pokemon.number),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: pokemon.types
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: SvgPicture.asset(
                    "assets/icons/types/${c.toLowerCase()}.svg",
                    width: 24,
                    height: 24,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
