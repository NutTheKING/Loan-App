import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/bank_account_controller.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';

class BankAccountScreen extends StatelessWidget {
  final BankAccountController bc = Get.put(BankAccountController());
  final LoanController lc = Get.put(LoanController());

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
                onPressed: bc.isValid
                    ? () {
                        final bankInfo = bc.buildModel();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            title: const Text("Verification Complete"),
                            content: const Text("Your bank account has been verified successfully."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // close dialog
                                  context.push(
                                    "/signature",
                                    extra: {"amount": lc.amount.value, "period": lc.selectedPeriod.value},
                                  );
                                },
                                child: const Text("Continue"),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
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
      child: TextField(
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (v) => controller.value = v,
      ),
    );
  }
}
