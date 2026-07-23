import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/transactions/data/transaction_api.dart';
import 'package:loan_app/modules/homescreen/controller/home_screen_controller.dart';

class DepositController extends GetxController {
  final TransactionApi _transactionApi = TransactionApi();

  final amount = 0.0.obs;
  final selectedMethod = 'Bank Transfer'.obs;
  final isSubmitting = false.obs;
  final methods = const [
    'Bank Transfer',
    'Visa / Mastercard',
    'QR Payment',
    'Cash Deposit',
  ];

  bool get isValid => amount.value > 0 && !isSubmitting.value;

  Future<bool> submit() async {
    if (!isValid) return false;
    isSubmitting.value = true;
    try {
      await _transactionApi.create(
        type: 'DEPOSIT',
        amount: amount.value,
        description: 'Deposit via ${selectedMethod.value}',
      );
      amount.value = 0;
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadDashboard();
      }
      Get.snackbar(
        'Deposit completed',
        'Your account balance has been updated.',
        backgroundColor: const Color(0xFF12B76A),
        colorText: Colors.white,
      );
      return true;
    } on ApiException catch (error) {
      Get.snackbar('Deposit failed', error.message);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
