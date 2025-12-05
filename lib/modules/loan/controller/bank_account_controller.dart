import 'package:get/get.dart';
import 'package:loan_app/modules/loan/model/bank_account_model.dart';

class BankAccountController extends GetxController {
  var beneficiaryBank = ''.obs;
  var accountName = ''.obs;
  var accountNumber = ''.obs;

  bool get isValid =>
      beneficiaryBank.value.isNotEmpty && accountName.value.isNotEmpty && accountNumber.value.isNotEmpty;

  Map<String, dynamic> buildModel() {
    return {
      "beneficiaryBank": beneficiaryBank.value,
      "accountName": accountName.value,
      "accountNumber": accountNumber.value,
    };
  }
}
