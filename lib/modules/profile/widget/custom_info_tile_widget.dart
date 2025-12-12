import 'package:flutter/material.dart';

class CustomInfoTileWidget extends StatelessWidget {
  const CustomInfoTileWidget({super.key, this.title, this.value});

  final String? title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title ?? '', style: const TextStyle(color: Colors.black54)),
          Text(value ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
