import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class LoanContractView extends StatelessWidget {
  LoanContractView({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loan = controller.latestLoan;
      return AccountPage(
        title: 'Loan contract',
        onRefresh: controller.loadAccount,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (loan == null)
              const AccountEmptyState(
                icon: Icons.description_outlined,
                title: 'No contract available',
                message:
                    'Your latest loan agreement will appear after an application is submitted.',
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${loan['loanNumber'] ?? 'Loan agreement'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        StatusPill(status: '${loan['status'] ?? 'PENDING'}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Submitted ${_date(loan['createdAt'])}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AccountSection(
                title: 'Financial summary',
                children: [
                  AccountInfoRow(
                    label: 'Principal',
                    value: _currency(loan['principal']),
                  ),
                  AccountInfoRow(
                    label: 'Term',
                    value: '${loan['termMonths'] ?? 0} months',
                  ),
                  AccountInfoRow(
                    label: 'Monthly interest',
                    value:
                        '${(_number(loan['monthlyInterestRate']) * 100).toStringAsFixed(2)}%',
                  ),
                  AccountInfoRow(
                    label: 'Interest amount',
                    value: _currency(loan['interestAmount']),
                  ),
                  AccountInfoRow(
                    label: 'Monthly payment',
                    value: _currency(loan['monthlyPayment']),
                  ),
                  AccountInfoRow(
                    label: 'Total repayment',
                    value: _currency(loan['totalRepayment']),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const AccountSection(
                title: 'Agreement summary',
                children: [
                  _ContractClause(
                    number: '01',
                    text:
                        'Repay principal and interest according to the payment schedule.',
                  ),
                  _ContractClause(
                    number: '02',
                    text:
                        'Keep identity, contact, employment, and payout details accurate.',
                  ),
                  _ContractClause(
                    number: '03',
                    text:
                        'Late or missed payments may result in penalties under the final agreement.',
                  ),
                  _ContractClause(
                    number: '04',
                    text:
                        'Approval and final disbursement remain subject to lender review.',
                    showDivider: false,
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _ContractClause extends StatelessWidget {
  const _ContractClause({
    required this.number,
    required this.text,
    this.showDivider = true,
  });

  final String number;
  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(text)),
          ],
        ),
      ),
      if (showDivider) const Divider(height: 1),
    ],
  );
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
