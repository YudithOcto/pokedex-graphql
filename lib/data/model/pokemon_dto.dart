import 'package:equatable/equatable.dart';

class PokemonDto extends Equatable {
  final String id;
  final String name;
  final String image;
  final List<String> types;

  const PokemonDto._({
    required this.id,
    required this.name,
    required this.image,
    required this.types,
  });

  factory PokemonDto({
    required String id,
    required String name,
    required String image,
    required List<String> types,
  }) {
    return PokemonDto._(
      id: id,
      name: name,
      image: image,
      types: List.unmodifiable(types),
    );
  }

  @override
  List<Object?> get props => [id, name, image, types];

  factory PokemonDto.fromJson(Map<String, dynamic> json) {
    return PokemonDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      types:
          (json['types'] as List?)?.map((e) => e as String).toList() ??
          const [],
    );
  }
}
