import 'package:flutter/material.dart';

class CustomUploadButtonWidget extends StatelessWidget {
  const CustomUploadButtonWidget({super.key, required this.label, required this.onUpload});

 final String label;final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onUpload,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        child: Text(label),
      ),
    );
  }
}