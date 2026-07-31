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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Available Balance",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "₱ ${wc.availableBalance.value.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              child: ListTile(
                leading: Icon(Icons.schedule_rounded),
                title: Text('Back-office review required'),
                subtitle: Text(
                  'Cash-out requests stay pending until an authorized user approves or rejects them.',
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
                initialValue: wc.selectedMethod.value.isEmpty
                    ? null
                    : wc.selectedMethod.value,
                decoration: const InputDecoration(
                  labelText: "Withdrawal Method",
                  border: OutlineInputBorder(),
                ),
                items: wc.methods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => wc.selectedMethod.value = val ?? '',
              ),
            ),
            const Spacer(),
            Obx(
              () => ElevatedButton(
                onPressed: wc.isValid ? () => _confirm(context) : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Confirm Withdrawal"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.outbox_outlined, size: 40),
        title: const Text('Submit withdrawal request?'),
        content: Text(
          'Request ₱${wc.withdrawAmount.value.toStringAsFixed(2)} through ${wc.selectedMethod.value}. The amount will remain pending until reviewed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit request'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await wc.submit();
    }
  }
}
