import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

class AccountProfileScreen extends StatelessWidget {
  AccountProfileScreen({super.key});

  final ProfileController pc = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Account Profile"), elevation: 0),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- WELCOME HEADER ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text(
                    '${pc.user.value.fullName}!',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---- MENU LIST ----
            _menuItem(
              icon: Icons.person,
              title: "Personal Information",
              onTap: () => context.push("/personal-information"),
            ),

            _menuItem(icon: Icons.wallet, title: "Limits", onTap: () => Get.toNamed("/limits")),

            _menuItem(icon: Icons.settings, title: "Settings", onTap: () => Get.toNamed("/settings")),

            _menuItem(icon: Icons.support_agent, title: "Help Center", onTap: () => Get.toNamed("/help-center")),

            _menuItem(icon: Icons.description, title: "Terms & Conditions", onTap: () => Get.toNamed("/terms")),

            const SizedBox(height: 20),

            // ---- LOGOUT BUTTON ----
            // ElevatedButton(
            //   onPressed: pc.logout,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.red,
            //     minimumSize: const Size(double.infinity, 50),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //   ),
            //   child: const Text("Logout"),
            // ),
            colorfulLogoutButton(() => pc.logout()),

            const SizedBox(height: 20),

            // ---- APP VERSION ----
            Center(
              child: Text("Version: ${pc.appVersion.value}", style: TextStyle(color: Colors.grey.shade600)),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Reusable Menu Item Widget ----
  Widget _menuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget colorfulLogoutButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6F61), // Coral red
              Color(0xFFFF8C42), // Orange
              Color(0xFFFFC857), // Yellow
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.white, size: 26),
            SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
