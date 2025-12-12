import 'package:flutter/material.dart';

class CustomContractRowWidget extends StatelessWidget {
  const CustomContractRowWidget({super.key, this.label, this.value});

  final String? label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label ?? '', style: const TextStyle(color: Colors.black54)),
          Text(value ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
