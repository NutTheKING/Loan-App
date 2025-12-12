import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/custom_profile_header_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_selection_title_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_setting_tile_widget.dart';

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
          CustomProfileHeaderWidget(name: "tinut chan", onEdit: () {}, phone: "+855 96 234 5678"),

          SizedBox(height: 20),

          // ⚙️ Account Section
          CustomSelectionTitleWidget(title: "Account"),
          CustomSettingTileWidget(icon: Icons.person, title: "Personal Information"),
          CustomSettingTileWidget(icon: Icons.phone_android, title: "Change Phone Number"),
          CustomSettingTileWidget(icon: Icons.lock, title: "Change Password"),

          SizedBox(height: 20),

          // 🔐 Security
          CustomSelectionTitleWidget(title: "Security"),
          Obx(
            () => SwitchListTile(
              title: Text("Enable Biometric Lock"),
              secondary: Icon(Icons.fingerprint),
              value: sc.biometricEnabled.value,
              onChanged: (v) => sc.biometricEnabled.value = v,
            ),
          ),
          CustomSettingTileWidget(icon: Icons.pin, title: "Change PIN Code"),

          SizedBox(height: 20),

          // 🔔 Notifications
          CustomSelectionTitleWidget(title: "Notifications"),
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
          CustomSelectionTitleWidget(title: "Preferences"),
          CustomSettingTileWidget(icon: Icons.language, title: "Language"),
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
          CustomSelectionTitleWidget(title: "Support"),
          CustomSettingTileWidget(icon: Icons.help_center, title: "Help Center"),
          CustomSettingTileWidget(icon: Icons.support_agent, title: "Contact Support"),
          CustomSettingTileWidget(icon: Icons.description, title: "Terms & Conditions"),

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
}
