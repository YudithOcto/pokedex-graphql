import 'package:flutter/material.dart';

enum PokemonType {
  bug,
  dragon,
  electric,
  fairy,
  fighting,
  fire,
  flying,
  ghost,
  grass,
  ground,
  ice,
  normal,
  poison,
  psychic,
  rock,
  steel,
  water,
}

extension PokemonTypeColor on PokemonType {
  Color get color {
    switch (this) {
      case PokemonType.bug:
        return const Color(0xFFA6B91A);
      case PokemonType.dragon:
        return const Color(0xFF6F35FC);
      case PokemonType.electric:
        return const Color(0xFFF7D02C);
      case PokemonType.fairy:
        return const Color(0xFFD685AD);
      case PokemonType.fighting:
        return const Color(0xFFC22E28);
      case PokemonType.fire:
        return const Color(0xFFEE8130);
      case PokemonType.flying:
        return const Color(0xFFA98FF3);
      case PokemonType.ghost:
        return const Color(0xFF735797);
      case PokemonType.grass:
        return const Color(0xFF7AC74C);
      case PokemonType.ground:
        return const Color(0xFFE2BF65);
      case PokemonType.ice:
        return const Color(0xFF96D9D6);
      case PokemonType.normal:
        return const Color(0xFFA8A77A);
      case PokemonType.poison:
        return const Color(0xFFA33EA1);
      case PokemonType.psychic:
        return const Color(0xFFF95587);
      case PokemonType.rock:
        return const Color(0xFFB6A136);
      case PokemonType.steel:
        return const Color(0xFFB7B7CE);
      case PokemonType.water:
        return const Color(0xFF6390F0);
    }
  }
}

/// Helper to parse from API string to enum
PokemonType? pokemonTypeFromString(String type) {
  return PokemonType.values.firstWhere(
        (e) => e.name.toLowerCase() == type.toLowerCase(),
    orElse: () => PokemonType.normal, // fallback
  );
}
