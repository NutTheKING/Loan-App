import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/custom_color_logout_button_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_menu_item_widget.dart';

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
            CustomMenuItemWidget(
              icon: Icons.person,
              title: "Personal Information",
              onTap: () => context.push("/personal-information"),
            ),

            CustomMenuItemWidget(
              icon: Icons.wallet,
              title: "Beneficiary Information",
              onTap: () => context.push("/beneficiary-information"),
            ),

            CustomMenuItemWidget(
              icon: Icons.currency_ruble,
              title: "Loan Contract",
              onTap: () => context.push("/loan-contract"),
            ),

            CustomMenuItemWidget(
              icon: Icons.calendar_month_rounded,
              title: "Payment Schedule",
              onTap: () => context.push("/payment-schedule"),
            ),

            CustomMenuItemWidget(
              icon: Icons.timer_outlined,
              title: "Transactions",
              onTap: () => context.push("/transactions"),
            ),

            CustomMenuItemWidget(icon: Icons.settings, title: "Settings", onTap: () => context.push("/settings")),

            CustomMenuItemWidget(
              icon: Icons.support_agent,
              title: "Help Center",
              onTap: () => context.push("/help-center"),
            ),

            CustomMenuItemWidget(
              icon: Icons.description,
              title: "Terms & Conditions",
              onTap: () => context.push("/term-conditions"),
            ),

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
            CustomColorLogoutButtonWidget(onTap: () => pc.logout()),

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
}
