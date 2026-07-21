import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loan_app/core/loan/loan_policy.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/loans/data/loan_api.dart';
import 'package:signature/signature.dart';

class LoanController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final LoanApi _loanApi = LoanApi();
  final Map<String, XFile> _documents = {};
  String? _submittedLoanId;

  final amount = LoanPolicy.minimumAmount.obs;
  final selectedPeriod = 4.obs;
  final agreeTerms = false.obs;
  final principal = 0.0.obs;
  final interestAmount = 0.0.obs;
  final paymentAmount = 0.0.obs;
  final monthlyPayment = 0.0.obs;
  final disbursementDate = DateTime.now().obs;
  final applicationSubmitting = false.obs;

  final frontId = ''.obs;
  final backId = ''.obs;
  final selfie = ''.obs;

  final beneficiaryBank = ''.obs;
  final accountName = ''.obs;
  final accountNumber = ''.obs;

  final actualName = ''.obs;
  final idCardNo = ''.obs;
  final currentJob = ''.obs;
  final gender = ''.obs;
  final stableIncome = 0.0.obs;
  final loanPurpose = ''.obs;
  final currentAddress = ''.obs;
  final guarantorName = ''.obs;
  final guarantorPhone = ''.obs;

  final signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color(0xFF202020),
  );
  final signed = false.obs;

  double get minAmount => LoanPolicy.minimumAmount;
  double get maxAmount => LoanPolicy.maximumAmount;
  double get monthlyInterestRate => LoanPolicy.monthlyInterestRate;

  @override
  void onInit() {
    super.onInit();
    calculateLoan();
  }

  void changeAmount(double value) {
    amount.value = value.clamp(minAmount, maxAmount).toDouble();
    calculateLoan();
  }

  void setPeriod(int months) {
    selectedPeriod.value = months;
    calculateLoan();
  }

  void calculateLoan() {
    final quote = LoanPolicy.calculate(
      amount: amount.value,
      termMonths: selectedPeriod.value,
    );
    principal.value = quote.principal;
    interestAmount.value = quote.interestAmount;
    paymentAmount.value = quote.totalRepayment;
    monthlyPayment.value = quote.monthlyPayment;
    disbursementDate.value = DateTime.now();
  }

  Future<void> pickFromCamera(String target) =>
      _pickDocument(target, ImageSource.camera);

  Future<void> pickFromGallery(String target) =>
      _pickDocument(target, ImageSource.gallery);

  Future<void> _pickDocument(String target, ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );
    if (file == null) {
      return;
    }

    _documents[target] = file;
    switch (target) {
      case 'ID_FRONT':
        frontId.value = file.name;
        break;
      case 'ID_BACK':
        backId.value = file.name;
        break;
      case 'SELFIE':
        selfie.value = file.name;
        break;
    }
  }

  bool get isValid =>
      beneficiaryBank.value.isNotEmpty &&
      accountName.value.isNotEmpty &&
      accountNumber.value.isNotEmpty;

  Map<String, String> buildModel() {
    return {
      'beneficiaryBank': beneficiaryBank.value,
      'accountName': accountName.value,
      'accountNumber': accountNumber.value,
    };
  }

  bool isPersonalInfoValid() {
    return actualName.value.isNotEmpty &&
        idCardNo.value.isNotEmpty &&
        currentJob.value.isNotEmpty &&
        gender.value.isNotEmpty &&
        stableIncome.value > 0 &&
        loanPurpose.value.isNotEmpty &&
        currentAddress.value.isNotEmpty &&
        guarantorName.value.isNotEmpty &&
        guarantorPhone.value.isNotEmpty;
  }

  void clearSignature() {
    signatureController.clear();
    signed.value = false;
  }

  Future<void> checkIfSigned() async {
    final data = await signatureController.toPngBytes();
    signed.value = data != null && data.isNotEmpty;
  }

  Future<Uint8List?> exportSignature() => signatureController.toPngBytes();

  bool allUploaded() =>
      frontId.value.isNotEmpty &&
      backId.value.isNotEmpty &&
      selfie.value.isNotEmpty;

  Future<bool> submitApplication() async {
    if (!isPersonalInfoValid() ||
        !isValid ||
        !allUploaded() ||
        !signed.value ||
        applicationSubmitting.value) {
      Get.snackbar(
        'Application incomplete',
        'Please complete every loan application step before submitting.',
      );
      return false;
    }

    final signature = await exportSignature();
    if (signature == null || signature.isEmpty) {
      Get.snackbar(
        'Signature required',
        'Please add your signature before submitting.',
      );
      return false;
    }

    applicationSubmitting.value = true;
    try {
      final loanId =
          _submittedLoanId ??
          await _loanApi.submitApplication({
            'amount': amount.value,
            'termMonths': selectedPeriod.value,
            'acceptTerms': true,
            'actualName': actualName.value,
            'idCardNumber': idCardNo.value,
            'currentJob': currentJob.value,
            'gender': gender.value,
            'stableIncome': stableIncome.value,
            'loanPurpose': loanPurpose.value,
            'currentAddress': currentAddress.value,
            'guarantorName': guarantorName.value,
            'guarantorPhone': guarantorPhone.value,
            'beneficiaryBank': beneficiaryBank.value,
            'accountName': accountName.value,
            'accountNumber': accountNumber.value,
          });
      _submittedLoanId = loanId;

      await Future.wait([
        _loanApi.uploadImage(
          loanId: loanId,
          kind: 'ID_FRONT',
          file: _documents['ID_FRONT']!,
        ),
        _loanApi.uploadImage(
          loanId: loanId,
          kind: 'ID_BACK',
          file: _documents['ID_BACK']!,
        ),
        _loanApi.uploadImage(
          loanId: loanId,
          kind: 'SELFIE',
          file: _documents['SELFIE']!,
        ),
        _loanApi.uploadSignature(loanId: loanId, bytes: signature),
      ]);
      _submittedLoanId = null;
      Get.snackbar(
        'Application submitted',
        'Your loan application is pending review.',
      );
      return true;
    } on ApiException catch (error) {
      Get.snackbar('Could not submit application', error.message);
      return false;
    } catch (_) {
      Get.snackbar(
        'Could not submit application',
        'Please check your connection and try again.',
      );
      return false;
    } finally {
      applicationSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    signatureController.dispose();
    super.onClose();
  }
}
