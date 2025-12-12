import 'package:flutter/material.dart';

class CustomSummaryRowWidget extends StatelessWidget {
  const CustomSummaryRowWidget({super.key, this.label, this.value});

  final String? label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label ?? '', style: const TextStyle(color: Colors.black54)),
          Text(value ?? ' ', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
