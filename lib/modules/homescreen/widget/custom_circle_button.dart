import 'package:flutter/material.dart';

class CustomCircleButton extends StatelessWidget {
  const CustomCircleButton({
    super.key,
    required this.label,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final double size;
  final double iconSize;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
            child: Icon(icon, size: iconSize * 1, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
