import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

class SettingsScreen extends StatelessWidget {
  final sc = Get.put(ProfileController());

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), centerTitle: true),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 🌟 Profile Header
          _profileHeader(),

          SizedBox(height: 20),

          // ⚙️ Account Section
          _sectionTitle("Account"),
          _settingsTile(Icons.person, "Personal Information"),
          _settingsTile(Icons.phone_android, "Change Phone Number"),
          _settingsTile(Icons.lock, "Change Password"),

          SizedBox(height: 20),

          // 🔐 Security
          _sectionTitle("Security"),
          Obx(
            () => SwitchListTile(
              title: Text("Enable Biometric Lock"),
              secondary: Icon(Icons.fingerprint),
              value: sc.biometricEnabled.value,
              onChanged: (v) => sc.biometricEnabled.value = v,
            ),
          ),
          _settingsTile(Icons.pin, "Change PIN Code"),

          SizedBox(height: 20),

          // 🔔 Notifications
          _sectionTitle("Notifications"),
          Obx(
            () => SwitchListTile(
              title: Text("Payment Reminders"),
              secondary: Icon(Icons.payments),
              value: sc.paymentReminder.value,
              onChanged: (v) => sc.paymentReminder.value = v,
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text("Promotions"),
              secondary: Icon(Icons.discount),
              value: sc.promotionReminder.value,
              onChanged: (v) => sc.promotionReminder.value = v,
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text("System Alerts"),
              secondary: Icon(Icons.notifications_active),
              value: sc.systemAlert.value,
              onChanged: (v) => sc.systemAlert.value = v,
            ),
          ),

          SizedBox(height: 20),

          // 🎨 Preferences
          _sectionTitle("Preferences"),
          _settingsTile(Icons.language, "Language"),
          Obx(
            () => SwitchListTile(
              title: Text("Dark Mode"),
              secondary: Icon(Icons.dark_mode),
              value: sc.isDarkMode.value,
              onChanged: (v) => sc.isDarkMode.value = v,
            ),
          ),

          SizedBox(height: 20),

          // 🛟 Support
          _sectionTitle("Support"),
          _settingsTile(Icons.help_center, "Help Center"),
          _settingsTile(Icons.support_agent, "Contact Support"),
          _settingsTile(Icons.description, "Terms & Conditions"),

          SizedBox(height: 30),

          // 🚪 Logout Button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  // 🧑‍💼 Profile Header Widget
  Widget _profileHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade200,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chan Tinut", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 5),
              Text("+855 96 234 5678", style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 8),
              TextButton(onPressed: () {}, child: Text("Edit Profile")),
            ],
          ),
        ],
      ),
    );
  }

  // 🔧 Section Title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blueGrey),
      ),
    );
  }

  // 🧱 Generic Settings Tile
  Widget _settingsTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
    );
  }
}
