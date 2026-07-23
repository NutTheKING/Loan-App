import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class PaymentScheduleView extends StatelessWidget {
  PaymentScheduleView({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final schedule = controller.repayments;
      final loan = controller.latestLoan;
      return AccountPage(
        title: 'Payment schedule',
        onRefresh: controller.loadAccount,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (loan != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${loan['loanNumber'] ?? 'Latest loan'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('${schedule.length} scheduled installments'),
                        ],
                      ),
                    ),
                    StatusPill(status: '${loan['status'] ?? 'PENDING'}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (schedule.isEmpty)
              const AccountEmptyState(
                icon: Icons.event_busy_outlined,
                title: 'No payment schedule',
                message:
                    'Installments appear here when a loan application creates a repayment schedule.',
              )
            else
              ...schedule.map(
                (payment) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        '${payment['installment'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    title: Text(
                      _currency(payment['amountDue']),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('Due ${_date(payment['dueDate'])}'),
                    trailing: StatusPill(
                      status: '${payment['status'] ?? 'SCHEDULED'}',
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
String _currency(Object? value) =>
    NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(_number(value));
String _date(Object? value) {
  final date = DateTime.tryParse('$value');
  return date == null
      ? 'Not available'
      : DateFormat.yMMMd().format(date.toLocal());
}
