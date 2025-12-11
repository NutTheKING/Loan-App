import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/go_save_account/controller/open_go_save_controller.dart';

class GoSaveScreen extends StatelessWidget {
  final GoSaveController gc = Get.put(GoSaveController());

  GoSaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Open Go-Save Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Initial Deposit",
                prefixText: "₱ ",
                border: OutlineInputBorder(),
              ),
              onChanged: gc.changeDeposit,
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: gc.selectedPlan.value,
                decoration: const InputDecoration(labelText: "Select Plan", border: OutlineInputBorder()),
                items: gc.planInterest.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => gc.changePlan(v!),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Period (Months)"),
                  DropdownButton<int>(
                    value: gc.periodMonths.value,
                    items: [6, 12, 24, 36].map((m) => DropdownMenuItem(value: m, child: Text("$m"))).toList(),
                    onChanged: (v) => gc.changePeriod(v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Interest Rate: ${gc.planInterest[gc.selectedPlan.value]}%"),
                      const SizedBox(height: 8),
                      Text("Estimated Interest: ₱ ${gc.estimatedInterest.toStringAsFixed(2)}"),
                      const SizedBox(height: 8),
                      Text(
                        "Total After ${gc.periodMonths.value} months: ₱ ${(gc.initialDeposit.value + gc.estimatedInterest).toStringAsFixed(2)}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Obx(
              () => ElevatedButton(
                onPressed: gc.initialDeposit.value > 0
                    ? () {
                        final account = gc.buildAccount();
                        Get.defaultDialog(
                          title: "Confirm Go-Save Account",
                          middleText:
                              "You are about to open a ${account.plan} plan with initial deposit ₱${account.initialDeposit.toStringAsFixed(2)}",
                          textConfirm: "Confirm",
                          textCancel: "Cancel",
                          onConfirm: () {
                            Get.back();
                            Get.snackbar("Success", "Go-Save Account Opened", snackPosition: SnackPosition.BOTTOM);
                          },
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Open Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
