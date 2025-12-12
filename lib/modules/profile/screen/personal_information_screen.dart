import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/custom_info_tile_widget.dart';

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

              CustomInfoTileWidget(title: "Full Name", value: u.actualName),
              CustomInfoTileWidget(title: "Gender", value: u.gender),
              CustomInfoTileWidget(title: "Current Job", value: u.currentJob),
              CustomInfoTileWidget(title: "Stable Income", value: "₱ ${u.stableIncome}"),

              // ID card with masking toggle
              Row(
                children: [
                  Expanded(
                    child: CustomInfoTileWidget(title: "ID Card", value: pc.maskedId),
                  ),
                  Switch(value: u.showFullId, onChanged: (_) => pc.toggleShowId()),
                ],
              ),

              CustomInfoTileWidget(title: "Loan Purpose", value: u.loanPurpose),
              CustomInfoTileWidget(title: "Address", value: u.currentAddress),

              const SizedBox(height: 25),
              const Text("Guarantor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              CustomInfoTileWidget(title: "Name", value: u.guarantorName),
              CustomInfoTileWidget(title: "Phone", value: u.guarantorPhone),

              const SizedBox(height: 25),
              const Text("Loan Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              CustomInfoTileWidget(title: "Borrowing Amount", value: "₱ ${u.borrowingAmount} / ${u.months} Months"),
              CustomInfoTileWidget(title: "Monthly Payment", value: "₱ ${u.monthlyPayment}"),
            ],
          );
        }),
      ),
    );
  }
}
