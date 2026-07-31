import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/core/auth/auth_session.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/admin/data/admin_api.dart';
import 'package:loan_app/features/admin/model/admin_loan.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';
import 'package:loan_app/routers/app_router.dart';
import 'package:loan_app/modules/notification/controller/notification_controller.dart';

enum AdminSection {
  dashboard,
  applications,
  packages,
  customers,
  repayments,
  transactions,
  deposits,
  withdrawals,
  reports,
  branches,
  users,
  profile,
}

class AdminDashboardController extends GetxController {
  final AdminApi _adminApi = AdminApi();
  final AuthApi _authApi = AuthApi();
  final notifications = Get.put(NotificationController(), permanent: true);

  final loans = <AdminLoan>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;
  final statusFilter = 'ALL'.obs;
  final transactionStatusFilter = 'ALL'.obs;
  final selectedSection = AdminSection.dashboard.obs;
  final sidebarCollapsed = false.obs;
  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();
  final overview = <String, dynamic>{}.obs;
  final customers = <AdminCustomer>[].obs;
  final repayments = <Map<String, dynamic>>[].obs;
  final transactions = <AdminTransaction>[].obs;
  final report = <String, dynamic>{}.obs;
  final products = <AdminLoanProduct>[].obs;
  final branches = <AdminBranch>[].obs;
  final users = <AdminUser>[].obs;
  final permissions = <AdminPermission>[].obs;

  bool can(String permission) =>
      currentUser.value?.hasPermission(permission) == true;

  List<AdminSection> get availableSections => AdminSection.values
      .where(
        (section) =>
            section == AdminSection.profile || can(_permissionFor(section)),
      )
      .toList();

  List<AdminLoan> get filteredLoans {
    if (statusFilter.value == 'ALL') {
      return loans;
    }
    return loans.where((loan) => loan.status == statusFilter.value).toList();
  }

  List<AdminTransaction> get filteredTransactions {
    if (transactionStatusFilter.value == 'ALL') {
      return transactions;
    }
    return transactions
        .where((item) => item.status == transactionStatusFilter.value)
        .toList();
  }

  int transactionCountFor(String status) =>
      transactions.where((item) => item.status == status).length;

  int get pendingWithdrawalCount {
    final value = overview['pendingWithdrawals'];
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  int countFor(String status) =>
      loans.where((loan) => loan.status == status).length;

  double get approvedPrincipal => loans
      .where((loan) => loan.status == 'APPROVED')
      .fold(0, (total, loan) => total + loan.principal);

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = '';
    final user = await _authApi.currentUser();
    if (user == null) {
      appRouter.go('/login');
      return;
    }
    if (!user.canAccessAdmin) {
      appRouter.go('/home');
      return;
    }
    currentUser.value = user;
    if (!availableSections.contains(selectedSection.value)) {
      selectedSection.value =
          availableSections.firstOrNull ?? AdminSection.profile;
    }
    await loadOverview();
  }

  Future<void> selectSection(AdminSection section) async {
    if (!availableSections.contains(section)) {
      return;
    }
    if (selectedSection.value != section) {
      transactionStatusFilter.value = 'ALL';
    }
    selectedSection.value = section;
    await switch (section) {
      AdminSection.dashboard => loadOverview(),
      AdminSection.applications => loadLoans(),
      AdminSection.packages => loadProducts(),
      AdminSection.customers => loadCustomers(),
      AdminSection.repayments => loadRepayments(),
      AdminSection.transactions => loadTransactions(),
      AdminSection.deposits => loadTransactions(type: 'DEPOSIT'),
      AdminSection.withdrawals => loadTransactions(type: 'WITHDRAWAL'),
      AdminSection.reports => loadReport(),
      AdminSection.branches => loadBranches(),
      AdminSection.users => loadUsers(),
      AdminSection.profile => Future<void>.value(),
    };
  }

  Future<void> refreshCurrentSection() => selectSection(selectedSection.value);

  Future<void> loadOverview() => _load(() async {
    overview.assignAll(await _adminApi.overview());
  });

  Future<void> loadCustomers() => _load(() async {
    customers.assignAll(await _adminApi.customers());
  });

  Future<void> loadRepayments() => _load(() async {
    repayments.assignAll(await _adminApi.repayments());
  });

  Future<void> loadTransactions({String? type}) => _load(() async {
    final values = await Future.wait<Object>([
      _adminApi.transactions(type: type),
      if (can('customers.read')) _adminApi.customers(),
    ]);
    transactions.assignAll(values.first as List<AdminTransaction>);
    if (values.length > 1) {
      customers.assignAll(values[1] as List<AdminCustomer>);
    }
  });

  void setTransactionStatusFilter(String status) {
    transactionStatusFilter.value = status;
  }

  Future<void> loadReport() => _load(() async {
    report.assignAll(await _adminApi.report());
  });

  Future<void> loadProducts() => _load(() async {
    products.assignAll(await _adminApi.loanProducts());
  });

  Future<void> loadBranches() => _load(() async {
    branches.assignAll(await _adminApi.branches());
  });

  Future<void> loadUsers() => _load(() async {
    final values = await Future.wait([
      _adminApi.users(),
      _adminApi.permissions(),
    ]);
    users.assignAll(values[0] as List<AdminUser>);
    permissions.assignAll(values[1] as List<AdminPermission>);
  });

  Future<bool> saveProduct(AdminLoanProduct product) => _save(
    () => _adminApi.saveLoanProduct(product),
    loadProducts,
    successMessage: product.id.isEmpty
        ? 'Loan package created.'
        : 'Loan package updated.',
  );

  Future<bool> saveBranch(AdminBranch branch) => _save(
    () => _adminApi.saveBranch(branch),
    loadBranches,
    successMessage: branch.id.isEmpty ? 'Branch created.' : 'Branch updated.',
  );

  Future<bool> saveCustomer(AdminCustomer customer) => _save(
    () => _adminApi.saveCustomer(customer),
    loadCustomers,
    successMessage: customer.id.isEmpty
        ? 'Customer registered.'
        : 'Customer updated.',
  );

  Future<bool> saveUser(AdminUser user) => _save(
    () =>
        _adminApi.saveUser(user, includePermissions: can('permissions.manage')),
    loadUsers,
    successMessage: user.id.isEmpty
        ? 'Back-office user created.'
        : 'Back-office user updated.',
  );

  void toggleSidebar() => sidebarCollapsed.toggle();

  Future<AdminLoan?> loadLoanDetail(String loanId) async {
    try {
      return await _adminApi.loanDetail(loanId);
    } on ApiException catch (error) {
      _showError('Unable to load application', error.message);
      return null;
    }
  }

  Future<Uint8List?> loadLoanDocument({
    required String loanId,
    required String documentId,
  }) async {
    try {
      return Uint8List.fromList(
        await _adminApi.loanDocument(loanId: loanId, documentId: documentId),
      );
    } on ApiException catch (error) {
      _showError('Unable to load document', error.message);
      return null;
    }
  }

  Future<bool> requestLoanInformation({
    required AdminLoan loan,
    required String reason,
  }) => _save(
    () => _adminApi.requestLoanInformation(loanId: loan.id, reason: reason),
    loadLoans,
    successMessage: 'Information request sent to ${loan.borrower.fullName}.',
  );

  Future<bool> createDeposit({
    required String customerId,
    required double amount,
    required String description,
  }) => _save(
    () => _adminApi.createDeposit(
      customerId: customerId,
      amount: amount,
      description: description,
    ),
    _refreshCashData,
    successMessage: 'Customer deposit completed.',
  );

  Future<bool> reviewTransaction({
    required AdminTransaction transaction,
    required String status,
    String? reason,
  }) => _save(
    () => _adminApi.reviewTransaction(
      transactionId: transaction.id,
      status: status,
      reason: reason,
    ),
    _refreshCashData,
    successMessage: status == 'COMPLETED'
        ? 'Transaction approved and completed.'
        : 'Transaction rejected and customer notified.',
  );

  Future<bool> deleteTransaction(AdminTransaction transaction) => _save(
    () => _adminApi.deleteTransaction(transaction.id),
    _refreshCashData,
    successMessage: 'Transaction request deleted.',
  );

  Future<AdminTransaction?> loadTransactionDetail(String transactionId) async {
    try {
      return await _adminApi.transactionDetail(transactionId);
    } on ApiException catch (error) {
      _showError('Unable to load request', error.message);
      return null;
    }
  }

  Future<void> _refreshCashData() async {
    await refreshCurrentSection();
    if (selectedSection.value != AdminSection.dashboard &&
        can('dashboard.view')) {
      try {
        overview.assignAll(await _adminApi.overview());
      } on ApiException {
        return;
      }
    }
  }

  Future<bool> deleteCustomer(AdminCustomer customer) => _save(
    () => _adminApi.deleteCustomer(customer.id),
    loadCustomers,
    successMessage: 'Customer account deleted.',
  );

  Future<bool> deleteProduct(AdminLoanProduct product) => _save(
    () => _adminApi.deleteLoanProduct(product.id),
    loadProducts,
    successMessage: 'Loan package deleted.',
  );

  Future<bool> deleteBranch(AdminBranch branch) => _save(
    () => _adminApi.deleteBranch(branch.id),
    loadBranches,
    successMessage: 'Branch deleted.',
  );

  Future<bool> deleteUser(AdminUser user) => _save(
    () => _adminApi.deleteUser(user.id),
    loadUsers,
    successMessage: 'Back-office user deleted.',
  );

  Future<void> _load(Future<void> Function() operation) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await operation();
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      if (error.statusCode == 401) {
        await _authApi.signOut();
        appRouter.go('/login');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _save(
    Future<void> Function() operation,
    Future<void> Function() reload, {
    required String successMessage,
  }) async {
    if (isSubmitting.value) {
      return false;
    }
    isSubmitting.value = true;
    try {
      await operation();
      await reload();
      Get.snackbar(
        'Changes saved',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF157347),
        colorText: Colors.white,
      );
      return true;
    } on ApiException catch (error) {
      Get.snackbar(
        'Unable to save',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFB42318),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFB42318),
      colorText: Colors.white,
    );
  }

  Future<void> loadLoans() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      loans.assignAll(await _adminApi.listLoans());
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      if (error.statusCode == 401) {
        await _authApi.signOut();
        appRouter.go('/login');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectStatus(String status) {
    statusFilter.value = status;
  }

  Future<bool> reviewLoan({
    required AdminLoan loan,
    required String status,
    String? reviewerNote,
  }) async {
    if (!loan.isPending || isSubmitting.value) {
      return false;
    }
    isSubmitting.value = true;
    try {
      await _adminApi.reviewLoan(
        loanId: loan.id,
        status: status,
        reviewerNote: reviewerNote,
      );
      await loadLoans();
      Get.snackbar(
        'Application updated',
        status == 'APPROVED'
            ? '${loan.loanNumber} was approved.'
            : '${loan.loanNumber} was rejected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: status == 'APPROVED'
            ? const Color(0xFF157347)
            : const Color(0xFFB42318),
        colorText: Colors.white,
      );
      return true;
    } on ApiException catch (error) {
      Get.snackbar(
        'Unable to update application',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFB42318),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> signOut() async {
    await _authApi.signOut();
    appRouter.go('/login');
  }

  String _permissionFor(AdminSection section) => switch (section) {
    AdminSection.dashboard => 'dashboard.view',
    AdminSection.applications => 'loans.read',
    AdminSection.packages => 'products.read',
    AdminSection.customers => 'customers.read',
    AdminSection.repayments => 'repayments.read',
    AdminSection.transactions => 'transactions.read',
    AdminSection.deposits => 'transactions.read',
    AdminSection.withdrawals => 'transactions.read',
    AdminSection.reports => 'reports.read',
    AdminSection.branches => 'branches.read',
    AdminSection.users => 'users.manage',
    AdminSection.profile => '',
  };
}
