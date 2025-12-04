import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/auth/signup/controller/register_controller.dart';
import 'package:image_picker/image_picker.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController c = Get.put(RegisterController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFdde6ea),
      appBar: AppBar(title: Text('register'.tr)),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'full_name'.tr),
                onChanged: (v) => c.model.update((val) {
                  val?.fullName = v;
                }),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'email'.tr),
                onChanged: (v) => c.model.update((val) {
                  val?.email = v;
                }),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'id_number'.tr),
                onChanged: (v) => c.model.update((val) {
                  val?.idNumber = v;
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (f != null) c.model.update((val) => val?.profilePath = f.path);
                    },
                    icon: const Icon(Icons.photo),
                    label: Text('upload_profile'.tr),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final XFile? f = await ImagePicker().pickImage(source: ImageSource.camera);
                      if (f != null) c.model.update((val) => val?.profilePath = f.path);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed: c.isLoading.value ? null : c.submit,
                  child: c.isLoading.value ? const CircularProgressIndicator() : Text('submit'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
