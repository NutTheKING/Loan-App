import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/bank_account_controller.dart';

class BankAccountScreen extends StatelessWidget {
  final BankAccountController bc = Get.put(BankAccountController());

  BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bank Account Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _textField("Beneficiary Bank", bc.beneficiaryBank),
            _textField("Account Name", bc.accountName),
            _textField("Account Number", bc.accountNumber, keyboard: TextInputType.number),
            const SizedBox(height: 30),
            Obx(
              () => ElevatedButton(
                onPressed: bc.isValid()
                    ? () {
                        final bankInfo = bc.buildModel();

                        // Show verification complete popup
                        Get.defaultDialog(
                          title: "Verification Complete",
                          middleText: "Your bank account has been verified successfully.",
                          textConfirm: "Continue",
                          onConfirm: () {
                            Get.back(); // Close dialog
                            context.go("/dashboard"); // Navigate to final screen
                          },
                          barrierDismissible: false,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, Rx<String> controller, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() {
        return TextField(
          keyboardType: keyboard,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) => controller.value = v,
        );
      }),
    );
  }
}
