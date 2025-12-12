import 'package:flutter/material.dart';

class CustomInfoRowWidget extends StatelessWidget {
  const CustomInfoRowWidget({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xfff7f9fb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value.isEmpty ? "---" : value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
