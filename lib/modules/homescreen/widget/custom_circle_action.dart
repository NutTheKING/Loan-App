import 'package:flutter/material.dart';

class CustomeCircleAction extends StatelessWidget {
  const CustomeCircleAction({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.cyanAccent,
          ),
          child: Icon(icon, size: 26, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
