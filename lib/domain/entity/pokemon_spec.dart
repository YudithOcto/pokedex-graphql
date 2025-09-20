import 'package:equatable/equatable.dart';

class PokemonSpec extends Equatable {
  @override
  List<Object?> get props => [id, name, number, image, types];

  final String name;
  final String id;
  final String number;
  final String image;
  final List<String> types;

  const PokemonSpec({
    required this.id,
    required this.name,
    required this.number,
    required this.image,
    required this.types,
  });
}
