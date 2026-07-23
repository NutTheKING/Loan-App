import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class BeneficiaryScreen extends StatelessWidget {
  BeneficiaryScreen({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loan = controller.latestLoan;
      return AccountPage(
        title: 'Payout account',
        onRefresh: controller.loadAccount,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (loan == null)
              const AccountEmptyState(
                icon: Icons.account_balance_outlined,
                title: 'No payout account',
                message:
                    'Your payout account appears here after a loan application is submitted.',
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(child: Icon(Icons.verified_user_outlined)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'This is the destination saved with your latest loan application.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AccountSection(
                title: 'Account details',
                children: [
                  AccountInfoRow(
                    icon: Icons.account_balance_outlined,
                    label: 'Provider',
                    value: '${loan['beneficiaryBank'] ?? ''}',
                  ),
                  AccountInfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Account name',
                    value: '${loan['accountName'] ?? ''}',
                  ),
                  AccountInfoRow(
                    icon: Icons.numbers_rounded,
                    label: 'Account number',
                    value: controller.maskedAccount,
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
