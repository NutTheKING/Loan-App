import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/upload_image_controller.dart';

class UploadScreen extends StatelessWidget {
  final UploadController uc = Get.put(UploadController());

  UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Documents")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _uploadButton("Front ID", () => uc.setFrontId("front_id.png")),
            _uploadButton("Back ID", () => uc.setBackId("back_id.png")),
            _uploadButton("Selfie", () => uc.setSelfie("selfie.png")),
            const SizedBox(height: 30),
            Obx(
              () => ElevatedButton(
                onPressed: uc.allUploaded() ? () => context.go("/personal-info") : null,
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadButton(String label, VoidCallback onUpload) {
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
