import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/modules/homescreen/controller/home_screen_controller.dart';
import 'package:loan_app/modules/loan/loan_routes.dart';
import 'package:loan_app/modules/notification/controller/notification_controller.dart';
import 'package:loan_app/themes/app_color.dart';
import 'package:loan_app/widgets/brand_logo.dart';

class BankHome extends StatelessWidget {
  const BankHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final notifications = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);
    final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                controller.loadDashboard(),
                notifications.fetchAllNotifications(),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
              children: [
                _Header(
                  name: controller.displayName.value,
                  notifications: notifications,
                ),
                const SizedBox(height: 22),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: .94, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value.clamp(0, 1), child: child),
                  ),
                  child: _LoanCard(
                    balance: currency.format(controller.availableBalance),
                    applications: controller.loans.length,
                  ),
                ),
                const SizedBox(height: 18),
                _QuickActions(
                  hasPendingLoan: controller.hasPendingLoan.value,
                  onLoan: () => _openLoan(context, controller),
                ),
                if (controller.hasPendingLoan.value) ...[
                  const SizedBox(height: 18),
                  _PendingLoanCard(loan: controller.pendingLoan),
                ],
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'Do more with your money',
                  subtitle: 'Simple tools, one clean place.',
                ),
                const SizedBox(height: 14),
                _FeatureCard(
                  eyebrow: 'SAVE',
                  title: 'Build your safety fund',
                  description:
                      'Create a savings goal and keep progress visible from your dashboard.',
                  icon: Icons.savings_outlined,
                  color: AppColors.primary,
                  onTap: () => context.push('/go-save-account'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactFeature(
                        title: 'Exchange',
                        icon: Icons.currency_exchange_rounded,
                        onTap: () => context.push('/exchange-rate'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactFeature(
                        title: 'Rewards',
                        icon: Icons.card_giftcard_rounded,
                        onTap: () => context.push('/explore-rewards'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _SectionTitle(
                        title: 'Recent activity',
                        subtitle: 'Your latest account movement.',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/transactions'),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (controller.isLoading.value)
                  const _LoadingActivity()
                else if (controller.errorMessage.value.isNotEmpty)
                  _MessageCard(
                    icon: Icons.cloud_off_outlined,
                    message: controller.errorMessage.value,
                  )
                else if (controller.recentTransactions.isEmpty)
                  const _MessageCard(
                    icon: Icons.inbox_outlined,
                    message:
                        'No transactions yet. Your activity will appear here.',
                  )
                else
                  ...controller.recentTransactions
                      .take(5)
                      .map(
                        (transaction) => _TransactionTile(
                          transaction: transaction,
                          currency: currency,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLoan(BuildContext context, HomeController controller) {
    if (controller.hasPendingLoan.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your current application is pending. You can apply again after review.',
          ),
        ),
      );
      return;
    }
    context.push(LoanRoutes.amount);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.notifications});

  final String name;
  final NotificationController notifications;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const BrandLogo(
        width: 92,
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good day, $name',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Your money, made simple',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      IconButton.filledTonal(
        tooltip: 'Profile',
        onPressed: () => context.push('/profile'),
        icon: const Icon(Icons.person_outline_rounded),
      ),
      const SizedBox(width: 6),
      Obx(
        () => Badge(
          isLabelVisible: notifications.unreadCount.value > 0,
          label: Text('${notifications.unreadCount.value}'),
          child: IconButton.filledTonal(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ),
    ],
  );
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.balance, required this.applications});

  final String balance;
  final int applications;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.58,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: ColoredBox(
        color: AppColors.strength,
        child: CustomPaint(
          painter: const _CardLinesPainter(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'LOAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: AppColors.strength,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Approved loan balance',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    balance,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card_rounded,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$applications application${applications == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    const Text(
                      '•••• 2026',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _CardLinesPainter extends CustomPainter {
  const _CardLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: .2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final center = Offset(size.width * .92, size.height * .18);
    for (var radius = 28.0; radius < size.width * .85; radius += 19) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * .12,
        math.pi * 1.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.hasPendingLoan, required this.onLoan});

  final bool hasPendingLoan;
  final VoidCallback onLoan;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ActionButton(
          icon: Icons.add_rounded,
          label: 'Deposit',
          onTap: () => context.push('/deposits'),
        ),
      ),
      Expanded(
        child: _ActionButton(
          icon: Icons.north_east_rounded,
          label: 'Send',
          onTap: () => context.push('/withdraws'),
        ),
      ),
      Expanded(
        child: _ActionButton(
          icon: hasPendingLoan
              ? Icons.schedule_rounded
              : Icons.description_outlined,
          label: hasPendingLoan ? 'Pending' : 'New loan',
          onTap: onLoan,
        ),
      ),
      Expanded(
        child: _ActionButton(
          icon: Icons.receipt_long_outlined,
          label: 'History',
          onTap: () => context.push('/transactions'),
        ),
      ),
    ],
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 3),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(description),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: onTap,
                    child: const Text('Explore'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 82,
              height: 118,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: AppColors.strength),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CompactFeature extends StatelessWidget {
  const _CompactFeature({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PendingLoanCard extends StatelessWidget {
  const _PendingLoanCard({required this.loan});

  final Map<String, dynamic>? loan;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        const CircleAvatar(child: Icon(Icons.schedule_rounded)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Application under review',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text('${loan?['loanNumber'] ?? 'Your loan'} is being reviewed.'),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.currency});

  final Map<String, dynamic> transaction;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final type = '${transaction['type'] ?? ''}'.toUpperCase();
    final incoming = _isIncomingTransaction(type);
    final outgoing = _isOutgoingTransaction(type);
    final movementColor = incoming
        ? const Color(0xFF12B76A)
        : outgoing
        ? const Color(0xFFF04438)
        : Theme.of(context).colorScheme.primary;
    final amount = _number(transaction['amount']);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: movementColor.withValues(alpha: .14),
          child: Icon(
            incoming
                ? Icons.south_west_rounded
                : outgoing
                ? Icons.north_east_rounded
                : Icons.swap_horiz_rounded,
            color: movementColor,
          ),
        ),
        title: Text(
          '${transaction['description'] ?? transaction['type'] ?? 'Transaction'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_friendly(transaction['status'])),
        trailing: Text(
          '${incoming
              ? '+'
              : outgoing
              ? '-'
              : ''}${currency.format(amount)}',
          style: TextStyle(fontWeight: FontWeight.w800, color: movementColor),
        ),
      ),
    );
  }
}

class _LoadingActivity extends StatelessWidget {
  const _LoadingActivity();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(28),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

bool _isIncomingTransaction(String type) => const {
  'LOAN_DISBURSEMENT',
  'DISBURSEMENT',
  'DEPOSIT',
  'TRANSFER_IN',
}.contains(type);

bool _isOutgoingTransaction(String type) =>
    const {'REPAYMENT', 'WITHDRAWAL', 'FEE', 'TRANSFER_OUT'}.contains(type);

String _friendly(Object? value) {
  final text = '${value ?? ''}'.replaceAll('_', ' ').toLowerCase();
  if (text.isEmpty) return 'Pending';
  return '${text[0].toUpperCase()}${text.substring(1)}';
}
