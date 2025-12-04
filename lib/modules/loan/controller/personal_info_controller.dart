import 'package:get/get.dart';
import 'package:loan_app/modules/loan/model/personal_information.dart';

class PersonalInfoController extends GetxController {
  var actualName = ''.obs;
  var idCardNo = ''.obs;
  var currentJob = ''.obs;
  var gender = ''.obs;
  var stableIncome = 0.0.obs;
  var loanPurpose = ''.obs;
  var currentAddress = ''.obs;
  var guarantorName = ''.obs;
  var guarantorPhone = ''.obs;

  bool isValid() {
    return actualName.isNotEmpty &&
        idCardNo.isNotEmpty &&
        currentJob.isNotEmpty &&
        gender.isNotEmpty &&
        stableIncome.value > 0 &&
        loanPurpose.isNotEmpty &&
        currentAddress.isNotEmpty &&
        guarantorName.isNotEmpty &&
        guarantorPhone.isNotEmpty;
  }

  PersonalInfoModel buildModel() {
    return PersonalInfoModel(
      actualName: actualName.value,
      idCardNo: idCardNo.value,
      currentJob: currentJob.value,
      gender: gender.value,
      stableIncome: stableIncome.value,
      loanPurpose: loanPurpose.value,
      currentAddress: currentAddress.value,
      guarantorName: guarantorName.value,
      guarantorPhone: guarantorPhone.value,
    );
  }
}
