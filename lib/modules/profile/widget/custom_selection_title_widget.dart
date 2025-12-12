import 'package:flutter/material.dart';

class CustomSelectionTitleWidget extends StatelessWidget {
  const CustomSelectionTitleWidget({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title ?? '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blueGrey),
      ),
    );
  }
}
