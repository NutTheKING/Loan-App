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
  final selectedSection = AdminSection.dashboard.obs;
  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();
  final overview = <String, dynamic>{}.obs;
  final customers = <AdminCustomer>[].obs;
  final repayments = <Map<String, dynamic>>[].obs;
  final transactions = <Map<String, dynamic>>[].obs;
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
    selectedSection.value = section;
    await switch (section) {
      AdminSection.dashboard => loadOverview(),
      AdminSection.applications => loadLoans(),
      AdminSection.packages => loadProducts(),
      AdminSection.customers => loadCustomers(),
      AdminSection.repayments => loadRepayments(),
      AdminSection.transactions => loadTransactions(),
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

  Future<void> loadTransactions() => _load(() async {
    transactions.assignAll(await _adminApi.transactions());
  });

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

  Future<bool> saveProduct(AdminLoanProduct product) =>
      _save(() => _adminApi.saveLoanProduct(product), loadProducts);

  Future<bool> saveBranch(AdminBranch branch) =>
      _save(() => _adminApi.saveBranch(branch), loadBranches);

  Future<bool> saveCustomer(AdminCustomer customer) =>
      _save(() => _adminApi.saveCustomer(customer), loadCustomers);

  Future<bool> saveUser(AdminUser user) => _save(
    () =>
        _adminApi.saveUser(user, includePermissions: can('permissions.manage')),
    loadUsers,
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
    Future<void> Function() reload,
  ) async {
    if (isSubmitting.value) {
      return false;
    }
    isSubmitting.value = true;
    try {
      await operation();
      await reload();
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
    AdminSection.reports => 'reports.read',
    AdminSection.branches => 'branches.read',
    AdminSection.users => 'users.manage',
    AdminSection.profile => '',
  };
}
