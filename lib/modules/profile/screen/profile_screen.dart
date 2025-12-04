import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController c = Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => ListTile(
                title: Text(c.fullName.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.email.value),
              ),
            ),
            Obx(
              () => ListTile(title: const Text('DOB'), subtitle: Text(c.dob.value.toIso8601String().split('T').first)),
            ),
            Obx(() => ListTile(title: const Text('ID Number'), subtitle: Text(c.idNumber.value))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("============Test=========");
                c.logout();
              },
              child: Text('logout'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
