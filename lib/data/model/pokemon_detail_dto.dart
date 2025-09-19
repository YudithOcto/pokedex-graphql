import 'package:equatable/equatable.dart';

class PokemonDetailDto extends Equatable {
  final String id;
  final String number;
  final String name;
  final String image;
  final List<String> types;
  final String classification;

  final RangeDto? height;
  final RangeDto? weight;

  final List<AttackDto> fastAttacks;
  final List<AttackDto> specialAttacks;
  final List<EvolutionDto> evolutions;

  const PokemonDetailDto._({
    required this.id,
    required this.number,
    required this.name,
    required this.image,
    required this.types,
    required this.classification,
    required this.height,
    required this.weight,
    required this.fastAttacks,
    required this.specialAttacks,
    required this.evolutions,
  });

  factory PokemonDetailDto({
    required String id,
    required String number,
    required String name,
    required String image,
    required List<String> types,
    required String classification,
    RangeDto? height,
    RangeDto? weight,
    List<AttackDto> fastAttacks = const [],
    List<AttackDto> specialAttacks = const [],
    List<EvolutionDto> evolutions = const [],
  }) =>
      PokemonDetailDto._(
        id: id,
        number: number,
        name: name,
        image: image,
        types: List.unmodifiable(types),
        classification: classification,
        height: height,
        weight: weight,
        fastAttacks: List.unmodifiable(fastAttacks),
        specialAttacks: List.unmodifiable(specialAttacks),
        evolutions: List.unmodifiable(evolutions),
      );

  factory PokemonDetailDto.fromJson(Map<String, dynamic> json) {
    final attacks = json['attacks'] as Map<String, dynamic>?;

    final fast = (attacks?['fast'] as List? ?? const <dynamic>[])
        .map((e) => AttackDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final special = (attacks?['special'] as List? ?? const <dynamic>[])
        .map((e) => AttackDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final evolutions = (json['evolutions'] as List? ?? const <dynamic>[])
        .map((e) => EvolutionDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PokemonDetailDto(
      id: json['id'] as String? ?? '',
      number: json['number'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      types: (json['types'] as List?)?.map((e) => e as String).toList() ?? const <String>[],
      classification: json['classification'] as String? ?? '',
      height: (json['height'] is Map)
          ? RangeDto.fromJson(Map<String, dynamic>.from(json['height'] as Map))
          : null,
      weight: (json['weight'] is Map)
          ? RangeDto.fromJson(Map<String, dynamic>.from(json['weight'] as Map))
          : null,
      fastAttacks: fast,
      specialAttacks: special,
      evolutions: evolutions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    number,
    name,
    image,
    types,
    classification,
    height,
    weight,
    fastAttacks,
    specialAttacks,
    evolutions,
  ];
}

class RangeDto extends Equatable {
  final String minimum;
  final String maximum;

  const RangeDto({required this.minimum, required this.maximum});

  factory RangeDto.fromJson(Map<String, dynamic> json) => RangeDto(
    minimum: json['minimum'] as String? ?? '',
    maximum: json['maximum'] as String? ?? '',
  );

  @override
  List<Object?> get props => [minimum, maximum];
}

class AttackDto extends Equatable {
  final String name;
  final String type;
  final int damage;

  const AttackDto({
    required this.name,
    required this.type,
    required this.damage,
  });

  factory AttackDto.fromJson(Map<String, dynamic> json) => AttackDto(
    name: json['name'] as String? ?? '',
    type: json['type'] as String? ?? '',
    damage: (json['damage'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [name, type, damage];
}

class EvolutionDto extends Equatable {
  final String id;
  final String number;
  final String name;
  final String image;
  final List<String> types;
  final String classification;

  const EvolutionDto._({
    required this.id,
    required this.number,
    required this.name,
    required this.image,
    required this.types,
    required this.classification,
  });

  factory EvolutionDto({
    required String id,
    required String number,
    required String name,
    required String image,
    required List<String> types,
    required String classification,
  }) =>
      EvolutionDto._(
        id: id,
        number: number,
        name: name,
        image: image,
        types: List.unmodifiable(types),
        classification: classification,
      );

  factory EvolutionDto.fromJson(Map<String, dynamic> json) => EvolutionDto(
    id: json['id'] as String? ?? '',
    number: json['number'] as String? ?? '',
    name: json['name'] as String? ?? '',
    image: json['image'] as String? ?? '',
    types: (json['types'] as List?)?.map((e) => e as String).toList() ?? const <String>[],
    classification: json['classification'] as String? ?? '',
  );

  @override
  List<Object?> get props => [id, number, name, image, types, classification];
}
