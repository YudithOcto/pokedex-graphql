import 'package:equatable/equatable.dart';

class PokemonDto extends Equatable {
  final String id;
  final String name;
  final String number;
  final String image;
  final List<String> types;

  // Detail fields
  final String classification;
  final RangeDto? weight;
  final RangeDto? height;
  final List<String> resistant;
  final List<AttackDto> fastAttacks;
  final List<AttackDto> specialAttacks;
  final List<String> weaknesses;
  final double fleeRate;
  final int maxCP;
  final int maxHP;
  final List<EvolutionDto> evolutions;
  final EvolutionRequirementDto? evolutionRequirements;

  const PokemonDto._({
    required this.id,
    required this.name,
    required this.number,
    required this.image,
    required this.types,
    required this.classification,
    required this.weight,
    required this.height,
    required this.resistant,
    required this.fastAttacks,
    required this.specialAttacks,
    required this.weaknesses,
    required this.fleeRate,
    required this.maxCP,
    required this.maxHP,
    required this.evolutions,
    required this.evolutionRequirements,
  });

  factory PokemonDto({
    required String id,
    required String name,
    required String number,
    required String image,
    required List<String> types,
    String classification = '',
    RangeDto? weight,
    RangeDto? height,
    List<String> resistant = const [],
    List<AttackDto> fastAttacks = const [],
    List<AttackDto> specialAttacks = const [],
    List<String> weaknesses = const [],
    double fleeRate = 0,
    int maxCP = 0,
    int maxHP = 0,
    List<EvolutionDto> evolutions = const [],
    EvolutionRequirementDto? evolutionRequirements,
  }) {
    return PokemonDto._(
      id: id,
      name: name,
      number: number,
      image: image,
      types: List.unmodifiable(types),
      classification: classification,
      weight: weight,
      height: height,
      resistant: List.unmodifiable(resistant),
      fastAttacks: List.unmodifiable(fastAttacks),
      specialAttacks: List.unmodifiable(specialAttacks),
      weaknesses: List.unmodifiable(weaknesses),
      fleeRate: fleeRate,
      maxCP: maxCP,
      maxHP: maxHP,
      evolutions: List.unmodifiable(evolutions),
      evolutionRequirements: evolutionRequirements,
    );
  }

  factory PokemonDto.fromJson(Map<String, dynamic> json) {
    final attacks = json['attacks'] as Map<String, dynamic>?;

    return PokemonDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      number: json['number'] as String? ?? '',
      image: json['image'] as String? ?? '',
      types: (json['types'] as List?)?.map((e) => e as String).toList() ?? const [],
      classification: json['classification'] as String? ?? '',
      weight: json['weight'] != null ? RangeDto.fromJson(json['weight']) : null,
      height: json['height'] != null ? RangeDto.fromJson(json['height']) : null,
      resistant: (json['resistant'] as List?)?.map((e) => e as String).toList() ?? const [],
      fastAttacks: (attacks?['fast'] as List?)
          ?.map((e) => AttackDto.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          const [],
      specialAttacks: (attacks?['special'] as List?)
          ?.map((e) => AttackDto.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          const [],
      weaknesses: (json['weaknesses'] as List?)?.map((e) => e as String).toList() ?? const [],
      fleeRate: (json['fleeRate'] as num?)?.toDouble() ?? 0,
      maxCP: json['maxCP'] as int? ?? 0,
      maxHP: json['maxHP'] as int? ?? 0,
      evolutions: (json['evolutions'] as List?)
          ?.map((e) => EvolutionDto.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          const [],
      evolutionRequirements: json['evolutionRequirements'] != null
          ? EvolutionRequirementDto.fromJson(Map<String, dynamic>.from(json['evolutionRequirements']))
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    number,
    image,
    types,
    classification,
    weight,
    height,
    resistant,
    fastAttacks,
    specialAttacks,
    weaknesses,
    fleeRate,
    maxCP,
    maxHP,
    evolutions,
    evolutionRequirements,
  ];
}

class RangeDto extends Equatable {
  final String minimum;
  final String maximum;

  const RangeDto({required this.minimum, required this.maximum});

  factory RangeDto.fromJson(Map<String, dynamic> json) {
    return RangeDto(
      minimum: json['minimum'] as String? ?? '',
      maximum: json['maximum'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [minimum, maximum];
}

class AttackDto extends Equatable {
  final String name;
  final String type;
  final int damage;

  const AttackDto({required this.name, required this.type, required this.damage});

  factory AttackDto.fromJson(Map<String, dynamic> json) {
    return AttackDto(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      damage: json['damage'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, type, damage];
}

class EvolutionDto extends Equatable {
  final String name;
  final String image;

  const EvolutionDto({required this.name, required this.image});

  factory EvolutionDto.fromJson(Map<String, dynamic> json) {
    return EvolutionDto(
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [name];
}

class EvolutionRequirementDto extends Equatable {
  final String name;
  final int amount;

  const EvolutionRequirementDto({required this.name, required this.amount});

  factory EvolutionRequirementDto.fromJson(Map<String, dynamic> json) {
    return EvolutionRequirementDto(
      name: json['name'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, amount];
}
