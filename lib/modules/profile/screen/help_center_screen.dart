import 'package:flutter/material.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class HelpCenterScreen extends StatelessWidget {
  HelpCenterScreen({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return AccountPage(
      title: 'Help center',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.support_agent_rounded, size: 38),
                const SizedBox(height: 14),
                Text(
                  'How can we help?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Find quick answers below or send our support team an email.',
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: controller.contactSupport,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email support'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const AccountSection(
            title: 'Frequently asked questions',
            children: [
              _Question(
                title: 'How long does loan review take?',
                answer:
                    'Review timing depends on document quality and verification. You will receive a notification when the status changes.',
              ),
              _Question(
                title: 'Why can’t I create another loan?',
                answer:
                    'Only one pending application is allowed. A new application becomes available after the current review is completed.',
              ),
              _Question(
                title: 'Where can I see repayments?',
                answer:
                    'Open Account, then Payment schedule to view every installment and its current status.',
              ),
              _Question(
                title: 'How do notifications work?',
                answer:
                    'Application events appear in the notification center. Push delivery also requires notification permission on your device.',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const AccountSection(
            title: 'Support details',
            children: [
              AccountInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'support@loanapp.com',
              ),
              AccountInfoRow(
                icon: Icons.schedule_outlined,
                label: 'Response target',
                value: 'Within 24 hours',
                showDivider: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.title, required this.answer});

  final String title;
  final String answer;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: 14),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    children: [Align(alignment: Alignment.centerLeft, child: Text(answer))],
  );
}
