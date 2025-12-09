import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

class PersonalInformationScreen extends StatelessWidget {
  final ProfileController pc = Get.put(ProfileController());

  PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final u = pc.users.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------- PROFILE HEADER -------------------
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: u.profileUrl.isEmpty ? null : NetworkImage(u.profileUrl),
                      child: u.profileUrl.isEmpty ? const Icon(Icons.person, size: 45) : null,
                    ),
                    const SizedBox(height: 10),
                    Text(u.phoneNumber.isEmpty ? "No Phone" : u.phoneNumber, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              infoTile("Full Name", u.actualName),
              infoTile("Gender", u.gender),
              infoTile("Current Job", u.currentJob),
              infoTile("Stable Income", "₱ ${u.stableIncome}"),

              // ID card with masking toggle
              Row(
                children: [
                  Expanded(child: infoTile("ID Card", pc.maskedId)),
                  Switch(value: u.showFullId, onChanged: (_) => pc.toggleShowId()),
                ],
              ),

              infoTile("Loan Purpose", u.loanPurpose),
              infoTile("Address", u.currentAddress),

              const SizedBox(height: 25),
              const Text("Guarantor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              infoTile("Name", u.guarantorName),
              infoTile("Phone", u.guarantorPhone),

              const SizedBox(height: 25),
              const Text("Loan Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              infoTile("Borrowing Amount", "₱ ${u.borrowingAmount} / ${u.months} Months"),
              infoTile("Monthly Payment", "₱ ${u.monthlyPayment}"),
            ],
          );
        }),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
