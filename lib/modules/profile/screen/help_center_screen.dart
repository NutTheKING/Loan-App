import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

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
            _supportCard(
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
            _supportCard(
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

            _faqItem("How to apply for a loan?"),
            _faqItem("Why was my loan rejected?"),
            _faqItem("How do I repay early?"),
            _faqItem("What documents are required?"),

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

  // 🟦 Support Card Widget
  Widget _supportCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 14),

          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),

          const SizedBox(height: 10),
          Text(description, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(buttonText, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ❓ FAQ Item
  Widget _faqItem(String title) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(title: Text(title), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () {}),
    );
  }
}
