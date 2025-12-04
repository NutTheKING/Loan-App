import 'package:get/get.dart';
import 'package:loan_app/modules/loan/model/bank_account_model.dart';

class BankAccountController extends GetxController {
  var beneficiaryBank = ''.obs;
  var accountName = ''.obs;
  var accountNumber = ''.obs;

  bool isValid() {
    return beneficiaryBank.isNotEmpty && accountName.isNotEmpty && accountNumber.isNotEmpty;
  }

  BankAccountModel buildModel() {
    return BankAccountModel(
      beneficiaryBank: beneficiaryBank.value,
      accountName: accountName.value,
      accountNumber: accountNumber.value,
    );
  }
}
