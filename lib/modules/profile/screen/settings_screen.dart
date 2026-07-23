import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return AccountPage(
      title: 'Settings',
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            AccountSection(
              title: 'Appearance',
              subtitle: 'Choose the look that is most comfortable for you.',
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Use a darker color scheme.'),
                  value: controller.isDarkMode.value,
                  onChanged: controller.setDarkMode,
                ),
              ],
            ),
            const SizedBox(height: 14),
            AccountSection(
              title: 'Notifications',
              subtitle: 'Control the alerts you want to receive.',
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.payments_outlined),
                  title: const Text('Payment reminders'),
                  subtitle: const Text('Upcoming installment reminders.'),
                  value: controller.paymentReminder.value,
                  onChanged: controller.setPaymentReminder,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Application updates'),
                  subtitle: const Text(
                    'Approval, rejection, and system alerts.',
                  ),
                  value: controller.systemAlert.value,
                  onChanged: controller.setSystemAlert,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.campaign_outlined),
                  title: const Text('Product updates'),
                  subtitle: const Text('Optional product and reward news.'),
                  value: controller.promotionReminder.value,
                  onChanged: controller.setPromotionReminder,
                ),
              ],
            ),
            const SizedBox(height: 14),
            AccountSection(
              title: 'Security',
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.phonelink_lock_outlined),
                  title: Text('Single-device session'),
                  subtitle: Text(
                    'Signing in on a new device ends the previous active session.',
                  ),
                  trailing: Icon(Icons.verified_rounded),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Remember biometric preference'),
                  subtitle: const Text(
                    'Saved for devices that support biometric sign-in.',
                  ),
                  value: controller.biometricEnabled.value,
                  onChanged: controller.setBiometric,
                ),
              ],
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
