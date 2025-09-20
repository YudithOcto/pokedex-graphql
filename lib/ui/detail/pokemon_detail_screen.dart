import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemondex/common/image_loader.dart';
import 'package:pokemondex/common/pokemon_helper.dart';
import 'package:pokemondex/common/type_badge.dart';
import 'package:pokemondex/core/custom_text_style.dart';
import 'package:pokemondex/core/di.dart';
import 'package:pokemondex/ui/detail/bloc/pokemon_detail_bloc.dart';

import 'bloc/pokemon_detail_event.dart';
import 'bloc/pokemon_detail_state.dart';

class PokemonDetailScreen extends StatelessWidget {
  final String pokemonId;

  const PokemonDetailScreen({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) =>
            PokemonDetailBloc(sl())..add(LoadPokemonDetail(pokemonId)),
        child: BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
          builder: (context, state) {
            if (state is PokemonDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PokemonDetailLoaded) {
              final p = state.detail;
              return PokemonWidget(
                name: p.name,
                number: p.number,
                imageUrl: p.imageUrl,
                types: p.types,
                classification: p.classification,
                minHeight: p.minHeight,
                maxHeight: p.maxHeight,
                minWeight: p.minWeight,
                maxWeight: p.maxWeight,
                weaknesses: p.weaknesses,
                resistant: p.resistant,
                evolutions: p.evolutions,
                evolutionRequirement: p.evolutionRequirement,
                fastAttacks: p.fastAttacks,
                specialAttacks: p.specialAttacks,
                primaryColor: pokemonTypeFromString(p.types.first)?.color,
              );
            } else if (state is PokemonDetailError) {
              return Center(
                child: Text(
                  "Error: ${state.message}",
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class PokemonWidget extends StatelessWidget {
  final String name;
  final String number;
  final String imageUrl;
  final List<String> types;
  final Color? primaryColor;

  final String classification;
  final String minHeight;
  final String maxHeight;
  final String minWeight;
  final String maxWeight;
  final List<String> weaknesses;
  final List<String> resistant;

  final List<Map<String, String>> evolutions;
  final String evolutionRequirement;

  final List<Map<String, dynamic>> fastAttacks;
  final List<Map<String, dynamic>> specialAttacks;

  const PokemonWidget({
    super.key,
    required this.name,
    required this.number,
    required this.imageUrl,
    required this.types,
    required this.classification,
    required this.minHeight,
    required this.maxHeight,
    required this.minWeight,
    required this.maxWeight,
    required this.weaknesses,
    required this.evolutions,
    required this.evolutionRequirement,
    required this.fastAttacks,
    required this.specialAttacks,
    required this.resistant,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: InkWell(
          onTap: () {
            context.pop();
          },
          child: Icon(Icons.adaptive.arrow_back, color: Colors.white),
        ),
        titleSpacing: 0.0,
        title: Text(
          name,
          style: CustomTextStyle.headline1.copyWith(color: Colors.white),
        ),
        actions: [
          Text(
            "#$number",
            style: CustomTextStyle.headline3.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 12.0),
        ],
      ),
      backgroundColor: primaryColor,
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: types
                  .map(
                    (t) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/types/${t.toLowerCase()}.svg",
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t,
                            style: CustomTextStyle.body3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Image.network(imageUrl, height: 150)),
          const SizedBox(height: 16),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(text: "About"),
                          Tab(text: "Evolution"),
                          Tab(text: "Moves"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAboutTab(context),
                            _buildEvolutionTab(),
                            _buildMovesTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoRow("Classification", classification),
        _buildInfoRow("Height", "$minHeight - $maxHeight"),
        _buildInfoRow("Weight", "$minWeight - $maxWeight"),

        const SizedBox(height: 12),
        Text("Weaknesses", style: CustomTextStyle.headline5),
        const SizedBox(height: 8),
        Wrap(children: weaknesses.map((t) => TypeBadge(type: t)).toList()),

        const SizedBox(height: 12),
        Text("Resistant", style: CustomTextStyle.headline5),
        const SizedBox(height: 8),
        Wrap(children: resistant.map((t) => TypeBadge(type: t)).toList()),
      ],
    );
  }

  Widget _buildEvolutionTab() {
    if (evolutions.isEmpty) {
      return Center(
        child: Text("No evolutions", style: CustomTextStyle.headline5),
      );
    }

    // Insert the current Pokémon as the first step
    final fullChain = [
      {"name": name, "image": imageUrl, "requirement": null},
      ...evolutions,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (evolutionRequirement.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "Requires: $evolutionRequirement",
              style: CustomTextStyle.headline5,
            ),
          ),

        // Evolution chain row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < fullChain.length; i++) ...[
              Column(
                children: [
                  ImageLoader(
                    imageUrl: fullChain[i]["image"]!,
                    height: (i + 1) * 40,
                    width: (i + 1) * 40,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 4),
                  Text(fullChain[i]["name"]!, style: CustomTextStyle.body3),
                ],
              ),
              if (i < fullChain.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 24),
                ),
            ],
          ],
        ),

        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < fullChain.length - 1; i++) ...[
              Text(
                "- ${fullChain[i]["name"]} evolves into ${fullChain[i + 1]["name"]}"
                "${fullChain[i + 1]["requirement"] != null ? " ${fullChain[i + 1]["requirement"]}" : ""}.",
                style: CustomTextStyle.body3.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMovesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Fast Attacks", style: CustomTextStyle.headline5),
        ...fastAttacks.map((a) => _buildAttackCard(a)),
        const SizedBox(height: 16),
        Text("Special Attacks", style: CustomTextStyle.headline5),
        ...specialAttacks.map((a) => _buildAttackCard(a)),
      ],
    );
  }

  Widget _buildAttackCard(Map<String, dynamic> atk) {
    return Card(
      color: pokemonTypeFromString(atk["type"])?.color,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          atk["name"],
          style: CustomTextStyle.caption1.copyWith(color: Colors.white),
        ),
        subtitle: Text(
          "${atk["type"]} • Damage: ${atk["damage"]}",
          style: CustomTextStyle.caption1.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: CustomTextStyle.caption1.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.left,
              // no right alignment, keeps natural flow
              style: CustomTextStyle.body3,
            ),
          ),
        ],
      ),
    );
  }
}
