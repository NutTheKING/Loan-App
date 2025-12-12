import 'package:flutter/material.dart';

class CustomSelectionTextWidget extends StatelessWidget {
  const CustomSelectionTextWidget({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Text(text ?? '', style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
    );
  }
}
