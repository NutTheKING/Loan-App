import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/features/admin/controller/admin_dashboard_controller.dart';
import 'package:loan_app/features/admin/model/admin_loan.dart';
import 'package:loan_app/features/admin/screen/admin_portal_sections.dart';
import 'package:loan_app/routers/app_router.dart';
import 'package:loan_app/widgets/brand_logo.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminDashboardController controller;
  final currency = NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);
  final dateTime = DateFormat('dd MMM yyyy, HH:mm');
  bool sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminDashboardController());
  }

  @override
  void dispose() {
    Get.delete<AdminDashboardController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.surfaceContainerLowest;
    return Scaffold(
      backgroundColor: background,
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 1000;
            final content = _PortalContent(
              controller: controller,
              currency: currency,
              dateTime: dateTime,
              desktop: desktop,
              onOpenLoan: _openLoan,
            );

            if (!desktop) {
              return Scaffold(
                backgroundColor: background,
                appBar: AppBar(
                  title: Obx(
                    () => Text(
                      adminSectionLabel(controller.selectedSection.value),
                    ),
                  ),
                  leading: PopupMenuButton<AdminSection>(
                    tooltip: 'Open menu',
                    icon: const Icon(Icons.menu_rounded),
                    onSelected: controller.selectSection,
                    itemBuilder: (context) => controller.availableSections
                        .map(
                          (section) => PopupMenuItem(
                            value: section,
                            child: Row(
                              children: [
                                Icon(adminSectionIcon(section), size: 20),
                                const SizedBox(width: 10),
                                Text(adminSectionLabel(section)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  actions: [
                    Obx(
                      () => Badge(
                        isLabelVisible:
                            controller.notifications.unreadCount.value > 0,
                        label: Text(
                          '${controller.notifications.unreadCount.value}',
                        ),
                        child: IconButton(
                          tooltip: 'Notifications',
                          onPressed: () => appRouter.go('/notifications'),
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: controller.refreshCurrentSection,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    IconButton(
                      tooltip: 'Sign out',
                      onPressed: controller.signOut,
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
                body: content,
              );
            }

            return Row(
              children: [
                _AdminSidebar(
                  name: user.fullName,
                  email: user.email,
                  selectedSection: controller.selectedSection.value,
                  sections: controller.availableSections,
                  collapsed: sidebarCollapsed,
                  unreadCount: controller.notifications.unreadCount.value,
                  onSelectSection: controller.selectSection,
                  onToggle: () =>
                      setState(() => sidebarCollapsed = !sidebarCollapsed),
                  onSignOut: controller.signOut,
                ),
                Expanded(child: content),
              ],
            );
          },
        );
      }),
    );
  }

  Future<void> _openLoan(AdminLoan loan) async {
    final noteController = TextEditingController(text: loan.reviewerNote);
    String? rejectionError;
    final request = await showDialog<_ReviewRequest>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(20),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              title: Row(
                children: [
                  Expanded(child: Text(loan.loanNumber)),
                  _StatusBadge(status: loan.status),
                ],
              ),
              content: SizedBox(
                width: 720,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DialogSection(
                        title: 'Application',
                        children: [
                          _InfoRow(
                            label: 'Customer',
                            value: loan.borrower.fullName,
                          ),
                          _InfoRow(label: 'Email', value: loan.borrower.email),
                          _InfoRow(
                            label: 'Submitted',
                            value: dateTime.format(loan.createdAt.toLocal()),
                          ),
                          _InfoRow(label: 'Purpose', value: loan.loanPurpose),
                          _InfoRow(
                            label: 'Documents',
                            value: '${loan.documents.length} uploaded',
                          ),
                        ],
                      ),
                      _DialogSection(
                        title: 'Loan statement',
                        children: [
                          _InfoRow(
                            label: 'Principal',
                            value: currency.format(loan.principal),
                          ),
                          _InfoRow(
                            label: 'Term',
                            value: '${loan.termMonths} months',
                          ),
                          _InfoRow(
                            label: 'Monthly payment',
                            value: currency.format(loan.monthlyPayment),
                          ),
                          _InfoRow(
                            label: 'Total repayment',
                            value: currency.format(loan.totalRepayment),
                          ),
                        ],
                      ),
                      _DialogSection(
                        title: 'Identity and employment',
                        children: [
                          _InfoRow(
                            label: 'Applicant name',
                            value: loan.actualName,
                          ),
                          _InfoRow(
                            label: 'ID number',
                            value: loan.idCardNumber,
                          ),
                          _InfoRow(
                            label: 'Current job',
                            value: loan.currentJob,
                          ),
                          _InfoRow(
                            label: 'Stable income',
                            value: currency.format(loan.stableIncome),
                          ),
                          _InfoRow(
                            label: 'Address',
                            value: loan.currentAddress,
                          ),
                        ],
                      ),
                      _DialogSection(
                        title: 'Guarantor and payout',
                        children: [
                          _InfoRow(
                            label: 'Guarantor',
                            value: loan.guarantorName,
                          ),
                          _InfoRow(
                            label: 'Guarantor phone',
                            value: loan.guarantorPhone,
                          ),
                          _InfoRow(label: 'Bank', value: loan.beneficiaryBank),
                          _InfoRow(
                            label: 'Account name',
                            value: loan.accountName,
                          ),
                          _InfoRow(
                            label: 'Account number',
                            value: loan.accountNumber,
                          ),
                        ],
                      ),
                      if (loan.isPending) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: noteController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Reviewer note',
                            hintText: 'Required when rejecting an application',
                            errorText: rejectionError,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ] else if ((loan.reviewerNote ?? '').isNotEmpty)
                        _DialogSection(
                          title: 'Reviewer note',
                          children: [Text(loan.reviewerNote!)],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                if (loan.isPending && controller.can('loans.review')) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      if (noteController.text.trim().isEmpty) {
                        setDialogState(() {
                          rejectionError = 'Add a reason before rejecting.';
                        });
                        return;
                      }
                      Navigator.pop(
                        dialogContext,
                        _ReviewRequest(
                          status: 'REJECTED',
                          note: noteController.text,
                        ),
                      );
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      dialogContext,
                      _ReviewRequest(
                        status: 'APPROVED',
                        note: noteController.text,
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Approve'),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
    noteController.dispose();

    if (request != null && mounted) {
      await controller.reviewLoan(
        loan: loan,
        status: request.status,
        reviewerNote: request.note,
      );
    }
  }
}

class _PortalContent extends StatelessWidget {
  const _PortalContent({
    required this.controller,
    required this.currency,
    required this.dateTime,
    required this.desktop,
    required this.onOpenLoan,
  });

  final AdminDashboardController controller;
  final NumberFormat currency;
  final DateFormat dateTime;
  final bool desktop;
  final ValueChanged<AdminLoan> onOpenLoan;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final section = controller.selectedSection.value;
      final content = switch (section) {
        AdminSection.dashboard => AdminOverviewSection(
          controller: controller,
          currency: currency,
          dateTime: dateTime,
          desktop: desktop,
        ),
        AdminSection.applications => _ApplicationsContent(
          controller: controller,
          currency: currency,
          dateTime: dateTime,
          desktop: desktop,
          onOpenLoan: onOpenLoan,
        ),
        AdminSection.packages => AdminPackagesSection(
          controller: controller,
          currency: currency,
          desktop: desktop,
        ),
        AdminSection.customers => AdminCustomersSection(
          controller: controller,
          desktop: desktop,
        ),
        AdminSection.repayments => AdminRecordsSection(
          controller: controller,
          type: AdminRecordType.repayments,
          currency: currency,
          dateTime: dateTime,
          desktop: desktop,
        ),
        AdminSection.transactions => AdminRecordsSection(
          controller: controller,
          type: AdminRecordType.transactions,
          currency: currency,
          dateTime: dateTime,
          desktop: desktop,
        ),
        AdminSection.reports => AdminReportsSection(
          controller: controller,
          currency: currency,
          desktop: desktop,
        ),
        AdminSection.branches => AdminBranchesSection(
          controller: controller,
          desktop: desktop,
        ),
        AdminSection.users => AdminUsersSection(
          controller: controller,
          desktop: desktop,
        ),
        AdminSection.profile => AdminProfileSection(
          controller: controller,
          desktop: desktop,
        ),
      };
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.015, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(section), child: content),
      );
    });
  }
}

class _ApplicationsContent extends StatelessWidget {
  const _ApplicationsContent({
    required this.controller,
    required this.currency,
    required this.dateTime,
    required this.desktop,
    required this.onOpenLoan,
  });

  final AdminDashboardController controller;
  final NumberFormat currency;
  final DateFormat dateTime;
  final bool desktop;
  final ValueChanged<AdminLoan> onOpenLoan;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = Theme.of(context).colorScheme;
      return RefreshIndicator(
        onRefresh: controller.loadLoans,
        child: ListView(
          padding: EdgeInsets.all(desktop ? 32 : 18),
          children: [
            if (desktop)
              _PageHeader(
                name: controller.currentUser.value?.fullName ?? 'Administrator',
                onRefresh: controller.loadLoans,
              ),
            if (desktop) const SizedBox(height: 28),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _SummaryCard(
                  label: 'All applications',
                  value: '${controller.loans.length}',
                  icon: Icons.description_outlined,
                  color: const Color(0xFF175CD3),
                ),
                _SummaryCard(
                  label: 'Pending review',
                  value: '${controller.countFor('PENDING')}',
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFFB54708),
                ),
                _SummaryCard(
                  label: 'Approved',
                  value: '${controller.countFor('APPROVED')}',
                  icon: Icons.verified_outlined,
                  color: const Color(0xFF067647),
                ),
                _SummaryCard(
                  label: 'Approved principal',
                  value: currency.format(controller.approvedPrincipal),
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF6941C6),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: colors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan applications',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review customer statements and make lending decisions.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['ALL', 'PENDING', 'APPROVED', 'REJECTED']
                          .map(
                            (status) => ChoiceChip(
                              label: Text(_statusLabel(status)),
                              selected: controller.statusFilter.value == status,
                              onSelected: (_) =>
                                  controller.selectStatus(status),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    if (controller.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (controller.errorMessage.value.isNotEmpty)
                      _ErrorPanel(
                        message: controller.errorMessage.value,
                        onRetry: controller.loadLoans,
                      )
                    else if (controller.filteredLoans.isEmpty)
                      const _EmptyPanel()
                    else if (desktop)
                      _LoanTable(
                        loans: controller.filteredLoans,
                        currency: currency,
                        dateTime: dateTime,
                        onOpenLoan: onOpenLoan,
                      )
                    else
                      ...controller.filteredLoans.map(
                        (loan) => _LoanCard(
                          loan: loan,
                          currency: currency,
                          dateTime: dateTime,
                          onTap: () => onOpenLoan(loan),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.name,
    required this.email,
    required this.selectedSection,
    required this.sections,
    required this.collapsed,
    required this.unreadCount,
    required this.onSelectSection,
    required this.onToggle,
    required this.onSignOut,
  });

  final String name;
  final String email;
  final AdminSection selectedSection;
  final List<AdminSection> sections;
  final bool collapsed;
  final int unreadCount;
  final ValueChanged<AdminSection> onSelectSection;
  final VoidCallback onToggle;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: collapsed ? 84 : 272,
      color: const Color(0xFF101828),
      padding: EdgeInsets.fromLTRB(
        collapsed ? 12 : 20,
        24,
        collapsed ? 12 : 20,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BrandLogo(
                width: collapsed ? 42 : 142,
                height: 42,
                padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 4 : 10,
                  vertical: 7,
                ),
              ),
              if (!collapsed) const Spacer(),
              IconButton(
                tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
                onPressed: onToggle,
                color: const Color(0xFFD0D5DD),
                icon: Icon(
                  collapsed
                      ? Icons.keyboard_double_arrow_right_rounded
                      : Icons.keyboard_double_arrow_left_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SidebarGroup(
                  label: 'Overview',
                  candidates: const [AdminSection.dashboard],
                  available: sections,
                  selected: selectedSection,
                  collapsed: collapsed,
                  onSelect: onSelectSection,
                ),
                _SidebarGroup(
                  label: 'Loan Management',
                  candidates: const [
                    AdminSection.applications,
                    AdminSection.packages,
                    AdminSection.customers,
                    AdminSection.repayments,
                    AdminSection.transactions,
                    AdminSection.reports,
                  ],
                  available: sections,
                  selected: selectedSection,
                  collapsed: collapsed,
                  onSelect: onSelectSection,
                ),
                _SidebarGroup(
                  label: 'Administration',
                  candidates: const [AdminSection.branches, AdminSection.users],
                  available: sections,
                  selected: selectedSection,
                  collapsed: collapsed,
                  onSelect: onSelectSection,
                ),
                _SidebarGroup(
                  label: 'Account',
                  candidates: const [AdminSection.profile],
                  available: sections,
                  selected: selectedSection,
                  collapsed: collapsed,
                  onSelect: onSelectSection,
                ),
              ],
            ),
          ),
          Center(
            child: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: IconButton(
                tooltip: 'Notifications',
                onPressed: () => appRouter.go('/notifications'),
                color: const Color(0xFFD0D5DD),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ),
          ),
          if (!collapsed) ...[
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 12),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onSignOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF475467)),
                minimumSize: const Size.fromHeight(44),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ] else
            Center(
              child: IconButton(
                tooltip: 'Sign out',
                onPressed: onSignOut,
                color: Colors.white,
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  const _SidebarGroup({
    required this.label,
    required this.candidates,
    required this.available,
    required this.selected,
    required this.collapsed,
    required this.onSelect,
  });

  final String label;
  final List<AdminSection> candidates;
  final List<AdminSection> available;
  final AdminSection selected;
  final bool collapsed;
  final ValueChanged<AdminSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final visible = candidates.where(available.contains).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 7),
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          for (final section in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Tooltip(
                message: collapsed ? adminSectionLabel(section) : '',
                child: Material(
                  color: selected == section
                      ? const Color(0xFF344054)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: collapsed ? 16 : 12,
                    ),
                    minLeadingWidth: 24,
                    leading: Icon(
                      adminSectionIcon(section),
                      color: selected == section
                          ? const Color(0xFF00CED1)
                          : const Color(0xFFD0D5DD),
                    ),
                    title: collapsed
                        ? null
                        : Text(
                            adminSectionLabel(section),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: selected == section
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                    onTap: () => onSelect(section),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.name, required this.onRefresh});

  final String name;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $name',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Monitor and review your lending activity.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 235,
      child: Card(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanTable extends StatelessWidget {
  const _LoanTable({
    required this.loans,
    required this.currency,
    required this.dateTime,
    required this.onOpenLoan,
  });

  final List<AdminLoan> loans;
  final NumberFormat currency;
  final DateFormat dateTime;
  final ValueChanged<AdminLoan> onOpenLoan;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        columns: const [
          DataColumn(label: Text('Application')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Submitted')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('')),
        ],
        rows: loans
            .map(
              (loan) => DataRow(
                cells: [
                  DataCell(Text(loan.loanNumber)),
                  DataCell(
                    SizedBox(
                      width: 190,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.borrower.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            loan.borrower.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(currency.format(loan.principal))),
                  DataCell(Text(dateTime.format(loan.createdAt.toLocal()))),
                  DataCell(_StatusBadge(status: loan.status)),
                  DataCell(
                    TextButton(
                      onPressed: () => onOpenLoan(loan),
                      child: Text(loan.isPending ? 'Review' : 'View'),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({
    required this.loan,
    required this.currency,
    required this.dateTime,
    required this.onTap,
  });

  final AdminLoan loan;
  final NumberFormat currency;
  final DateFormat dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loan.loanNumber,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _StatusBadge(status: loan.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(loan.borrower.fullName),
          Text(
            loan.borrower.email,
            style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  currency.format(loan.principal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(dateTime.format(loan.createdAt.toLocal())),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              child: Text(
                loan.isPending ? 'Review application' : 'View details',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'APPROVED' => const Color(0xFF067647),
      'REJECTED' => const Color(0xFFB42318),
      'CANCELLED' => const Color(0xFF475467),
      _ => const Color(0xFFB54708),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
          ),
          Expanded(child: SelectableText(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 44,
            color: Color(0xFFB42318),
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 52),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF98A2B3)),
          SizedBox(height: 12),
          Text('No loan applications match this filter.'),
        ],
      ),
    );
  }
}

class _ReviewRequest {
  const _ReviewRequest({required this.status, required this.note});

  final String status;
  final String note;
}

String _statusLabel(String status) {
  if (status == 'ALL') {
    return 'All';
  }
  return status[0] + status.substring(1).toLowerCase();
}
