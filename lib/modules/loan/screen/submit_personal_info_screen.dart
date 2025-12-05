import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/personal_info_controller.dart';

class PersonalInfoScreen extends StatelessWidget {
  final PersonalInfoController pc = Get.put(PersonalInfoController());

  PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _textField("Actual Name", pc.actualName),
            _textField("ID Card Number", pc.idCardNo, keyboard: TextInputType.number),
            _textField("Current Job", pc.currentJob),
            _dropdownField("Gender", ["Male", "Female", "Other"], pc.gender),
            _textField("Stable Income", pc.stableIncome),
            _textField("Loan Purpose", pc.loanPurpose),
            _textField("Current Address", pc.currentAddress),
            _textField("Guarantor Name", pc.guarantorName),
            _textField("Guarantor Phone", pc.guarantorPhone, keyboard: TextInputType.phone),
            const SizedBox(height: 30),
            // Only button needs Obx
            Obx(
              () => ElevatedButton(
                onPressed: pc.isValid() ? () => context.push("/bank-account") : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, Rx<dynamic> controller, {TextInputType keyboard = TextInputType.text}) {
    // Use GetX builder for reactive TextField safely
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GetX<PersonalInfoController>(
        builder: (_) {
          return TextField(
            keyboardType: keyboard,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) {
              if (controller is RxString) controller.value = v;
              if (controller is RxDouble) controller.value = double.tryParse(v) ?? 0;
            },
            controller: TextEditingController(
              text: controller.value is String ? controller.value : controller.value.toString(),
            ),
          );
        },
      ),
    );
  }

  Widget _dropdownField(String label, List<String> options, Rx<String> controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GetX<PersonalInfoController>(
        builder: (_) {
          return DropdownButtonFormField<String>(
            initialValue: controller.value.isEmpty ? null : controller.value,
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => controller.value = v ?? '',
          );
        },
      ),
    );
  }
}
