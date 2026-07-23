import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/homescreen/controller/home_screen_controller.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/modules/loan/widget/loan_step_header.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatelessWidget {
  SignatureScreen({super.key, required this.loanAmount, required this.period});

  final LoanController controller = LoanController.ensure();
  final double loanAmount;
  final int period;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 0);
    final colors = Theme.of(context).colorScheme;
    final selectedAmount = controller.amount.value == 0
        ? loanAmount
        : controller.amount.value;
    final selectedPeriod = controller.selectedPeriod.value == 0
        ? period
        : controller.selectedPeriod.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Review and sign')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const LoanStepHeader(
            step: 5,
            title: 'Final review',
            subtitle:
                'Review your loan summary, read the contract, then sign to submit.',
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryValue(
                    label: 'Loan amount',
                    value: currency.format(selectedAmount),
                  ),
                ),
                Container(width: 1, height: 46, color: colors.outlineVariant),
                const SizedBox(width: 18),
                Expanded(
                  child: _SummaryValue(
                    label: 'Repayment',
                    value: '$selectedPeriod months',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _showContract(context),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Read loan contract'),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your signature',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: controller.clearSignature,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 230,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Signature(
                  controller: controller.signatureController,
                  backgroundColor: Colors.white,
                ),
                const Positioned(
                  left: 18,
                  bottom: 14,
                  child: Text(
                    'Sign inside this box',
                    style: TextStyle(color: Colors.black38),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'By signing, you confirm that the information provided is accurate and authorize verification.',
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton.icon(
              onPressed:
                  controller.signed.value &&
                      !controller.applicationSubmitting.value
                  ? () => _submit(context)
                  : null,
              icon: controller.applicationSubmitting.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(
                controller.applicationSubmitting.value
                    ? 'Submitting securely…'
                    : 'Submit application',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final submitted = await controller.submitApplication();
    if (!submitted || !context.mounted) {
      return;
    }
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().loadDashboard();
    }
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline_rounded, size: 42),
        title: const Text('Application received'),
        content: const Text(
          'Your application is pending review. We will notify you when its status changes.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Back to dashboard'),
          ),
        ],
      ),
    );
    if (context.mounted) {
      context.go('/home');
    }
  }

  Future<void> _showContract(
    BuildContext context,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: FractionallySizedBox(
        heightFactor: .82,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          children: [
            Text(
              'Loan contract summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              '1. The borrower agrees to repay principal and interest according to the repayment schedule.\n\n'
              '2. Payments are due on the dates shown in the account payment schedule.\n\n'
              '3. Late or missed payments may result in penalties allowed by the final agreement.\n\n'
              '4. The borrower confirms that all submitted information and documents are accurate.\n\n'
              '5. The borrower authorizes identity, employment, income, and payout-account verification.\n\n'
              '6. The final approved amount may differ from the requested amount after review.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(value, style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}
