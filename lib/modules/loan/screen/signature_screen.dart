import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatelessWidget {
  final LoanController lc = Get.put(LoanController());

  final double loanAmount;
  final int period;

  SignatureScreen({super.key, required this.loanAmount, required this.period});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loan Signature")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------- Loan Summary -------
            Text(
              "Loan Amount: ₱ ${loanAmount.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Loan Period: $period months",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // ------- View Contract Button -------
            ElevatedButton(
              onPressed: () => _showContractDialog(context),
              child: const Text("View Contract"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Draw Your Signature:",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // ------- Signature Box -------
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onPanEnd: (_) => lc.checkIfSigned(),
                child: Signature(
                  controller: lc.signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ------- Reset Button -------
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => lc.clearSignature(),
                  child: const Text("Reset Signature"),
                ),
              ],
            ),

            const Spacer(),

            // ------- Continue Button -------
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: lc.signed.value && !lc.applicationSubmitting.value
                      ? () async {
                          final submitted = await lc.submitApplication();
                          if (submitted && context.mounted) {
                            context.go('/home');
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: lc.applicationSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Submit application'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showContractDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Loan Contract",
      content: SizedBox(
        height: 380,
        width: 300,
        child: SingleChildScrollView(
          child: Text("""
LOAN AGREEMENT

1. Borrower agrees to repay the loan amount with interest.
2. Payment shall be made monthly.
3. Failure to pay will result in penalties.
4. Borrower confirms all personal information is accurate.
5. Borrower authorizes verification of documents.

Thank you.
""", style: const TextStyle(fontSize: 14)),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text("Close"),
      ),
    );
  }
}
