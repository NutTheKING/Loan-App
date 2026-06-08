import 'package:flutter/material.dart';

class CustomInforowWidget extends StatelessWidget {
  const CustomInforowWidget({super.key, required this.label, required this.value});

  final String label;final String value;

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  
  }
}