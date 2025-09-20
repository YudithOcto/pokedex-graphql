import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TypeBadge extends StatelessWidget {
  final String type;

  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final assetPath = "assets/icons/types/${type.toLowerCase()}.svg";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetPath,
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
