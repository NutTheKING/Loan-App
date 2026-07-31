import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';

void main() {
  test('final loan validation matches API field limits', () async {
    await dotenv.load(fileName: '.env');
    final controller = LoanController()
      ..actualName.value = 'Test Borrower'
      ..idCardNo.value = 'TEST-1234'
      ..currentJob.value = 'Engineer'
      ..gender.value = 'Other'
      ..stableIncome.value = 100000
      ..loanPurpose.value = 'Home improvement'
      ..currentAddress.value = '123 Test Avenue'
      ..guarantorName.value = 'Test Guarantor'
      ..guarantorPhone.value = '323'
      ..beneficiaryBank.value = 'Test Bank'
      ..accountName.value = 'Test Borrower'
      ..accountNumber.value = '1234567890';

    expect(controller.isPersonalInfoValid(), isFalse);

    controller.guarantorPhone.value = '09171234567';

    expect(controller.isPersonalInfoValid(), isTrue);
    expect(controller.isValid, isTrue);

    controller.signatureController.dispose();
  });
}
