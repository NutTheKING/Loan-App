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

  Future<List<Map<String, dynamic>>> repayments() =>
      _list('/admin/repayments', 'repayments');

  Future<List<Map<String, dynamic>>> transactions() =>
      _list('/admin/transactions', 'transactions');

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
