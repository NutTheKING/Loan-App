import 'dart:typed_data';

import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/features/admin/model/admin_loan.dart';

class AdminApi {
  AdminApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<AdminLoan>> listLoans() async {
    final response = await _client.get('/admin/loans');
    final loans = response['loans'];
    if (loans is! List) {
      return const [];
    }
    return loans
        .whereType<Map>()
        .map((loan) => AdminLoan.fromJson(Map<String, dynamic>.from(loan)))
        .toList();
  }

  Future<void> reviewLoan({
    required String loanId,
    required String status,
    String? reviewerNote,
  }) async {
    await _client.patch(
      '/admin/loans/$loanId/status',
      data: {
        'status': status,
        if (reviewerNote != null && reviewerNote.trim().isNotEmpty)
          'reviewerNote': reviewerNote.trim(),
      },
    );
  }

  Future<AdminLoan> loanDetail(String loanId) async {
    final response = await _client.get('/admin/loans/$loanId');
    return AdminLoan.fromJson(
      Map<String, dynamic>.from(response['loan'] as Map),
    );
  }

  Future<void> requestLoanInformation({
    required String loanId,
    required String reason,
  }) async {
    await _client.post(
      '/admin/loans/$loanId/request-information',
      data: {'reason': reason},
    );
  }

  Future<Uint8List> loanDocument({
    required String loanId,
    required String documentId,
  }) => _client.getBytes('/loans/$loanId/documents/$documentId');

  Future<Map<String, dynamic>> overview() => _client.get('/admin/overview');

  Future<List<AdminCustomer>> customers() async {
    final response = await _client.get('/admin/customers');
    return _typedList(response['customers'], AdminCustomer.fromJson);
  }

  Future<void> saveCustomer(AdminCustomer customer) async {
    if (customer.id.isEmpty) {
      await _client.post('/admin/customers', data: customer.toJson());
      return;
    }
    await _client.patch(
      '/admin/customers/${customer.id}',
      data: customer.toJson(),
    );
  }

  Future<AdminCustomer> customerDetail(String customerId) async {
    final response = await _client.get('/admin/customers/$customerId');
    return AdminCustomer.fromJson(
      Map<String, dynamic>.from(response['customer'] as Map),
    );
  }

  Future<void> deleteCustomer(String customerId) =>
      _client.delete('/admin/customers/$customerId');

  Future<List<Map<String, dynamic>>> repayments() =>
      _list('/admin/repayments', 'repayments');

  Future<List<AdminTransaction>> transactions() async {
    final response = await _client.get('/admin/transactions');
    return _typedList(response['transactions'], AdminTransaction.fromJson);
  }

  Future<void> createDeposit({
    required String customerId,
    required double amount,
    required String description,
  }) async {
    await _client.post(
      '/admin/transactions',
      data: {
        'userId': customerId,
        'amount': amount,
        'description': description,
      },
    );
  }

  Future<void> reviewTransaction({
    required String transactionId,
    required String status,
    String? reason,
  }) async {
    await _client.patch(
      '/admin/transactions/$transactionId/status',
      data: {
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<void> deleteTransaction(String transactionId) =>
      _client.delete('/admin/transactions/$transactionId');

  Future<Map<String, dynamic>> report() =>
      _client.get('/admin/reports/summary');

  Future<List<AdminLoanProduct>> loanProducts() async {
    final response = await _client.get('/admin/loan-products');
    return _typedList(response['products'], AdminLoanProduct.fromJson);
  }

  Future<void> saveLoanProduct(AdminLoanProduct product) async {
    if (product.id.isEmpty) {
      await _client.post('/admin/loan-products', data: product.toJson());
      return;
    }
    await _client.patch(
      '/admin/loan-products/${product.id}',
      data: product.toJson(),
    );
  }

  Future<void> deleteLoanProduct(String productId) =>
      _client.delete('/admin/loan-products/$productId');

  Future<List<AdminBranch>> branches() async {
    final response = await _client.get('/admin/branches');
    return _typedList(response['branches'], AdminBranch.fromJson);
  }

  Future<void> saveBranch(AdminBranch branch) async {
    if (branch.id.isEmpty) {
      await _client.post('/admin/branches', data: branch.toJson());
      return;
    }
    await _client.patch('/admin/branches/${branch.id}', data: branch.toJson());
  }

  Future<void> deleteBranch(String branchId) =>
      _client.delete('/admin/branches/$branchId');

  Future<List<AdminPermission>> permissions() async {
    final response = await _client.get('/admin/permissions');
    return _typedList(response['permissions'], AdminPermission.fromJson);
  }

  Future<List<AdminUser>> users() async {
    final response = await _client.get('/admin/users');
    return _typedList(response['users'], AdminUser.fromJson);
  }

  Future<void> saveUser(
    AdminUser user, {
    bool includePermissions = true,
  }) async {
    if (user.id.isEmpty) {
      await _client.post(
        '/admin/users',
        data: user.toJson(includePermissions: includePermissions),
      );
      return;
    }
    await _client.patch(
      '/admin/users/${user.id}',
      data: user.toJson(includePermissions: includePermissions),
    );
  }

  Future<void> deleteUser(String userId) =>
      _client.delete('/admin/users/$userId');

  Future<List<Map<String, dynamic>>> _list(String path, String key) async {
    final response = await _client.get(path);
    final values = response[key];
    if (values is! List) {
      return const [];
    }
    return values
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  List<T> _typedList<T>(
    Object? values,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (values is! List) {
      return const [];
    }
    return values
        .whereType<Map>()
        .map((value) => fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }
}
