import 'package:flutter/material.dart';

class CustomContractTextWidget extends StatelessWidget {
  const CustomContractTextWidget({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text ?? '', style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
    );
  }
}
