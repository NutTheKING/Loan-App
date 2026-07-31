import 'package:loan_app/core/network/api_client.dart';

class TransactionApi {
  TransactionApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<TransactionSubmission> create({
    required String type,
    required double amount,
    required String description,
  }) async {
    final response = await _client.post(
      '/transactions',
      data: {'type': type, 'amount': amount, 'description': description},
    );
    return TransactionSubmission.fromJson(response);
  }
}

class TransactionSubmission {
  const TransactionSubmission({
    required this.id,
    required this.status,
    required this.availableBalance,
    required this.message,
  });

  final String id;
  final String status;
  final double availableBalance;
  final String message;

  factory TransactionSubmission.fromJson(Map<String, dynamic> json) {
    final transaction = json['transaction'] is Map
        ? Map<String, dynamic>.from(json['transaction'] as Map)
        : const <String, dynamic>{};
    final balance = json['availableBalance'];
    return TransactionSubmission(
      id: transaction['id'] as String? ?? '',
      status: transaction['status'] as String? ?? 'PENDING',
      availableBalance: balance is num
          ? balance.toDouble()
          : double.tryParse('$balance') ?? 0,
      message:
          json['message'] as String? ??
          'Your request is pending back-office review.',
    );
  }
}
