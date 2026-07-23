import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/modules/loan/loan_routes.dart';
import 'package:loan_app/modules/loan/widget/loan_step_header.dart';

class BankAccountScreen extends StatelessWidget {
  BankAccountScreen({super.key});

  final LoanController controller = LoanController.ensure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payout account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const LoanStepHeader(
            step: 4,
            title: 'Where should we send it?',
            subtitle:
                'Use an account in your name. Approved funds will be disbursed to this account.',
          ),
          const SizedBox(height: 22),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _field(
                    label: 'Bank or wallet provider',
                    initialValue: controller.beneficiaryBank.value,
                    icon: Icons.account_balance_outlined,
                    onChanged: (value) =>
                        controller.beneficiaryBank.value = value.trim(),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: 'Account holder name',
                    initialValue: controller.accountName.value,
                    icon: Icons.person_outline_rounded,
                    onChanged: (value) =>
                        controller.accountName.value = value.trim(),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: 'Account number',
                    initialValue: controller.accountNumber.value,
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        controller.accountNumber.value = value.trim(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Double-check the account number. Transfers to an incorrect account may not be recoverable.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton.icon(
              onPressed: controller.isValid
                  ? () => context.push(
                      LoanRoutes.signature,
                      extra: {
                        'amount': controller.amount.value,
                        'period': controller.selectedPeriod.value,
                      },
                    )
                  : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Review and sign'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String initialValue,
    required IconData icon,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) => TextFormField(
    initialValue: initialValue,
    keyboardType: keyboardType,
    textCapitalization: TextCapitalization.words,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    onChanged: onChanged,
  );
}
