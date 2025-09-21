import 'package:equatable/equatable.dart';
import 'package:pokemondex/data/model/pokemon_dto.dart';

class PokemonDetailSpec extends Equatable {
  final String name;
  final String number;
  final String imageUrl;
  final List<String> types;

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

  const PokemonDetailSpec({
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
    required this.resistant,
    required this.evolutions,
    required this.evolutionRequirement,
    required this.fastAttacks,
    required this.specialAttacks,
  });

  @override
  List<Object?> get props => [
    name,
    number,
    imageUrl,
    types,
    classification,
    minHeight,
    maxHeight,
    minWeight,
    maxWeight,
    weaknesses,
    resistant,
    evolutions,
    evolutionRequirement,
    fastAttacks,
    specialAttacks,
  ];
}

extension PokemonMapper on PokemonDto {
  PokemonDetailSpec toEntity() {
    return PokemonDetailSpec(
      name: name,
      number: number,
      imageUrl: image,
      types: types,
      classification: classification,
      minHeight: height?.minimum ?? "",
      maxHeight: height?.maximum ?? "",
      minWeight: weight?.minimum ?? "",
      maxWeight: weight?.maximum ?? "",
      weaknesses: weaknesses,
      resistant: resistant,
      evolutions: evolutions
          .map((data) => {"name": data.name, "image": data.image})
          .toList(),
      evolutionRequirement: evolutionRequirements?.name ?? "",
      fastAttacks: fastAttacks
          .map(
            (data) => {
              "name": data.name,
              "type": data.type,
              "damage": data.damage,
            },
          )
          .toList(),
      specialAttacks: specialAttacks
          .map(
            (data) => {
              "name": data.name,
              "type": data.type,
              "damage": data.damage,
            },
          )
          .toList(),
    );
  }
}
