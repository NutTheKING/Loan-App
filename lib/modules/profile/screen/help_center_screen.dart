import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/custom_support_card_widget.dart';
import 'package:loan_app/modules/profile/widget/ucstom_faq_item_widget.dart';

class HelpCenterScreen extends StatelessWidget {
  HelpCenterScreen({super.key});

  final ProfileController helpCenterCon = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help Center"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("We’re here for you 24/7", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            // 🟦 Telegram Support Card
            CustomSupportCardWidgety(
              color: const Color(0xFF1C93E3),
              icon: Icons.telegram,
              title: "Telegram Support",
              subtitle: "@LoanSupportOfficial",
              description: "Chat with our official support team directly.",
              buttonText: "Open Telegram",
              onTap: () {
                helpCenterCon.openTelegram();
              },
            ),

            const SizedBox(height: 18),

            // 🟩 LiveHelp100 Support Card
            CustomSupportCardWidgety(
              color: const Color(0xFF28C76F),
              icon: Icons.headset_mic_rounded,
              title: "LiveHelp100 – 24/7 Chat",
              subtitle: "Instant Customer Support",
              description: "Response time usually less than 1 minute.",
              buttonText: "Start Live Chat",
              onTap: () {},
            ),

            const SizedBox(height: 30),

            // FAQ Section
            const Text("Common Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            CustomFaqItemWidget(title: "How to apply for a loan?"),
            CustomFaqItemWidget(title: "Why was my loan rejected?"),
            CustomFaqItemWidget(title: "How do I repay early?"),
            CustomFaqItemWidget(title: "What documents are required?"),

            const SizedBox(height: 30),

            // Other Options
            const Text("Other Support Options", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email Support"),
              subtitle: const Text("support@loanapp.com"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Submit a Ticket"),
              subtitle: const Text("We will reply within 24 hours."),
              onTap: () {},
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
