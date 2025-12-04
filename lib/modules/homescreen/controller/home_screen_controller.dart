import 'package:get/get.dart';
import 'package:loan_app/modules/loan/model/loan_model.dart';

class HomeController extends GetxController {
  var balance = 6.0.obs;
  var recentTransactions = <Map<String, dynamic>>[].obs;
  var loans = <LoanModel>[].obs;
  final cardPadding = 0.045;
  final iconSize = 0.075;
  final circleSize = 0.22;

  @override
  void onInit() {
    super.onInit();
    // Demo transactions
    recentTransactions.addAll([
      {'title': 'Go Rewards points earned', 'amount': 49.10, 'credit': true},
      {'title': 'ROBINSONS SUPT IMUS', 'amount': -245.50, 'credit': false},
      {'title': 'Robinsons Supermarket', 'amount': 500.00, 'credit': true},
    ]);
  }

  void addLoan(LoanModel loan) {
    loans.add(loan);
  }
}
