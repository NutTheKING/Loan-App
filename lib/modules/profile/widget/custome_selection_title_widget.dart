import 'package:flutter/material.dart';

class CustomeSelectionTitleWidget extends StatelessWidget {
  const CustomeSelectionTitleWidget({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title ?? '',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}
