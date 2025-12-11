import 'package:get/get.dart';
import 'package:loan_app/modules/go_save_account/model/open_go_save_account.dart';

class GoSaveController extends GetxController {
  var initialDeposit = 0.0.obs;
  var selectedPlan = "Standard".obs;
  var periodMonths = 6.obs;

  // Example: plan-interest mapping
  final Map<String, double> planInterest = {"Standard": 3.0, "Premium": 5.0, "VIP": 7.0};

  void changeDeposit(String value) {
    initialDeposit.value = double.tryParse(value) ?? 0.0;
  }

  void changePlan(String plan) {
    selectedPlan.value = plan;
  }

  void changePeriod(int months) {
    periodMonths.value = months;
  }

  double get estimatedInterest =>
      initialDeposit.value * (planInterest[selectedPlan.value]! / 100) * (periodMonths.value / 12);

  GoSaveAccount buildAccount() {
    return GoSaveAccount(
      initialDeposit: initialDeposit.value,
      plan: selectedPlan.value,
      interestRate: planInterest[selectedPlan.value]!,
      periodMonths: periodMonths.value,
    );
  }
}
