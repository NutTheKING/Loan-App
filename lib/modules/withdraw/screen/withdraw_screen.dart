import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/withdraw/controller/withdraw_controller.dart';

class WithdrawScreen extends StatelessWidget {
  final WithdrawController wc = Get.put(WithdrawController());

  WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdraw Money"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Available Balance", style: TextStyle(fontSize: 16)),
                      Text(
                        "₱ ${wc.availableBalance.value.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Withdrawal Amount",
                prefixText: "₱ ",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                wc.withdrawAmount.value = double.tryParse(val) ?? 0.0;
              },
            ),
            const SizedBox(height: 20),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: wc.selectedMethod.value.isEmpty ? null : wc.selectedMethod.value,
                decoration: const InputDecoration(labelText: "Withdrawal Method", border: OutlineInputBorder()),
                items: wc.methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => wc.selectedMethod.value = val ?? '',
              ),
            ),
            const Spacer(),
            Obx(
              () => ElevatedButton(
                onPressed: wc.isValid() ? wc.submit : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Confirm Withdrawal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
