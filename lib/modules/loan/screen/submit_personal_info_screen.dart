import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/modules/loan/loan_routes.dart';
import 'package:loan_app/modules/loan/widget/loan_step_header.dart';

class PersonalInfoScreen extends StatelessWidget {
  PersonalInfoScreen({super.key});

  final LoanController controller = LoanController.ensure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal information')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const LoanStepHeader(
            step: 3,
            title: 'Tell us about you',
            subtitle:
                'We use these details to assess affordability and verify your application.',
          ),
          const SizedBox(height: 22),
          _Section(
            title: 'Identity',
            children: [
              _field(
                label: 'Full legal name',
                initialValue: controller.actualName.value,
                onChanged: (value) =>
                    controller.actualName.value = value.trim(),
              ),
              _field(
                label: 'ID card number',
                initialValue: controller.idCardNo.value,
                keyboardType: TextInputType.text,
                onChanged: (value) => controller.idCardNo.value = value.trim(),
              ),
              DropdownButtonFormField<String>(
                initialValue: controller.gender.value.isEmpty
                    ? null
                    : controller.gender.value,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const ['Male', 'Female', 'Other']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => controller.gender.value = value ?? '',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'Income and purpose',
            children: [
              _field(
                label: 'Current job',
                initialValue: controller.currentJob.value,
                onChanged: (value) =>
                    controller.currentJob.value = value.trim(),
              ),
              _field(
                label: 'Stable monthly income',
                initialValue: controller.stableIncome.value > 0
                    ? controller.stableIncome.value.toStringAsFixed(0)
                    : '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixText: '₱ ',
                onChanged: (value) => controller.stableIncome.value =
                    double.tryParse(value.replaceAll(',', '')) ?? 0,
              ),
              _field(
                label: 'Loan purpose',
                initialValue: controller.loanPurpose.value,
                maxLines: 2,
                onChanged: (value) =>
                    controller.loanPurpose.value = value.trim(),
              ),
              _field(
                label: 'Current address',
                initialValue: controller.currentAddress.value,
                maxLines: 2,
                onChanged: (value) =>
                    controller.currentAddress.value = value.trim(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'Guarantor',
            children: [
              _field(
                label: 'Guarantor full name',
                initialValue: controller.guarantorName.value,
                onChanged: (value) =>
                    controller.guarantorName.value = value.trim(),
              ),
              _field(
                label: 'Guarantor phone number',
                initialValue: controller.guarantorPhone.value,
                keyboardType: TextInputType.phone,
                onChanged: (value) =>
                    controller.guarantorPhone.value = value.trim(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton.icon(
              onPressed: controller.isPersonalInfoValid()
                  ? () => context.push(LoanRoutes.payoutAccount)
                  : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue to payout account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label, prefixText: prefixText),
      onChanged: onChanged,
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          ...children,
        ],
      ),
    ),
  );
}
