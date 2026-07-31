import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class TransactionsScreen extends StatelessWidget {
  TransactionsScreen({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AccountPage(
        title: 'Transactions',
        onRefresh: controller.loadAccount,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (controller.transactions.isEmpty)
              const AccountEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                message:
                    'Loan disbursements and repayments will appear here automatically.',
              )
            else
              ...controller.transactions.map((transaction) {
                final type = '${transaction['type'] ?? ''}'.toUpperCase();
                final incoming = _isIncoming(type);
                final outgoing = _isOutgoing(type);
                final movementColor = incoming
                    ? const Color(0xFF12B76A)
                    : outgoing
                    ? const Color(0xFFF04438)
                    : Theme.of(context).colorScheme.primary;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => _showTransaction(context, transaction),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: movementColor.withValues(alpha: .14),
                      child: Icon(_transactionIcon(type), color: movementColor),
                    ),
                    title: Text(
                      '${transaction['description'] ?? transaction['type'] ?? 'Transaction'}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(_date(transaction['occurredAt'])),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${incoming
                              ? '+'
                              : outgoing
                              ? '-'
                              : ''}${_currency(transaction['amount'])}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: movementColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StatusPill(
                          status: '${transaction['status'] ?? 'PENDING'}',
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _showTransaction(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final status = '${transaction['status'] ?? 'PENDING'}'.toUpperCase();
    final type = '${transaction['type'] ?? 'TRANSACTION'}'.toUpperCase();
    final reason = '${transaction['reviewReason'] ?? ''}'.trim();
    final message = switch (status) {
      'PENDING' =>
        'This ${_friendly(type).toLowerCase()} request is under back-office review. Your available balance reflects any reserved withdrawal amount.',
      'REJECTED' =>
        reason.isEmpty
            ? 'This request was rejected by the back office.'
            : 'This request was rejected: $reason',
      'COMPLETED' => 'This transaction has been completed successfully.',
      _ =>
        reason.isEmpty
            ? 'This transaction could not be completed.'
            : 'This transaction could not be completed: $reason',
    };
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          status == 'COMPLETED'
              ? Icons.check_circle_outline_rounded
              : status == 'REJECTED' || status == 'FAILED'
              ? Icons.cancel_outlined
              : Icons.schedule_rounded,
          size: 42,
        ),
        title: Text('${_friendly(type)} · ${_friendly(status)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              _currency(transaction['amount']),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(_date(transaction['occurredAt'])),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

IconData _transactionIcon(Object? type) => switch ('$type'.toUpperCase()) {
  'LOAN_DISBURSEMENT' ||
  'DISBURSEMENT' ||
  'DEPOSIT' ||
  'TRANSFER_IN' => Icons.south_west_rounded,
  'REPAYMENT' => Icons.north_east_rounded,
  'WITHDRAWAL' || 'FEE' || 'TRANSFER_OUT' => Icons.north_east_rounded,
  _ => Icons.swap_horiz_rounded,
};
bool _isIncoming(String type) => const {
  'LOAN_DISBURSEMENT',
  'DISBURSEMENT',
  'DEPOSIT',
  'TRANSFER_IN',
}.contains(type);
bool _isOutgoing(String type) =>
    const {'REPAYMENT', 'WITHDRAWAL', 'FEE', 'TRANSFER_OUT'}.contains(type);
double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
String _currency(Object? value) =>
    NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(_number(value));
String _date(Object? value) {
  final date = DateTime.tryParse('$value');
  return date == null
      ? 'Date unavailable'
      : DateFormat('MMM d, y · h:mm a').format(date.toLocal());
}

String _friendly(Object? value) => '$value'
    .toLowerCase()
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
