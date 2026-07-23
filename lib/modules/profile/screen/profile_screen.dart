import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/themes/app_color.dart';

class AccountProfileScreen extends StatelessWidget {
  AccountProfileScreen({super.key});

  final ProfileController controller = ProfileController.ensure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.loadAccount,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _ProfileCard(controller: controller),
              if (controller.isLoading.value) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(),
              ],
              if (controller.errorMessage.value.isNotEmpty) ...[
                const SizedBox(height: 14),
                _InlineMessage(message: controller.errorMessage.value),
              ],
              const SizedBox(height: 24),
              _MenuGroup(
                title: 'Your account',
                children: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal information',
                    subtitle: 'Identity and account details',
                    onTap: () => context.push('/personal-information'),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_outlined,
                    title: 'Payout account',
                    subtitle: 'Beneficiary bank information',
                    onTap: () => context.push('/beneficiary-information'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _MenuGroup(
                title: 'Loan center',
                children: [
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'Loan contract',
                    subtitle: 'Review your latest agreement',
                    onTap: () => context.push('/loan-contract'),
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Payment schedule',
                    subtitle: 'Installments and due dates',
                    onTap: () => context.push('/payment-schedule'),
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Transactions',
                    subtitle: 'Disbursements and payments',
                    onTap: () => context.push('/transactions'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _MenuGroup(
                title: 'Preferences and support',
                children: [
                  _MenuItem(
                    icon: Icons.tune_rounded,
                    title: 'Settings',
                    subtitle: 'Theme, security and alerts',
                    onTap: () => context.push('/settings'),
                  ),
                  _MenuItem(
                    icon: Icons.support_agent_rounded,
                    title: 'Help center',
                    subtitle: 'Get answers or contact support',
                    onTap: () => context.push('/help-center'),
                  ),
                  _MenuItem(
                    icon: Icons.gavel_outlined,
                    title: 'Terms and conditions',
                    subtitle: 'Legal and privacy information',
                    onTap: () => context.push('/term-conditions'),
                  ),
                  if (controller.user.value?.canAccessAdmin == true)
                    _MenuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Administration',
                      subtitle: 'Open the management portal',
                      onTap: () => context.go('/admin'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Loan app ${controller.appVersion.value}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.strength,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 31,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.strength,
          child: Text(
            controller.initials.isEmpty ? 'L' : controller.initials,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                controller.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  controller.role.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: AppColors.strength,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),
      Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(icon),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right_rounded),
  );
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
