import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/custom_info_row_widget.dart';

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

                    CustomInfoRowWidget(label: "Full Name", value: b.fullName),
                    CustomInfoRowWidget(label: "Phone Number", value: b.phoneNumber),

                    Row(
                      children: [
                        Expanded(
                          child: CustomInfoRowWidget(label: "ID Card", value: bc.maskedId),
                        ),
                        Switch(value: b.showFullId, onChanged: (_) => bc.toggleId()),
                      ],
                    ),

                    CustomInfoRowWidget(label: "Relationship", value: b.relationship),
                    CustomInfoRowWidget(label: "Address", value: b.address),
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
}
