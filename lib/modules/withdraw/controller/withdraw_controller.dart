import 'package:get/get.dart';

class WithdrawController extends GetxController {
  var availableBalance = 5000.0.obs; // Example balance
  var withdrawAmount = 0.0.obs;
  var selectedMethod = ''.obs;

  var methods = ["Bank Transfer", "GCash", "PayPal"];

  bool isValid() {
    return withdrawAmount.value > 0 && withdrawAmount.value <= availableBalance.value && selectedMethod.isNotEmpty;
  }

  void reset() {
    withdrawAmount.value = 0;
    selectedMethod.value = '';
  }

  void submit() {
    if (isValid()) {
      // handle withdraw API call here
      print("Withdraw ${withdrawAmount.value} via ${selectedMethod.value}");
      availableBalance.value -= withdrawAmount.value;
      reset();
    }
  }
}
