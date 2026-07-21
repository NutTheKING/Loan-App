import 'package:flutter/material.dart';

class CustomUploadButtonWidget extends StatelessWidget {
  const CustomUploadButtonWidget({
    super.key,
    required this.label,
    required this.onUpload,
    required this.isUploaded,
  });

  final String label;
  final VoidCallback onUpload;
  final bool isUploaded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onUpload,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUploaded ? Icons.check_circle : Icons.upload_file),
            const SizedBox(width: 8),
            Text(isUploaded ? '$label selected' : label),
          ],
        ),
      ),
    );
  }
}
