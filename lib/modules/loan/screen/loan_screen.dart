import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/routers/app_router.dart';

class LoanView extends StatelessWidget {
  const LoanView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoanController lc = Get.put(LoanController());

    return Scaffold(
      backgroundColor: const Color(0xffdde6ea),
      appBar: AppBar(title: const Text("Loan Module"), backgroundColor: const Color(0xffdde6ea), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Amount Selector --------
              const Text("Loan Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Slider(
                value: lc.amount.value,
                min: lc.minAmount,
                max: lc.maxAmount,
                onChanged: (v) => lc.changeAmount(v),
              ),

              Center(
                child: Text(
                  "₱ ${lc.amount.value.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              // ------- Circle Progress ----------
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // -------- CIRCLE WITH BONUS + DOT ----------
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: CircularProgressIndicator(
                        value: (lc.amount.value - lc.minAmount) / (lc.maxAmount - lc.minAmount),
                        strokeWidth: 12,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Loan Amount"),
                        Text(
                          "₱ ${lc.amount.value.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // -------- Period Selector --------
              const Text("Loan Period", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Wrap(
                spacing: 10,
                children: [4, 12, 24, 36].map((m) {
                  return ChoiceChip(
                    label: Text("$m months"),
                    selected: lc.selectedPeriod.value == m,
                    onSelected: (_) => lc.setPeriod(m),
                  );
                }).toList(),
              ),

              const SizedBox(height: 35),

              // -------- Calculation Container --------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Loan Amount", "₱ ${lc.amount.value.toStringAsFixed(0)}"),
                    _infoRow("Principal", "₱ ${lc.principal.value.toStringAsFixed(2)}"),
                    _infoRow("Interest Rate", "0.5% per month"),
                    _infoRow("Interest Amount", "₱ ${lc.interestAmount.value.toStringAsFixed(2)}"),
                    _infoRow("Total Payment", "₱ ${lc.paymentAmount.value.toStringAsFixed(2)}"),
                    _infoRow("Disbursement", "${lc.disbursementDate.value.toLocal()}".split(' ')[0]),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // -------- Terms & Condition --------
              Row(
                children: [
                  Checkbox(value: lc.agreeTerms.value, onChanged: (v) => lc.agreeTerms.value = v ?? false),
                  const Expanded(child: Text("I agree to the Terms and Conditions")),
                ],
              ),

              const SizedBox(height: 20),

              // -------- Request Loan Button --------
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: lc.agreeTerms.value
                        ? () async {
                            // Show Flutter native dialog
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Loan"),
                                  content: const Text("Are you sure you want to request this loan?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => context.go('/upload-id'),
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                );
                              },
                            );

                            // If user confirmed, navigate to next screen
                            if (confirm == true) {
                              Get.toNamed("/upload-id"); // Safe navigation with GetX
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Request Loan"),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
