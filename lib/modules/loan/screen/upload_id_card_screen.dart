import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/modules/loan/widget/custom_upload_button_widget.dart';

class UploadScreen extends StatelessWidget {
  final LoanController lc = Get.put(LoanController());

  UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Documents")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            children: [
              CustomUploadButtonWidget(
                label: 'Front ID',
                isUploaded: lc.frontId.value.isNotEmpty,
                onUpload: () => lc.pickFromGallery('ID_FRONT'),
              ),
              CustomUploadButtonWidget(
                label: 'Back ID',
                isUploaded: lc.backId.value.isNotEmpty,
                onUpload: () => lc.pickFromGallery('ID_BACK'),
              ),
              CustomUploadButtonWidget(
                label: 'Selfie',
                isUploaded: lc.selfie.value.isNotEmpty,
                onUpload: () => lc.pickFromCamera('SELFIE'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: lc.allUploaded()
                    ? () => context.push('/personal-info')
                    : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _uploadButton(String label, VoidCallback onUpload) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: ElevatedButton(
  //       onPressed: onUpload,
  //       style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
  //       child: Text(label),
  //     ),
  //   );
  // }
}
