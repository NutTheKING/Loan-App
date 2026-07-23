import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class PersonalInformationScreen extends StatelessWidget {
  PersonalInformationScreen({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loan = controller.latestLoan;
      return AccountPage(
        title: 'Personal information',
        onRefresh: controller.loadAccount,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (controller.isLoading.value) const LinearProgressIndicator(),
            if (controller.isLoading.value) const SizedBox(height: 18),
            AccountSection(
              title: 'Account identity',
              subtitle: 'Verified information from your signed-in account.',
              children: [
                AccountInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Full name',
                  value: controller.fullName,
                ),
                AccountInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: controller.email,
                ),
                AccountInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'ID number',
                  value: controller.maskedId,
                ),
                AccountInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value: _date(controller.user.value?.createdAt),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (loan == null)
              const AccountEmptyState(
                icon: Icons.description_outlined,
                title: 'No application details yet',
                message:
                    'Personal application information appears after you submit a loan.',
              )
            else ...[
              AccountSection(
                title: 'Application details',
                subtitle: 'Information submitted with your latest application.',
                children: [
                  AccountInfoRow(
                    label: 'Legal name',
                    value: '${loan['actualName'] ?? ''}',
                  ),
                  AccountInfoRow(
                    label: 'Current job',
                    value: '${loan['currentJob'] ?? ''}',
                  ),
                  AccountInfoRow(
                    label: 'Gender',
                    value: '${loan['gender'] ?? ''}',
                  ),
                  AccountInfoRow(
                    label: 'Monthly income',
                    value: _currency(loan['stableIncome']),
                  ),
                  AccountInfoRow(
                    label: 'Loan purpose',
                    value: '${loan['loanPurpose'] ?? ''}',
                  ),
                  AccountInfoRow(
                    label: 'Address',
                    value: '${loan['currentAddress'] ?? ''}',
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AccountSection(
                title: 'Guarantor',
                children: [
                  AccountInfoRow(
                    label: 'Full name',
                    value: '${loan['guarantorName'] ?? ''}',
                  ),
                  AccountInfoRow(
                    label: 'Phone number',
                    value: '${loan['guarantorPhone'] ?? ''}',
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

String _currency(Object? value) {
  final number = value is num
      ? value.toDouble()
      : double.tryParse('$value') ?? 0;
  return NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(number);
}

String _date(DateTime? value) => value == null
    ? 'Not available'
    : DateFormat.yMMMd().format(value.toLocal());
