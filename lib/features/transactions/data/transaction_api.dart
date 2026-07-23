import 'package:loan_app/core/network/api_client.dart';

class TransactionApi {
  TransactionApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<double> create({
    required String type,
    required double amount,
    required String description,
  }) async {
    final response = await _client.post(
      '/transactions',
      data: {'type': type, 'amount': amount, 'description': description},
    );
    final balance = response['availableBalance'];
    return balance is num
        ? balance.toDouble()
        : double.tryParse('$balance') ?? 0;
  }
}
