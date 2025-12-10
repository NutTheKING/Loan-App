import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

class BeneficiaryScreen extends StatelessWidget {
  BeneficiaryScreen({super.key});
  final ProfileController bc = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6f9),
      appBar: AppBar(
        title: const Text("Beneficiary Information"),
        elevation: 0,
        backgroundColor: const Color(0xfff3f6f9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final b = bc.b.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- CARD ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Primary Beneficiary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 12),

                    infoRow("Full Name", b.fullName),
                    infoRow("Phone Number", b.phoneNumber),

                    Row(
                      children: [
                        Expanded(child: infoRow("ID Card", bc.maskedId)),
                        Switch(value: b.showFullId, onChanged: (_) => bc.toggleId()),
                      ],
                    ),

                    infoRow("Relationship", b.relationship),
                    infoRow("Address", b.address),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- BUTTON ----------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Save Beneficiary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xfff7f9fb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value.isEmpty ? "---" : value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
