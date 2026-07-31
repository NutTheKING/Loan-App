import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/transactions/data/transaction_api.dart';
import 'package:loan_app/modules/homescreen/controller/home_screen_controller.dart';

class WithdrawController extends GetxController {
  final TransactionApi _transactionApi = TransactionApi();
  final availableBalance = 0.0.obs;
  final withdrawAmount = 0.0.obs;
  final selectedMethod = ''.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final methods = const ['Bank Transfer', 'GCash', 'PayPal'];

  bool get isValid =>
      withdrawAmount.value > 0 &&
      withdrawAmount.value <= availableBalance.value &&
      selectedMethod.value.isNotEmpty &&
      !isSubmitting.value;

  @override
  void onInit() {
    super.onInit();
    loadBalance();
  }

  Future<void> loadBalance() async {
    isLoading.value = true;
    try {
      final dashboard = await ApiClient.instance.get('/dashboard');
      availableBalance.value = _number(dashboard['availableBalance']);
    } on ApiException catch (error) {
      Get.snackbar('Balance unavailable', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    withdrawAmount.value = 0;
    selectedMethod.value = '';
  }

  Future<bool> submit() async {
    if (!isValid) return false;
    isSubmitting.value = true;
    try {
      final result = await _transactionApi.create(
        type: 'WITHDRAWAL',
        amount: withdrawAmount.value,
        description: 'Withdrawal via ${selectedMethod.value}',
      );
      availableBalance.value = result.availableBalance;
      reset();
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadDashboard();
      }
      Get.snackbar(
        'Withdrawal pending review',
        result.message,
        backgroundColor: const Color(0xFFF79009),
        colorText: Colors.white,
      );
      return true;
    } on ApiException catch (error) {
      Get.snackbar('Withdrawal failed', error.message);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  static double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
