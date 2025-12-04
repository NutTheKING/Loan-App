import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loan_app/modules/loan/model/loan_model.dart';
import 'package:loan_app/modules/loan/model/loand_models.dart';
import 'package:uuid/uuid.dart';

class LoanController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var amount = 70000.0.obs; // must be >= minAmount
  var loanStatus = LoanStatus.pending.obs;
  var selfiePath = ''.obs;
  var idFrontPath = ''.obs;
  var idBackPath = ''.obs;

  Future<void> pickFromCamera(String target) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file == null) return;
    if (target == 'selfie') selfiePath.value = file.path;
    if (target == 'id_front') idFrontPath.value = file.path;
    if (target == 'id_back') idBackPath.value = file.path;
  }

  Future<void> pickFromGallery(String target) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    if (target == 'selfie') selfiePath.value = file.path;
    if (target == 'id_front') idFrontPath.value = file.path;
    if (target == 'id_back') idBackPath.value = file.path;
  }

  Future<LoanModel> submitLoan() async {
    // Do validation
    final id = const Uuid().v4();
    final loan = LoanModel(
      id: id,
      amount: amount.value,
      createdAt: DateTime.now(),
      status: LoanStatus.pending,
      documentSelfie: selfiePath.value,
      idFront: idFrontPath.value,
      idBack: idBackPath.value,
    );
    // TODO: send to backend
    return loan;
  }

  final minAmount = 70000.0;
  final maxAmount = 1500000.0;

  // RxDouble amount = 70000.0.obs;
  RxInt selectedPeriod = 4.obs;

  final monthlyInterestRate = 0.005; // 0.5%

  RxBool agreeTerms = false.obs;

  // Calculated fields

  RxDouble principal = 0.0.obs;
  RxDouble interestAmount = 0.0.obs;
  RxDouble paymentAmount = 0.0.obs;
  Rx<DateTime> disbursementDate = DateTime.now().obs;

  void changeAmount(double value) {
    if (value < minAmount) {
      amount.value = minAmount;
    } else if (value > maxAmount) {
      amount.value = maxAmount;
    } else {
      amount.value = value;
    }

    calculateLoan();
  }

  void setPeriod(int months) {
    selectedPeriod.value = months;
    calculateLoan();
  }

  void calculateLoan() {
    final amt = amount.value;
    final months = selectedPeriod.value;

    // principal is the raw loan amount
    principal.value = amt;

    // interest = principal × rate × months
    interestAmount.value = amt * monthlyInterestRate * months;

    // total payment
    paymentAmount.value = principal.value + interestAmount.value;

    // disbursement date = today
    disbursementDate.value = DateTime.now();
  }

  LoanModels buildLoanModel() {
    return LoanModels(
      amount: amount.value,
      period: selectedPeriod.value,
      monthlyInterestRate: monthlyInterestRate,
      principal: principal.value,
      interestAmount: interestAmount.value,
      paymentAmount: paymentAmount.value,
      disbursementDate: disbursementDate.value,
    );
  }
}
