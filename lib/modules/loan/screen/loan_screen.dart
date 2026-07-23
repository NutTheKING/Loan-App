import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/modules/loan/loan_routes.dart';
import 'package:loan_app/modules/loan/widget/loan_step_header.dart';
import 'package:loan_app/themes/app_color.dart';

class LoanView extends StatelessWidget {
  const LoanView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoanController.ensure();
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Loan amount')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const LoanStepHeader(
              step: 1,
              title: 'Build your loan',
              subtitle:
                  'Choose an amount and a repayment period that fits your budget.',
            ),
            if (controller.configurationLoading.value) ...[
              const SizedBox(height: 18),
              const LinearProgressIndicator(),
            ],
            if (controller.hasPendingLoan.value) ...[
              const SizedBox(height: 18),
              _NoticeCard(
                icon: Icons.lock_clock_outlined,
                message:
                    'Your current application is still under review. You can apply again after a decision.',
              ),
            ],
            const SizedBox(height: 22),
            _AmountCard(controller: controller, currency: currency),
            const SizedBox(height: 22),
            Text(
              'Repayment period',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.allowedTerms
                  .map(
                    (months) => ChoiceChip(
                      label: Text('$months months'),
                      selected: controller.selectedPeriod.value == months,
                      onSelected: controller.hasPendingLoan.value
                          ? null
                          : (_) => controller.setPeriod(months),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Monthly payment',
                      value: currency.format(controller.monthlyPayment.value),
                      emphasized: true,
                    ),
                    _SummaryRow(
                      label: 'Monthly interest',
                      value:
                          '${(controller.monthlyInterestRate * 100).toStringAsFixed(2)}%',
                    ),
                    _SummaryRow(
                      label: 'Total interest',
                      value: currency.format(controller.interestAmount.value),
                    ),
                    _SummaryRow(
                      label: 'Total repayment',
                      value: currency.format(controller.paymentAmount.value),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: controller.agreeTerms.value,
              onChanged: controller.hasPendingLoan.value
                  ? null
                  : (value) => controller.agreeTerms.value = value ?? false,
              title: const Text('I agree to the loan terms and conditions.'),
              subtitle: const Text(
                'Your final contract is available before submission.',
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed:
                  controller.agreeTerms.value &&
                      !controller.hasPendingLoan.value &&
                      !controller.configurationLoading.value
                  ? () => context.push(LoanRoutes.documents)
                  : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                controller.hasPendingLoan.value
                    ? 'Application pending'
                    : 'Continue to documents',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.controller, required this.currency});

  final LoanController controller;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final range = controller.maxAmount - controller.minAmount;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.strength,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.productName.value,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(controller.amount.value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 76,
            child: CustomPaint(
              painter: _AmountChartPainter(
                principal: controller.principal.value,
                totalRepayment: controller.paymentAmount.value,
                accent: AppColors.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Principal', style: TextStyle(color: Colors.white60)),
              Text(
                'Principal + interest',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: .16),
            ),
            child: Slider(
              value: controller.amount.value,
              min: controller.minAmount,
              max: range > 0 ? controller.maxAmount : controller.minAmount + 1,
              divisions: range > 0 ? 50 : null,
              onChanged: controller.hasPendingLoan.value
                  ? null
                  : controller.changeAmount,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currency.format(controller.minAmount),
                style: const TextStyle(color: Colors.white60),
              ),
              Text(
                currency.format(controller.maxAmount),
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${controller.selectedPeriod.value} payments · ${currency.format(controller.monthlyPayment.value)} / month',
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountChartPainter extends CustomPainter {
  const _AmountChartPainter({
    required this.principal,
    required this.totalRepayment,
    required this.accent,
  });

  final double principal;
  final double totalRepayment;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 12;
    const gap = 6.0;
    final barWidth = (size.width - gap * (barCount - 1)) / barCount;
    final safeTotal = totalRepayment <= 0 ? 1 : totalRepayment;
    final principalRatio = (principal / safeTotal).clamp(0.0, 1.0);
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: .12);
    final principalPaint = Paint()..color = Colors.white.withValues(alpha: .5);
    final interestPaint = Paint()..color = accent;

    for (var index = 0; index < barCount; index++) {
      final progress = (index + 1) / barCount;
      final height = size.height * (.32 + progress * .68);
      final left = index * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, backgroundPaint);

      final principalHeight = height * principalRatio;
      final principalRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          size.height - principalHeight,
          barWidth,
          principalHeight,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(principalRect, principalPaint);

      final interestHeight = height - principalHeight;
      if (interestHeight > 1) {
        final interestRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - height, barWidth, interestHeight),
          const Radius.circular(6),
        );
        canvas.drawRRect(interestRect, interestPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AmountChartPainter oldDelegate) =>
      principal != oldDelegate.principal ||
      totalRepayment != oldDelegate.totalRepayment ||
      accent != oldDelegate.accent;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value,
              style: TextStyle(
                fontSize: emphasized ? 18 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      if (showDivider) const Divider(height: 1),
    ],
  );
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
