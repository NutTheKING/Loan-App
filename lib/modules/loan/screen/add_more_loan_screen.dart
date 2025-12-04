import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';

class AddMoreLoanView extends StatelessWidget {
  const AddMoreLoanView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoanController lc = Get.find<LoanController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add More Loan')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Obx(() => Text('Current: ₱${lc.amount.value.toStringAsFixed(2)}')),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Add additional amount'),
              onChanged: (v) => lc.amount.value = lc.amount.value + (double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Get.back(), child: const Text('Add')),
          ],
        ),
      ),
    );
  }
}
