import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/features/admin/controller/admin_dashboard_controller.dart';
import 'package:loan_app/features/admin/model/admin_loan.dart';

enum AdminRecordType { repayments }

enum AdminTransactionView { all, deposits, withdrawals }

String adminSectionLabel(AdminSection section) => switch (section) {
  AdminSection.dashboard => 'Dashboard',
  AdminSection.applications => 'Loan Applications',
  AdminSection.packages => 'Loan Packages',
  AdminSection.customers => 'Customers',
  AdminSection.repayments => 'EMI & Repayments',
  AdminSection.transactions => 'Transactions',
  AdminSection.deposits => 'Deposits',
  AdminSection.withdrawals => 'Withdrawal Requests',
  AdminSection.reports => 'Reports',
  AdminSection.branches => 'Branches',
  AdminSection.users => 'Users & Permissions',
  AdminSection.profile => 'My Profile',
};

IconData adminSectionIcon(AdminSection section) => switch (section) {
  AdminSection.dashboard => Icons.dashboard_customize_outlined,
  AdminSection.applications => Icons.assignment_outlined,
  AdminSection.packages => Icons.account_balance_wallet_outlined,
  AdminSection.customers => Icons.group_outlined,
  AdminSection.repayments => Icons.calendar_month_outlined,
  AdminSection.transactions => Icons.swap_vert_circle_outlined,
  AdminSection.deposits => Icons.add_card_outlined,
  AdminSection.withdrawals => Icons.payments_outlined,
  AdminSection.reports => Icons.analytics_outlined,
  AdminSection.branches => Icons.apartment_outlined,
  AdminSection.users => Icons.manage_accounts_outlined,
  AdminSection.profile => Icons.account_circle_outlined,
};

class AdminOverviewSection extends StatelessWidget {
  const AdminOverviewSection({
    super.key,
    required this.controller,
    required this.currency,
    required this.dateTime,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final NumberFormat currency;
  final DateFormat dateTime;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.overview;
      final recent = _mapList(data['recentTransactions']);
      return _SectionList(
        desktop: desktop,
        onRefresh: controller.loadOverview,
        title: 'Loan Management Dashboard',
        subtitle: 'At-a-glance portfolio performance and recent activity.',
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                title: 'Customers',
                value: '${data['customers'] ?? 0}',
                icon: Icons.people_outline,
                color: const Color(0xFF2E90FA),
              ),
              _MetricCard(
                title: 'Applications',
                value: '${data['applications'] ?? 0}',
                icon: Icons.description_outlined,
                color: const Color(0xFF7F56D9),
              ),
              _MetricCard(
                title: 'Pending review',
                value: '${data['pending'] ?? 0}',
                icon: Icons.schedule_rounded,
                color: const Color(0xFFF79009),
              ),
              _MetricCard(
                title: 'Approved principal',
                value: currency.format(_number(data['approvedPrincipal'])),
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF12B76A),
              ),
              _MetricCard(
                title: 'Pending withdrawals',
                value: '${data['pendingWithdrawals'] ?? 0}',
                icon: Icons.payments_outlined,
                color: const Color(0xFFF04438),
              ),
              _MetricCard(
                title: 'Pending deposits',
                value: '${data['pendingDeposits'] ?? 0}',
                icon: Icons.add_card_outlined,
                color: const Color(0xFF06AED4),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Panel(
            title: 'Portfolio overview',
            subtitle: 'Current application decision status.',
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _StatusTile(
                  label: 'Pending',
                  value: '${data['pending'] ?? 0}',
                  color: const Color(0xFFF79009),
                ),
                _StatusTile(
                  label: 'Approved',
                  value: '${data['approved'] ?? 0}',
                  color: const Color(0xFF12B76A),
                ),
                _StatusTile(
                  label: 'Rejected',
                  value: '${data['rejected'] ?? 0}',
                  color: const Color(0xFFF04438),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Panel(
            title: 'Recent transactions',
            subtitle: 'Latest financial activity across customer accounts.',
            child: recent.isEmpty
                ? const _EmptyState(
                    message: 'No transactions have been recorded yet.',
                  )
                : _SimpleTable(
                    columns: const [
                      'Customer',
                      'Type',
                      'Loan',
                      'Amount',
                      'Date',
                    ],
                    rows: recent
                        .map(
                          (item) => [
                            _nested(item, 'user', 'fullName'),
                            _friendly(item['type']),
                            _nested(item, 'loan', 'loanNumber', fallback: '—'),
                            currency.format(_number(item['amount'])),
                            _date(item['occurredAt'], dateTime),
                          ],
                        )
                        .toList(),
                  ),
          ),
        ],
      );
    });
  }
}

class AdminPackagesSection extends StatelessWidget {
  const AdminPackagesSection({
    super.key,
    required this.controller,
    required this.currency,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final NumberFormat currency;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _SectionList(
        desktop: desktop,
        onRefresh: controller.loadProducts,
        title: 'Loan Packages',
        subtitle:
            'Configure pricing, limits, repayment frequency, and available terms.',
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        action: controller.can('products.manage')
            ? FilledButton.icon(
                onPressed: () => _editProduct(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New package'),
              )
            : null,
        children: [
          if (controller.products.isEmpty)
            const _EmptyState(message: 'No loan packages are configured.')
          else
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: controller.products
                  .map(
                    (product) => _PackageCard(
                      product: product,
                      currency: currency,
                      onEdit: controller.can('products.manage')
                          ? () => _editProduct(context, product)
                          : null,
                      onDelete: controller.can('products.manage')
                          ? () => _deleteProduct(context, product)
                          : null,
                    ),
                  )
                  .toList(),
            ),
        ],
      );
    });
  }

  Future<void> _editProduct(
    BuildContext context, [
    AdminLoanProduct? product,
  ]) async {
    final result = await showDialog<AdminLoanProduct>(
      context: context,
      builder: (_) => _ProductDialog(product: product),
    );
    if (result != null &&
        context.mounted &&
        await _confirmAction(
          context,
          title: product == null
              ? 'Create loan package?'
              : 'Save package changes?',
          message:
              'The package rules will be available to the customer loan API.',
          confirmLabel: product == null ? 'Create package' : 'Save changes',
        )) {
      await controller.saveProduct(result);
    }
  }

  Future<void> _deleteProduct(
    BuildContext context,
    AdminLoanProduct product,
  ) async {
    final confirmed = await _confirmDelete(
      context,
      title: 'Delete ${product.name}?',
      message:
          'A package can only be deleted when no loan application has used it. Otherwise disable it.',
    );
    if (confirmed) {
      await controller.deleteProduct(product);
    }
  }
}

class AdminRecordsSection extends StatelessWidget {
  const AdminRecordsSection({
    super.key,
    required this.controller,
    required this.type,
    required this.currency,
    required this.dateTime,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final AdminRecordType type;
  final NumberFormat currency;
  final DateFormat dateTime;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.repayments;
      return _SectionList(
        desktop: desktop,
        onRefresh: _refresh,
        title: _title,
        subtitle: _subtitle,
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        children: [
          _Panel(
            title: '$_title (${records.length})',
            subtitle: _subtitle,
            child: records.isEmpty
                ? _EmptyState(message: 'No ${_title.toLowerCase()} found.')
                : _SimpleTable(columns: _columns, rows: _rows(records)),
          ),
        ],
      );
    });
  }

  String get _title => 'EMI & Repayments';

  String get _subtitle =>
      'Installment schedules, amounts paid, due dates, and status.';

  Future<void> Function() get _refresh => controller.loadRepayments;

  List<String> get _columns => const [
    'Loan',
    'Customer',
    'Installment',
    'Due date',
    'Amount due',
    'Paid',
    'Status',
  ];

  List<List<String>> _rows(List<Map<String, dynamic>> records) {
    return records
        .map(
          (item) => [
            _nested(item, 'loan', 'loanNumber'),
            _nestedDeep(item, 'loan', 'borrower', 'fullName'),
            '#${item['installment'] ?? 0}',
            _date(item['dueDate'], dateTime, dateOnly: true),
            currency.format(_number(item['amountDue'])),
            currency.format(_number(item['amountPaid'])),
            _friendly(item['status']),
          ],
        )
        .toList();
  }
}

class AdminTransactionsSection extends StatelessWidget {
  const AdminTransactionsSection({
    super.key,
    required this.controller,
    required this.currency,
    required this.dateTime,
    required this.desktop,
    this.view = AdminTransactionView.all,
  });

  final AdminDashboardController controller;
  final NumberFormat currency;
  final DateFormat dateTime;
  final bool desktop;
  final AdminTransactionView view;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.filteredTransactions;
      final title = switch (view) {
        AdminTransactionView.all => 'Transactions & Cash Review',
        AdminTransactionView.deposits => 'Customer Deposits',
        AdminTransactionView.withdrawals => 'Withdrawal Requests',
      };
      final subtitle = switch (view) {
        AdminTransactionView.all =>
          'Review customer cash requests and inspect completed account activity.',
        AdminTransactionView.deposits =>
          'Post back-office deposits and review customer deposit requests.',
        AdminTransactionView.withdrawals =>
          'Approve or reject customer cash-out requests. Every rejection requires a clear reason.',
      };
      return _SectionList(
        desktop: desktop,
        onRefresh: controller.refreshCurrentSection,
        title: title,
        subtitle: subtitle,
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        action:
            controller.can('transactions.manage') &&
                view != AdminTransactionView.withdrawals
            ? FilledButton.icon(
                onPressed: () => _createDeposit(context),
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Add deposit'),
              )
            : null,
        children: [
          if (view == AdminTransactionView.withdrawals)
            _WithdrawalSummary(
              transactions: controller.transactions,
              currency: currency,
            ),
          _TransactionFilters(controller: controller),
          _Panel(
            title: '$title (${records.length})',
            subtitle: view == AdminTransactionView.withdrawals
                ? 'Pending requests require review. Completed withdrawals are permanent financial records.'
                : 'Completed records are immutable; pending or rejected customer requests can be safely removed.',
            child: records.isEmpty
                ? _EmptyState(
                    message: view == AdminTransactionView.withdrawals
                        ? 'No withdrawal requests match this status.'
                        : 'No transactions match this status.',
                  )
                : Column(
                    children: records
                        .map(
                          (transaction) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () =>
                                  _openTransaction(context, transaction),
                              leading: _TransactionAvatar(
                                transaction: transaction,
                              ),
                              title: Text(
                                transaction.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${transaction.customerName} · ${_friendly(transaction.type)} · ${_date(transaction.occurredAt.toIso8601String(), dateTime)}',
                              ),
                              trailing: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                children: [
                                  Text(
                                    currency.format(transaction.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  _RecordStatusChip(status: transaction.status),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      );
    });
  }

  Future<void> _createDeposit(BuildContext context) async {
    if (controller.customers.isEmpty) {
      await controller.loadCustomers();
      if (!context.mounted || controller.customers.isEmpty) {
        return;
      }
    }
    final request = await showDialog<_DepositRequest>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DepositDialog(customers: controller.customers),
    );
    if (request == null || !context.mounted) {
      return;
    }
    final customer = controller.customers.firstWhereOrNull(
      (item) => item.id == request.customerId,
    );
    final confirmed = await _confirmAction(
      context,
      title: 'Post completed deposit?',
      message:
          '${currency.format(request.amount)} will be added immediately to ${customer?.fullName ?? 'the customer'}’s available balance.',
      confirmLabel: 'Post deposit',
    );
    if (confirmed) {
      await controller.createDeposit(
        customerId: request.customerId,
        amount: request.amount,
        description: request.description,
      );
    }
  }

  Future<void> _openTransaction(
    BuildContext context,
    AdminTransaction summary,
  ) async {
    final transaction =
        await controller.loadTransactionDetail(summary.id) ?? summary;
    if (!context.mounted) return;
    final noteController = TextEditingController(
      text: transaction.reviewReason,
    );
    String? reasonError;
    final action = await showDialog<_TransactionAction>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(_friendly(transaction.type))),
              _RecordStatusChip(status: transaction.status),
            ],
          ),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailLine(
                    label: 'Customer',
                    value: transaction.customerName,
                  ),
                  _DetailLine(label: 'Email', value: transaction.customerEmail),
                  if ((transaction.customerPhone ?? '').isNotEmpty)
                    _DetailLine(
                      label: 'Phone',
                      value: transaction.customerPhone!,
                    ),
                  if ((transaction.customerIdNumber ?? '').isNotEmpty)
                    _DetailLine(
                      label: 'ID number',
                      value: transaction.customerIdNumber!,
                    ),
                  _DetailLine(
                    label: 'Description',
                    value: transaction.description,
                  ),
                  _DetailLine(
                    label: 'Amount',
                    value: currency.format(transaction.amount),
                  ),
                  _DetailLine(
                    label: 'Requested',
                    value: dateTime.format(transaction.occurredAt.toLocal()),
                  ),
                  if (transaction.loanNumber != null)
                    _DetailLine(label: 'Loan', value: transaction.loanNumber!),
                  if (transaction.reviewerName != null)
                    _DetailLine(
                      label: 'Reviewed by',
                      value: transaction.reviewerName!,
                    ),
                  if ((transaction.reviewReason ?? '').isNotEmpty)
                    _DetailLine(
                      label: 'Review reason',
                      value: transaction.reviewReason!,
                    ),
                  if (transaction.isPending &&
                      controller.can('transactions.manage')) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: transaction.type == 'WITHDRAWAL'
                            ? 'Rejection reason'
                            : 'Review note',
                        hintText:
                            'Required for rejection, for example: payout account could not be verified',
                        errorText: reasonError,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (transaction.canDelete && controller.can('transactions.manage'))
              TextButton.icon(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  const _TransactionAction(status: 'DELETE'),
                ),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            if (transaction.isPending &&
                controller.can('transactions.manage')) ...[
              OutlinedButton.icon(
                onPressed: () {
                  if (noteController.text.trim().length < 5) {
                    setDialogState(() {
                      reasonError =
                          'Enter a clear rejection reason of at least 5 characters.';
                    });
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    _TransactionAction(
                      status: 'REJECTED',
                      reason: noteController.text.trim(),
                    ),
                  );
                },
                icon: const Icon(Icons.close_rounded),
                label: Text(
                  transaction.type == 'WITHDRAWAL'
                      ? 'Reject withdrawal'
                      : 'Reject',
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  _TransactionAction(
                    status: 'COMPLETED',
                    reason: noteController.text.trim(),
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  transaction.type == 'WITHDRAWAL'
                      ? 'Approve withdrawal'
                      : 'Approve',
                ),
              ),
            ],
          ],
        ),
      ),
    );
    noteController.dispose();
    if (action == null || !context.mounted) {
      return;
    }
    if (action.status == 'DELETE') {
      final confirmed = await _confirmDelete(
        context,
        title: 'Delete this transaction request?',
        message:
            'Only pending or rejected requests can be deleted. Completed financial records remain immutable.',
      );
      if (confirmed) {
        await controller.deleteTransaction(transaction);
      }
      return;
    }
    final confirmed = await _confirmAction(
      context,
      title: action.status == 'COMPLETED'
          ? 'Approve transaction?'
          : 'Reject transaction?',
      message: action.status == 'COMPLETED'
          ? transaction.type == 'WITHDRAWAL'
                ? '${currency.format(transaction.amount)} will be deducted from the customer balance and marked completed.'
                : 'The request will be completed and the customer balance will update.'
          : 'The customer will receive this reason: ${action.reason}',
      confirmLabel: action.status == 'COMPLETED' ? 'Approve' : 'Reject',
    );
    if (confirmed) {
      await controller.reviewTransaction(
        transaction: transaction,
        status: action.status,
        reason: action.reason,
      );
    }
  }
}

class _TransactionFilters extends StatelessWidget {
  const _TransactionFilters({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    const statuses = ['ALL', 'PENDING', 'COMPLETED', 'REJECTED'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final count = status == 'ALL'
            ? controller.transactions.length
            : controller.transactionCountFor(status);
        return ChoiceChip(
          selected: controller.transactionStatusFilter.value == status,
          onSelected: (_) => controller.setTransactionStatusFilter(status),
          avatar: Icon(switch (status) {
            'PENDING' => Icons.schedule_rounded,
            'COMPLETED' => Icons.check_circle_outline_rounded,
            'REJECTED' => Icons.cancel_outlined,
            _ => Icons.list_alt_rounded,
          }, size: 17),
          label: Text('${_friendly(status)}  $count'),
        );
      }).toList(),
    );
  }
}

class _WithdrawalSummary extends StatelessWidget {
  const _WithdrawalSummary({
    required this.transactions,
    required this.currency,
  });

  final List<AdminTransaction> transactions;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final pending = transactions
        .where((item) => item.status == 'PENDING')
        .toList();
    final completed = transactions
        .where((item) => item.status == 'COMPLETED')
        .toList();
    final rejected = transactions
        .where((item) => item.status == 'REJECTED')
        .toList();
    final pendingAmount = pending.fold<double>(
      0,
      (total, item) => total + item.amount,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 780
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _WithdrawalMetric(
              width: cardWidth,
              icon: Icons.pending_actions_rounded,
              label: 'Pending review',
              value: '${pending.length}',
              detail: currency.format(pendingAmount),
              color: const Color(0xFFF79009),
            ),
            _WithdrawalMetric(
              width: cardWidth,
              icon: Icons.task_alt_rounded,
              label: 'Completed',
              value: '${completed.length}',
              detail: 'Approved cash-outs',
              color: const Color(0xFF12B76A),
            ),
            _WithdrawalMetric(
              width: cardWidth,
              icon: Icons.do_not_disturb_alt_rounded,
              label: 'Rejected',
              value: '${rejected.length}',
              detail: 'Reason sent to customer',
              color: const Color(0xFFF04438),
            ),
          ],
        );
      },
    );
  }
}

class _WithdrawalMetric extends StatelessWidget {
  const _WithdrawalMetric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .14),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TransactionAvatar extends StatelessWidget {
  const _TransactionAvatar({required this.transaction});

  final AdminTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'DEPOSIT';
    final color = isDeposit ? const Color(0xFF12B76A) : const Color(0xFFF04438);
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: .14),
      child: Icon(
        isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
        color: color,
      ),
    );
  }
}

class _DepositDialog extends StatefulWidget {
  const _DepositDialog({required this.customers});

  final List<AdminCustomer> customers;

  @override
  State<_DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<_DepositDialog> {
  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final description = TextEditingController(text: 'Back-office cash deposit');
  String? customerId;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add customer deposit'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: customerId,
              decoration: const InputDecoration(
                labelText: 'Customer',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: widget.customers
                  .where((customer) => customer.isActive)
                  .map(
                    (customer) => DropdownMenuItem(
                      value: customer.id,
                      child: Text(customer.fullName),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => customerId = value),
              validator: (value) => value == null ? 'Select a customer.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Deposit amount',
                prefixText: '₱ ',
              ),
              validator: (value) {
                final number = double.tryParse(
                  (value ?? '').replaceAll(',', ''),
                );
                return number != null && number > 0
                    ? null
                    : 'Enter a valid amount.';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: description,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              validator: (value) => (value ?? '').trim().length >= 2
                  ? null
                  : 'Enter a description.',
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Continue'),
      ),
    ],
  );

  void _submit() {
    if (!formKey.currentState!.validate() || customerId == null) {
      return;
    }
    Navigator.pop(
      context,
      _DepositRequest(
        customerId: customerId!,
        amount: double.parse(amount.text.replaceAll(',', '')),
        description: description.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    amount.dispose();
    description.dispose();
    super.dispose();
  }
}

class _DepositRequest {
  const _DepositRequest({
    required this.customerId,
    required this.amount,
    required this.description,
  });

  final String customerId;
  final double amount;
  final String description;
}

class _TransactionAction {
  const _TransactionAction({required this.status, this.reason});

  final String status;
  final String? reason;
}

class AdminReportsSection extends StatelessWidget {
  const AdminReportsSection({
    super.key,
    required this.controller,
    required this.currency,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final NumberFormat currency;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.report;
      final loanStatuses = _mapList(data['loanStatuses']);
      final repaymentStatuses = _mapList(data['repaymentStatuses']);
      return _SectionList(
        desktop: desktop,
        onRefresh: controller.loadReport,
        title: 'Overall Report',
        subtitle: 'Portfolio, disbursement, collection, and EMI performance.',
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                title: 'Total disbursed',
                value: currency.format(_number(data['totalDisbursed'])),
                icon: Icons.north_east_rounded,
                color: const Color(0xFF7F56D9),
              ),
              _MetricCard(
                title: 'Total collected',
                value: currency.format(_number(data['totalCollected'])),
                icon: Icons.south_west_rounded,
                color: const Color(0xFF12B76A),
              ),
              _MetricCard(
                title: 'Loan statuses',
                value:
                    '${loanStatuses.fold<int>(0, (sum, item) => sum + _number(item['count']).toInt())}',
                icon: Icons.pie_chart_outline,
                color: const Color(0xFF2E90FA),
              ),
              _MetricCard(
                title: 'EMI records',
                value:
                    '${repaymentStatuses.fold<int>(0, (sum, item) => sum + _number(item['count']).toInt())}',
                icon: Icons.calculate_outlined,
                color: const Color(0xFFF79009),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Panel(
            title: 'Loan overview',
            subtitle: 'Application count and principal by status.',
            child: _SimpleTable(
              columns: const [
                'Status',
                'Applications',
                'Principal',
                'Expected repayment',
              ],
              rows: loanStatuses
                  .map(
                    (item) => [
                      _friendly(item['status']),
                      '${item['count'] ?? 0}',
                      currency.format(_number(item['principal'])),
                      currency.format(_number(item['totalRepayment'])),
                    ],
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 22),
          _Panel(
            title: 'EMI report',
            subtitle: 'Installment totals grouped by payment status.',
            child: _SimpleTable(
              columns: const [
                'Status',
                'Installments',
                'Amount due',
                'Amount paid',
              ],
              rows: repaymentStatuses
                  .map(
                    (item) => [
                      _friendly(item['status']),
                      '${item['count'] ?? 0}',
                      currency.format(_number(item['amountDue'])),
                      currency.format(_number(item['amountPaid'])),
                    ],
                  )
                  .toList(),
            ),
          ),
        ],
      );
    });
  }
}

class AdminBranchesSection extends StatelessWidget {
  const AdminBranchesSection({
    super.key,
    required this.controller,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _SectionList(
        desktop: desktop,
        onRefresh: controller.loadBranches,
        title: 'Branches',
        subtitle: 'Manage operating locations and branch contacts.',
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        action: controller.can('branches.manage')
            ? FilledButton.icon(
                onPressed: () => _editBranch(context),
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('New branch'),
              )
            : null,
        children: [
          if (controller.branches.isEmpty)
            const _EmptyState(message: 'No branches are configured.')
          else
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: controller.branches
                  .map(
                    (branch) => _BranchCard(
                      branch: branch,
                      onEdit: controller.can('branches.manage')
                          ? () => _editBranch(context, branch)
                          : null,
                      onDelete: controller.can('branches.manage')
                          ? () => _deleteBranch(context, branch)
                          : null,
                    ),
                  )
                  .toList(),
            ),
        ],
      );
    });
  }

  Future<void> _editBranch(BuildContext context, [AdminBranch? branch]) async {
    final result = await showDialog<AdminBranch>(
      context: context,
      builder: (_) => _BranchDialog(branch: branch),
    );
    if (result != null &&
        context.mounted &&
        await _confirmAction(
          context,
          title: branch == null ? 'Create branch?' : 'Save branch changes?',
          message: 'The branch information will be updated in PostgreSQL.',
          confirmLabel: branch == null ? 'Create branch' : 'Save changes',
        )) {
      await controller.saveBranch(result);
    }
  }

  Future<void> _deleteBranch(BuildContext context, AdminBranch branch) async {
    final confirmed = await _confirmDelete(
      context,
      title: 'Delete ${branch.name}?',
      message: 'This branch will be permanently removed.',
    );
    if (confirmed) {
      await controller.deleteBranch(branch);
    }
  }
}

class AdminCustomersSection extends StatelessWidget {
  const AdminCustomersSection({
    super.key,
    required this.controller,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _SectionList(
        desktop: desktop,
        onRefresh: controller.loadCustomers,
        title: 'Customer Accounts',
        subtitle:
            'Registered borrowers are managed separately from back-office users.',
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        action: controller.can('customers.manage')
            ? FilledButton.icon(
                onPressed: () => _editCustomer(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Register customer'),
              )
            : null,
        children: [
          _Panel(
            title: 'Customer directory (${controller.customers.length})',
            subtitle:
                'Account status, session presence, loans, and transactions are loaded from PostgreSQL.',
            child: controller.customers.isEmpty
                ? const _EmptyState(message: 'No customer accounts were found.')
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: controller.customers
                        .map(
                          (customer) => _CustomerCard(
                            customer: customer,
                            onView: () => _viewCustomer(context, customer),
                            onEdit: controller.can('customers.manage')
                                ? () => _editCustomer(context, customer)
                                : null,
                            onDelete: controller.can('customers.manage')
                                ? () => _deleteCustomer(context, customer)
                                : null,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _editCustomer(
    BuildContext context, [
    AdminCustomer? customer,
  ]) async {
    final result = await showDialog<AdminCustomer>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CustomerDialog(customer: customer),
    );
    if (result != null &&
        context.mounted &&
        await _confirmAction(
          context,
          title: customer == null
              ? 'Register customer?'
              : 'Save customer changes?',
          message:
              'Identity, contact, photo, and account access will be updated through the API.',
          confirmLabel: customer == null ? 'Register customer' : 'Save changes',
        )) {
      await controller.saveCustomer(result);
    }
  }

  Future<void> _viewCustomer(BuildContext context, AdminCustomer customer) {
    final date = DateFormat('dd MMM yyyy');
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            _CustomerAvatar(customer: customer, radius: 25),
            const SizedBox(width: 12),
            Expanded(child: Text(customer.fullName)),
          ],
        ),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailLine(label: 'Email', value: customer.email),
                _DetailLine(
                  label: 'Phone',
                  value: customer.phone ?? 'Not provided',
                ),
                _DetailLine(
                  label: 'ID number',
                  value: customer.idNumber ?? 'Not provided',
                ),
                _DetailLine(
                  label: 'Date of birth',
                  value: customer.dateOfBirth == null
                      ? 'Not provided'
                      : date.format(customer.dateOfBirth!.toLocal()),
                ),
                _DetailLine(
                  label: 'Gender',
                  value: customer.gender ?? 'Not provided',
                ),
                _DetailLine(
                  label: 'Address',
                  value: customer.address ?? 'Not provided',
                ),
                _DetailLine(
                  label: 'Account status',
                  value: customer.isActive ? 'Enabled' : 'Disabled',
                ),
                _DetailLine(label: 'Presence', value: customer.presenceStatus),
                _DetailLine(
                  label: 'Financial activity',
                  value:
                      '${customer.loanCount} loans · ${customer.transactionCount} transactions',
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
          if (controller.can('customers.manage'))
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _editCustomer(context, customer);
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(
    BuildContext context,
    AdminCustomer customer,
  ) async {
    final confirmed = await _confirmDelete(
      context,
      title: 'Delete ${customer.fullName}?',
      message:
          'Only customers without loan or transaction history can be deleted. Otherwise disable the account.',
    );
    if (confirmed) {
      await controller.deleteCustomer(customer);
    }
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.onView,
    this.onEdit,
    this.onDelete,
  });

  final AdminCustomer customer;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final presenceColor = customer.isOnline
        ? const Color(0xFF12B76A)
        : colors.outline;
    return Container(
      width: 340,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _CustomerAvatar(customer: customer),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: presenceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      customer.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(Icons.circle, size: 10, color: presenceColor),
                label: Text(customer.presenceStatus),
              ),
              Chip(label: Text(customer.isActive ? 'Enabled' : 'Disabled')),
              Chip(label: Text('${customer.loanCount} loans')),
              Chip(label: Text('${customer.transactionCount} transactions')),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            customer.lastSeenAt == null
                ? 'No login activity yet'
                : 'Last seen ${DateFormat('MMM d, y · h:mm a').format(customer.lastSeenAt!.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View'),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Edit customer',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
              if (onDelete != null) ...[
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  tooltip: 'Delete customer',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
          if (onEdit != null) ...[
            const SizedBox(height: 14),
            Text(
              'Use Edit to update identity, contact, photo, and account access.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.customer, this.radius = 20});

  final AdminCustomer customer;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final photo = customer.profilePhotoUrl?.trim() ?? '';
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      backgroundImage: photo.isEmpty ? null : NetworkImage(photo),
      child: photo.isEmpty
          ? Text(
              customer.fullName.isEmpty
                  ? '?'
                  : customer.fullName[0].toUpperCase(),
            )
          : null,
    );
  }
}

class _CustomerDialog extends StatefulWidget {
  const _CustomerDialog({this.customer});

  final AdminCustomer? customer;

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController fullName;
  late final TextEditingController email;
  late final TextEditingController idNumber;
  late final TextEditingController phone;
  late final TextEditingController dateOfBirth;
  late final TextEditingController gender;
  late final TextEditingController address;
  late final TextEditingController profilePhotoUrl;
  late final TextEditingController password;
  late bool active;
  bool obscurePassword = true;

  bool get isNew => widget.customer == null;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    fullName = TextEditingController(text: customer?.fullName ?? '');
    email = TextEditingController(text: customer?.email ?? '');
    idNumber = TextEditingController(text: customer?.idNumber ?? '');
    phone = TextEditingController(text: customer?.phone ?? '');
    dateOfBirth = TextEditingController(
      text: customer?.dateOfBirth?.toIso8601String().split('T').first ?? '',
    );
    gender = TextEditingController(text: customer?.gender ?? '');
    address = TextEditingController(text: customer?.address ?? '');
    profilePhotoUrl = TextEditingController(
      text: customer?.profilePhotoUrl ?? '',
    );
    password = TextEditingController();
    active = customer?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isNew ? 'Register customer' : 'Edit customer'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullName,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    return text.contains('@') && text.contains('.')
                        ? null
                        : 'Enter a valid email address.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: idNumber,
                  decoration: const InputDecoration(
                    labelText: 'ID number (optional)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    return text.isEmpty || text.length >= 4
                        ? null
                        : 'Use at least 4 characters.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number (optional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    return text.isEmpty || text.length >= 7
                        ? null
                        : 'Use at least 7 characters.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dateOfBirth,
                  decoration: const InputDecoration(
                    labelText: 'Date of birth (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    return text.isEmpty || DateTime.tryParse(text) != null
                        ? null
                        : 'Use the YYYY-MM-DD format.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender (optional)',
                    prefixIcon: Icon(Icons.person_search_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: address,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    return text.isEmpty || text.length >= 5
                        ? null
                        : 'Use at least 5 characters.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: profilePhotoUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Profile photo URL (optional)',
                    prefixIcon: Icon(Icons.photo_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    return text.isEmpty ||
                            Uri.tryParse(text)?.hasAbsolutePath == true
                        ? null
                        : 'Enter a complete image URL.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: isNew
                        ? 'Temporary password'
                        : 'New password (leave blank to keep)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final text = value ?? '';
                    if (isNew && text.isEmpty) {
                      return 'A temporary password is required.';
                    }
                    return text.isEmpty || text.length >= 12
                        ? null
                        : 'Use at least 12 characters.';
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Customer account enabled'),
                  subtitle: const Text(
                    'Disabled customers cannot sign in or submit applications.',
                  ),
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(isNew ? 'Register customer' : 'Save changes'),
        ),
      ],
    );
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'This field is required.' : null;

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    final existing = widget.customer;
    Navigator.pop(
      context,
      AdminCustomer(
        id: existing?.id ?? '',
        email: email.text.trim().toLowerCase(),
        fullName: fullName.text.trim(),
        idNumber: idNumber.text.trim().isEmpty ? null : idNumber.text.trim(),
        phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        dateOfBirth: dateOfBirth.text.trim().isEmpty
            ? null
            : DateTime.tryParse(dateOfBirth.text.trim()),
        gender: gender.text.trim().isEmpty ? null : gender.text.trim(),
        address: address.text.trim().isEmpty ? null : address.text.trim(),
        profilePhotoUrl: profilePhotoUrl.text.trim().isEmpty
            ? null
            : profilePhotoUrl.text.trim(),
        isActive: active,
        isOnline: existing?.isOnline ?? false,
        loanCount: existing?.loanCount ?? 0,
        transactionCount: existing?.transactionCount ?? 0,
        createdAt: existing?.createdAt ?? DateTime.now(),
        lastLoginAt: existing?.lastLoginAt,
        lastSeenAt: existing?.lastSeenAt,
        password: password.text,
      ),
    );
  }

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    idNumber.dispose();
    phone.dispose();
    dateOfBirth.dispose();
    gender.dispose();
    address.dispose();
    profilePhotoUrl.dispose();
    password.dispose();
    super.dispose();
  }
}

class AdminUsersSection extends StatelessWidget {
  const AdminUsersSection({
    super.key,
    required this.controller,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _SectionList(
        desktop: desktop,
        onRefresh: controller.loadUsers,
        title: 'Users & Permissions',
        subtitle:
            'Create staff and administrator accounts with database-backed access.',
        loading: controller.isLoading.value,
        error: controller.errorMessage.value,
        action: FilledButton.icon(
          onPressed: () => _editUser(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('New user'),
        ),
        children: [
          _Panel(
            title: 'Account directory (${controller.users.length})',
            subtitle: controller.can('permissions.manage')
                ? 'Permissions are loaded from PostgreSQL and can be customized per account.'
                : 'You can manage accounts, but permission assignment is restricted.',
            child: controller.users.isEmpty
                ? const _EmptyState(message: 'No user accounts were found.')
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: controller.users
                        .map(
                          (user) => _UserCard(
                            user: user,
                            isCurrentUser:
                                user.id == controller.currentUser.value?.id,
                            onEdit: () => _editUser(context, user),
                            onDelete:
                                user.id == controller.currentUser.value?.id
                                ? null
                                : () => _deleteUser(context, user),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      );
    });
  }

  Future<void> _editUser(BuildContext context, [AdminUser? user]) async {
    final result = await showDialog<AdminUser>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UserDialog(
        user: user,
        permissions: controller.permissions,
        canAssignPermissions: controller.can('permissions.manage'),
      ),
    );
    if (result != null &&
        context.mounted &&
        await _confirmAction(
          context,
          title: user == null
              ? 'Create back-office user?'
              : 'Save user changes?',
          message:
              'Role and permission changes take effect on the user’s next API request.',
          confirmLabel: user == null ? 'Create user' : 'Save changes',
        )) {
      await controller.saveUser(result);
    }
  }

  Future<void> _deleteUser(BuildContext context, AdminUser user) async {
    final confirmed = await _confirmDelete(
      context,
      title: 'Delete ${user.fullName}?',
      message:
          'The back-office account and its active session will be permanently removed.',
    );
    if (confirmed) {
      await controller.deleteUser(user);
    }
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isCurrentUser,
    required this.onEdit,
    this.onDelete,
  });

  final AdminUser user;
  final bool isCurrentUser;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 330,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: Text(
                  user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.circle,
                size: 13,
                color: user.isOnline ? const Color(0xFF12B76A) : colors.outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(_friendly(user.role))),
              if (isCurrentUser) const Chip(label: Text('You')),
              Chip(label: Text(user.isOnline ? 'Online' : 'Offline')),
              Chip(label: Text('${user.permissions.length} permissions')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.lastSeenAt == null
                ? 'No login activity yet'
                : 'Last seen ${DateFormat('MMM d, y · h:mm a').format(user.lastSeenAt!.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit account'),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Delete account',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AdminProfileSection extends StatelessWidget {
  const AdminProfileSection({
    super.key,
    required this.controller,
    required this.desktop,
  });

  final AdminDashboardController controller;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;
    return _SectionList(
      desktop: desktop,
      onRefresh: controller.initialize,
      title: 'My Profile',
      subtitle: 'Authenticated administrator account and security status.',
      children: [
        _Panel(
          title: user?.fullName ?? 'Administrator',
          subtitle: user?.email ?? '',
          child: Column(
            children: [
              _ProfileRow(label: 'Role', value: _friendly(user?.role)),
              const _ProfileRow(
                label: 'Session policy',
                value: 'One active device per account',
              ),
              const _ProfileRow(
                label: 'Access token',
                value: '15-minute rotating access',
              ),
              const _ProfileRow(
                label: 'Database',
                value: 'Supabase PostgreSQL',
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await _confirmAction(
                      context,
                      title: 'Sign out of the admin portal?',
                      message: 'This device session will be closed.',
                      confirmLabel: 'Sign out',
                    );
                    if (confirmed) {
                      await controller.signOut();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({
    required this.desktop,
    required this.onRefresh,
    required this.title,
    required this.subtitle,
    required this.children,
    this.loading = false,
    this.error = '',
    this.action,
  });

  final bool desktop;
  final Future<void> Function() onRefresh;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool loading;
  final String error;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.all(desktop ? 32 : 18),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 26),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error.isNotEmpty)
            _Panel(
              title: 'Unable to load data',
              subtitle: error,
              child: OutlinedButton(
                onPressed: onRefresh,
                child: const Text('Try again'),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 235,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(title, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}

class _SimpleTable extends StatelessWidget {
  const _SimpleTable({required this.columns, required this.rows});
  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const _EmptyState(message: 'No report data is available.');
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        columns: columns
            .map((column) => DataColumn(label: Text(column)))
            .toList(),
        rows: rows
            .map(
              (row) => DataRow(
                cells: row.map((value) => DataCell(Text(value))).toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.product,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminLoanProduct product;
  final NumberFormat currency;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 410,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    if (product.isDefault) ...[
                      const SizedBox(width: 8),
                      const Chip(label: Text('Default')),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  product.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF667085)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PackageHero(
                      value:
                          '${(product.monthlyInterestRate * 100).toStringAsFixed(2)}%',
                      label: 'Monthly interest',
                    ),
                    _PackageHero(
                      value: currency.format(product.minimumAmount),
                      label: 'Minimum amount',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                _PackageLine(
                  label: 'Maximum amount',
                  value: currency.format(product.maximumAmount),
                ),
                _PackageLine(
                  label: 'EMI type',
                  value: _friendly(product.repaymentFrequency),
                ),
                _PackageLine(
                  label: 'Loan tenure',
                  value: product.allowedTerms
                      .map((term) => '$term mo')
                      .join(', '),
                ),
                _PackageLine(
                  label: 'Availability',
                  value: product.isActive ? 'Active' : 'Inactive',
                ),
                const SizedBox(height: 16),
                if (onEdit != null || onDelete != null)
                  Row(
                    children: [
                      if (onEdit != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onEdit,
                            child: const Text('Edit package'),
                          ),
                        ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Delete package',
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageHero extends StatelessWidget {
  const _PackageHero({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
      ),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
      ),
    ],
  );
}

class _PackageLine extends StatelessWidget {
  const _PackageLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF667085))),
        ),
        Text(value),
      ],
    ),
  );
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminBranch branch;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: Color(0xFF2E90FA),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  branch.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(label: Text(branch.isActive ? 'Active' : 'Inactive')),
            ],
          ),
          const SizedBox(height: 14),
          Text(branch.address),
          const SizedBox(height: 8),
          Text(branch.phone),
          Text(branch.email ?? '—'),
          const SizedBox(height: 14),
          if (onEdit != null || onDelete != null)
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEdit,
                      child: const Text('Edit branch'),
                    ),
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Delete branch',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _UserDialog extends StatefulWidget {
  const _UserDialog({
    required this.permissions,
    required this.canAssignPermissions,
    this.user,
  });

  final AdminUser? user;
  final List<AdminPermission> permissions;
  final bool canAssignPermissions;

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController fullName;
  late final TextEditingController email;
  late final TextEditingController idNumber;
  late final TextEditingController password;
  late String role;
  late bool active;
  late Set<String> selectedPermissions;
  bool obscurePassword = true;

  bool get isNew => widget.user == null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    fullName = TextEditingController(text: user?.fullName ?? '');
    email = TextEditingController(text: user?.email ?? '');
    idNumber = TextEditingController(text: user?.idNumber ?? '');
    password = TextEditingController();
    role = user?.role ?? 'STAFF';
    active = user?.isActive ?? true;
    selectedPermissions = user == null
        ? _defaultsForRole(role)
        : user.permissions.toSet();
  }

  Set<String> _defaultsForRole(String selectedRole) => widget.permissions
      .where((permission) => permission.defaultRoles.contains(selectedRole))
      .map((permission) => permission.key)
      .toSet();

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<AdminPermission>>{};
    for (final permission in widget.permissions) {
      grouped.putIfAbsent(permission.category, () => []).add(permission);
    }
    return AlertDialog(
      title: Text(isNew ? 'Create user account' : 'Edit user account'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fullName,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!text.contains('@') || !text.contains('.')) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: idNumber,
                  decoration: const InputDecoration(
                    labelText: 'ID number (optional)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isNotEmpty && text.length < 4) {
                      return 'ID number must contain at least 4 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: isNew
                        ? 'Temporary password'
                        : 'New password (leave blank to keep)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final text = value ?? '';
                    if (isNew && text.isEmpty) {
                      return 'A temporary password is required.';
                    }
                    if (text.isNotEmpty && text.length < 12) {
                      return 'Use at least 12 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(
                    labelText: 'Account role',
                    prefixIcon: Icon(Icons.security_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'STAFF', child: Text('Staff')),
                    DropdownMenuItem(
                      value: 'ADMIN',
                      child: Text('Administrator'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      role = value;
                      if (widget.canAssignPermissions) {
                        selectedPermissions = _defaultsForRole(value);
                      }
                    });
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Account enabled'),
                  subtitle: const Text(
                    'Disabled users cannot sign in or refresh a session.',
                  ),
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Database permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text('${selectedPermissions.length} selected'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  role == 'ADMIN'
                      ? 'Administrators are super users and always receive every database permission.'
                      : widget.canAssignPermissions
                      ? 'Role defaults are preselected. Customize access below.'
                      : 'Only an account with permission-management access can change these values.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                for (final entry in grouped.entries)
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      initiallyExpanded:
                          entry.key == 'Dashboard' || entry.key == 'Loans',
                      title: Text(entry.key),
                      subtitle: Text(
                        '${entry.value.where((item) => selectedPermissions.contains(item.key)).length} of ${entry.value.length} enabled',
                      ),
                      children: entry.value
                          .map(
                            (permission) => CheckboxListTile(
                              value: selectedPermissions.contains(
                                permission.key,
                              ),
                              onChanged:
                                  widget.canAssignPermissions && role != 'ADMIN'
                                  ? (value) => setState(() {
                                      if (value == true) {
                                        selectedPermissions.add(permission.key);
                                      } else {
                                        selectedPermissions.remove(
                                          permission.key,
                                        );
                                      }
                                    })
                                  : null,
                              title: Text(permission.name),
                              subtitle: Text(permission.description),
                              secondary: const Icon(Icons.key_outlined),
                              controlAffinity: ListTileControlAffinity.trailing,
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(isNew ? 'Create account' : 'Save changes'),
        ),
      ],
    );
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'This field is required.' : null;

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      AdminUser(
        id: widget.user?.id ?? '',
        email: email.text.trim().toLowerCase(),
        fullName: fullName.text.trim(),
        idNumber: idNumber.text.trim().isEmpty ? null : idNumber.text.trim(),
        role: role,
        isActive: active,
        isOnline: widget.user?.isOnline ?? false,
        permissions: selectedPermissions.toList()..sort(),
        lastLoginAt: widget.user?.lastLoginAt,
        lastSeenAt: widget.user?.lastSeenAt,
        password: password.text,
      ),
    );
  }

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    idNumber.dispose();
    password.dispose();
    super.dispose();
  }
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({this.product});
  final AdminLoanProduct? product;
  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController code;
  late final TextEditingController name;
  late final TextEditingController description;
  late final TextEditingController minimum;
  late final TextEditingController maximum;
  late final TextEditingController interest;
  late final TextEditingController terms;
  String frequency = 'MONTHLY';
  bool active = true;
  bool defaultProduct = false;

  @override
  void initState() {
    super.initState();
    final item = widget.product;
    code = TextEditingController(text: item?.code ?? '');
    name = TextEditingController(text: item?.name ?? '');
    description = TextEditingController(text: item?.description ?? '');
    minimum = TextEditingController(
      text: item?.minimumAmount.toStringAsFixed(0) ?? '70000',
    );
    maximum = TextEditingController(
      text: item?.maximumAmount.toStringAsFixed(0) ?? '1500000',
    );
    interest = TextEditingController(
      text: ((item?.monthlyInterestRate ?? .005) * 100).toStringAsFixed(2),
    );
    terms = TextEditingController(
      text: item?.allowedTerms.join(', ') ?? '4, 12, 24, 36',
    );
    frequency = item?.repaymentFrequency ?? 'MONTHLY';
    active = item?.isActive ?? true;
    defaultProduct = item?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.product == null ? 'New loan package' : 'Edit loan package',
      ),
      content: SizedBox(
        width: 620,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(code, 'Code', uppercase: true),
                _field(name, 'Package name'),
                _field(description, 'Description', lines: 2),
                Row(
                  children: [
                    Expanded(
                      child: _field(minimum, 'Minimum amount', number: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(maximum, 'Maximum amount', number: true),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        interest,
                        'Monthly interest (%)',
                        number: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _field(terms, 'Terms in months')),
                  ],
                ),
                DropdownButtonFormField<String>(
                  initialValue: frequency,
                  decoration: const InputDecoration(
                    labelText: 'Repayment frequency',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
                    DropdownMenuItem(
                      value: 'BIWEEKLY',
                      child: Text('Biweekly'),
                    ),
                    DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                  ],
                  onChanged: (value) =>
                      setState(() => frequency = value ?? 'MONTHLY'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active package'),
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Default customer package'),
                  value: defaultProduct,
                  onChanged: (value) => setState(() => defaultProduct = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save package')),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
    bool uppercase = false,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textCapitalization: uppercase
            ? TextCapitalization.characters
            : TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value ?? '').trim().isEmpty ? '$label is required.' : null,
      ),
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    final allowedTerms = terms.text
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toList();
    final minValue = double.tryParse(minimum.text);
    final maxValue = double.tryParse(maximum.text);
    final rate = double.tryParse(interest.text);
    if (allowedTerms.isEmpty ||
        minValue == null ||
        maxValue == null ||
        rate == null ||
        maxValue < minValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check the amount, interest, and term values.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      AdminLoanProduct(
        id: widget.product?.id ?? '',
        code: code.text.trim().toUpperCase(),
        name: name.text.trim(),
        description: description.text.trim(),
        currency: widget.product?.currency ?? 'PHP',
        minimumAmount: minValue,
        maximumAmount: maxValue,
        monthlyInterestRate: rate / 100,
        allowedTerms: allowedTerms,
        repaymentFrequency: frequency,
        isActive: active,
        isDefault: defaultProduct,
      ),
    );
  }

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    description.dispose();
    minimum.dispose();
    maximum.dispose();
    interest.dispose();
    terms.dispose();
    super.dispose();
  }
}

class _BranchDialog extends StatefulWidget {
  const _BranchDialog({this.branch});
  final AdminBranch? branch;
  @override
  State<_BranchDialog> createState() => _BranchDialogState();
}

class _BranchDialogState extends State<_BranchDialog> {
  final formKey = GlobalKey<FormState>();
  late final List<TextEditingController> fields;
  bool active = true;

  @override
  void initState() {
    super.initState();
    final item = widget.branch;
    fields = [
      TextEditingController(text: item?.code),
      TextEditingController(text: item?.name),
      TextEditingController(text: item?.address),
      TextEditingController(text: item?.phone),
      TextEditingController(text: item?.email),
      TextEditingController(text: item?.managerName),
    ];
    active = item?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Code',
      'Branch name',
      'Address',
      'Phone',
      'Email',
      'Manager name',
    ];
    return AlertDialog(
      title: Text(widget.branch == null ? 'New branch' : 'Edit branch'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var index = 0; index < fields.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: fields[index],
                      decoration: InputDecoration(
                        labelText: labels[index],
                        border: const OutlineInputBorder(),
                      ),
                      validator: index < 4
                          ? (value) => (value ?? '').trim().isEmpty
                                ? '${labels[index]} is required.'
                                : null
                          : null,
                    ),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active branch'),
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save branch')),
      ],
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      AdminBranch(
        id: widget.branch?.id ?? '',
        code: fields[0].text.trim().toUpperCase(),
        name: fields[1].text.trim(),
        address: fields[2].text.trim(),
        phone: fields[3].text.trim(),
        email: fields[4].text.trim().isEmpty ? null : fields[4].text.trim(),
        managerName: fields[5].text.trim().isEmpty
            ? null
            : fields[5].text.trim(),
        isActive: active,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in fields) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(
          width: 170,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Center(
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 44, color: Color(0xFF98A2B3)),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _RecordStatusChip extends StatelessWidget {
  const _RecordStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = switch (normalized) {
      'COMPLETED' || 'APPROVED' => const Color(0xFF067647),
      'REJECTED' || 'FAILED' => const Color(0xFFB42318),
      _ => const Color(0xFFB54708),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _friendly(normalized),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Future<bool> _confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) => _confirmAction(
  context,
  title: title,
  message: message,
  confirmLabel: 'Delete',
  destructive: true,
);

Future<bool> _confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    )
                  : null,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];
double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
String _friendly(Object? value) {
  final text = '${value ?? '—'}'.replaceAll('_', ' ').toLowerCase();
  return text.isEmpty ? '—' : text[0].toUpperCase() + text.substring(1);
}

String _date(Object? value, DateFormat formatter, {bool dateOnly = false}) {
  final parsed = DateTime.tryParse('${value ?? ''}');
  if (parsed == null) return '—';
  return dateOnly
      ? DateFormat('dd MMM yyyy').format(parsed.toLocal())
      : formatter.format(parsed.toLocal());
}

String _nested(
  Map<String, dynamic> item,
  String parent,
  String child, {
  String fallback = '—',
}) {
  final value = item[parent];
  return value is Map ? '${value[child] ?? fallback}' : fallback;
}

String _nestedDeep(
  Map<String, dynamic> item,
  String first,
  String second,
  String third,
) {
  final parent = item[first];
  if (parent is! Map) return '—';
  final child = parent[second];
  return child is Map ? '${child[third] ?? '—'}' : '—';
}
