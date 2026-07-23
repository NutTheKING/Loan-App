import 'package:flutter/material.dart';
import 'package:loan_app/modules/profile/widget/account_ui.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountPage(
      title: 'Terms and conditions',
      child: _TermsBody(),
    );
  }
}

class _TermsBody extends StatelessWidget {
  const _TermsBody();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
    children: const [
      AccountSection(
        title: 'Using the service',
        subtitle: 'Last updated July 2026',
        children: [
          _Term(
            number: '01',
            title: 'Account responsibility',
            body:
                'Keep your sign-in details secure and provide accurate information. Notify support if you believe your account is compromised.',
          ),
          _Term(
            number: '02',
            title: 'Loan applications',
            body:
                'Submitting an application does not guarantee approval. Applications are assessed using the information and documents provided.',
          ),
          _Term(
            number: '03',
            title: 'Repayments',
            body:
                'Approved loans must be repaid according to the final contract and payment schedule shown in your account.',
          ),
          _Term(
            number: '04',
            title: 'Privacy and verification',
            body:
                'Information may be processed to verify identity, assess affordability, prevent fraud, and operate the lending service.',
          ),
          _Term(
            number: '05',
            title: 'Notifications',
            body:
                'Important account and loan decisions may be delivered in-app, by push notification, or through registered contact details.',
            showDivider: false,
          ),
        ],
      ),
      SizedBox(height: 14),
      AccountEmptyState(
        icon: Icons.info_outline_rounded,
        title: 'Important',
        message:
            'This in-app summary does not replace the final signed loan agreement or legal disclosures provided for an approved product.',
      ),
    ],
  );
}

class _Term extends StatelessWidget {
  const _Term({
    required this.number,
    required this.title,
    required this.body,
    this.showDivider = true,
  });

  final String number;
  final String title;
  final String body;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
      if (showDivider) const Divider(height: 1),
    ],
  );
}
