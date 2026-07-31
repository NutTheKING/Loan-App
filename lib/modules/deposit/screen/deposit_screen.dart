import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/deposit/controller/deposit_controller.dart';

class DepositScreen extends StatelessWidget {
  DepositScreen({super.key});

  final DepositController controller = Get.put(DepositController());

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit money')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deposit amount'),
                    const SizedBox(height: 8),
                    Text(
                      currency.format(controller.amount.value),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Card(
              child: ListTile(
                leading: Icon(Icons.verified_user_outlined),
                title: Text('Deposit verification'),
                subtitle: Text(
                  'Your deposit request will be pending until the back office verifies it.',
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
                prefixIcon: Icon(Icons.add_card_rounded),
              ),
              onChanged: (value) => controller.amount.value =
                  double.tryParse(value.replaceAll(',', '')) ?? 0,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: controller.selectedMethod.value,
              decoration: const InputDecoration(
                labelText: 'Deposit method',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: controller.methods
                  .map(
                    (method) =>
                        DropdownMenuItem(value: method, child: Text(method)),
                  )
                  .toList(),
              onChanged: (value) => controller.selectedMethod.value =
                  value ?? controller.methods.first,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.isValid ? () => _confirm(context) : null,
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.south_west_rounded),
              label: const Text('Confirm deposit'),
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
        icon: const Icon(Icons.add_card_rounded, size: 40),
        title: const Text('Submit deposit request?'),
        content: Text(
          'Submit ₱${controller.amount.value.toStringAsFixed(2)} through ${controller.selectedMethod.value} for verification.',
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
      await controller.submit();
    }
  }
}
