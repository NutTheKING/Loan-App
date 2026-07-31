import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/loans/data/loan_api.dart';
import 'package:loan_app/modules/loan/loan_routes.dart';
import 'package:signature/signature.dart';

class LoanController extends GetxController {
  static LoanController ensure() => Get.isRegistered<LoanController>()
      ? Get.find<LoanController>()
      : Get.put(LoanController());

  final ImagePicker _picker = ImagePicker();
  final LoanApi _loanApi = LoanApi();
  final Map<String, XFile> _documents = {};
  String? _submittedLoanId;

  final amount = 70000.0.obs;
  final selectedPeriod = 4.obs;
  final agreeTerms = false.obs;
  final principal = 0.0.obs;
  final interestAmount = 0.0.obs;
  final paymentAmount = 0.0.obs;
  final monthlyPayment = 0.0.obs;
  final disbursementDate = DateTime.now().obs;
  final applicationSubmitting = false.obs;
  final applicationProgress = ''.obs;
  final configurationLoading = false.obs;
  final hasActiveLoan = false.obs;
  final loanBlockReason = ''.obs;
  final loanBlockMessage = ''.obs;
  final submissionError = ''.obs;
  final submissionCorrectionRoute = ''.obs;
  final productId = ''.obs;
  final productName = 'Standard Loan'.obs;
  final minimumAmount = 70000.0.obs;
  final maximumAmount = 1500000.0.obs;
  final configuredInterestRate = .005.obs;
  final allowedTerms = <int>[4, 12, 24, 36].obs;

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

  double get minAmount => minimumAmount.value;
  double get maxAmount => maximumAmount.value;
  double get monthlyInterestRate => configuredInterestRate.value;

  @override
  void onInit() {
    super.onInit();
    signatureController.addListener(_syncSignatureState);
    calculateLoan();
    loadConfiguration();
  }

  void _syncSignatureState() {
    signed.value = signatureController.isNotEmpty;
  }

  Future<void> loadConfiguration() async {
    configurationLoading.value = true;
    try {
      final values = await Future.wait([
        _loanApi.currentProduct(),
        _loanApi.applicationAvailability(),
      ]);
      final product = values[0] as Map<String, dynamic>;
      final availability = values[1] as LoanApplicationAvailability;
      productId.value = product['id'] as String? ?? '';
      productName.value = product['name'] as String? ?? 'Loan package';
      minimumAmount.value = _number(product['minimumAmount'], 70000);
      maximumAmount.value = _number(product['maximumAmount'], 1500000);
      configuredInterestRate.value = _number(
        product['monthlyInterestRate'],
        .005,
      );
      allowedTerms.assignAll(
        (product['allowedTerms'] as List? ?? const [4, 12, 24, 36])
            .whereType<num>()
            .map((term) => term.toInt()),
      );
      hasActiveLoan.value = !availability.canApply;
      loanBlockReason.value = availability.reason ?? '';
      loanBlockMessage.value =
          availability.message ??
          'You cannot apply for another loan at this time.';
      amount.value = amount.value.clamp(minAmount, maxAmount).toDouble();
      if (!allowedTerms.contains(selectedPeriod.value) &&
          allowedTerms.isNotEmpty) {
        selectedPeriod.value = allowedTerms.first;
      }
      calculateLoan();
    } on ApiException catch (error) {
      Get.snackbar('Loan package unavailable', error.message);
    } finally {
      configurationLoading.value = false;
    }
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
    principal.value = amount.value;
    interestAmount.value =
        amount.value * monthlyInterestRate * selectedPeriod.value;
    paymentAmount.value = amount.value + interestAmount.value;
    monthlyPayment.value = paymentAmount.value / selectedPeriod.value;
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
      beneficiaryBank.value.trim().length >= 2 &&
      accountName.value.trim().length >= 2 &&
      accountNumber.value.trim().length >= 4;

  Map<String, String> buildModel() {
    return {
      'beneficiaryBank': beneficiaryBank.value,
      'accountName': accountName.value,
      'accountNumber': accountNumber.value,
    };
  }

  bool isPersonalInfoValid() {
    return actualName.value.trim().length >= 2 &&
        idCardNo.value.trim().length >= 4 &&
        currentJob.value.trim().length >= 2 &&
        gender.value.trim().isNotEmpty &&
        stableIncome.value > 0 &&
        loanPurpose.value.trim().length >= 2 &&
        currentAddress.value.trim().length >= 5 &&
        guarantorName.value.trim().length >= 2 &&
        guarantorPhone.value.trim().length >= 7;
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
    submissionError.value = '';
    submissionCorrectionRoute.value = '';
    final missingStep = _missingStep();
    if (missingStep != null) {
      submissionError.value = missingStep;
      submissionCorrectionRoute.value = _correctionRoute();
      return false;
    }

    final signature = await exportSignature();
    if (signature == null || signature.isEmpty) {
      submissionError.value = 'Please add your signature before submitting.';
      return false;
    }

    applicationSubmitting.value = true;
    applicationProgress.value = 'Creating secure application…';
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
            if (productId.value.isNotEmpty) 'productId': productId.value,
          });
      _submittedLoanId = loanId;

      applicationProgress.value = 'Uploading ID front…';
      await _loanApi.uploadImage(
        loanId: loanId,
        kind: 'ID_FRONT',
        file: _documents['ID_FRONT']!,
      );
      applicationProgress.value = 'Uploading ID back…';
      await _loanApi.uploadImage(
        loanId: loanId,
        kind: 'ID_BACK',
        file: _documents['ID_BACK']!,
      );
      applicationProgress.value = 'Uploading selfie…';
      await _loanApi.uploadImage(
        loanId: loanId,
        kind: 'SELFIE',
        file: _documents['SELFIE']!,
      );
      applicationProgress.value = 'Uploading signature…';
      await _loanApi.uploadSignature(loanId: loanId, bytes: signature);
      applicationProgress.value = 'Finalizing application…';
      await _loanApi.completeApplication(loanId);
      _submittedLoanId = null;
      hasActiveLoan.value = true;
      loanBlockReason.value = 'PENDING_REVIEW';
      loanBlockMessage.value =
          'Your loan application is pending review. Wait for a decision before applying again.';
      return true;
    } on ApiException catch (error) {
      submissionError.value = error.message;
      return false;
    } catch (_) {
      submissionError.value = 'Please check your connection and try again.';
      return false;
    } finally {
      applicationSubmitting.value = false;
      applicationProgress.value = '';
    }
  }

  static double _number(Object? value, double fallback) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

  String? _missingStep() {
    if (hasActiveLoan.value) {
      return loanBlockMessage.value;
    }
    if (applicationSubmitting.value) {
      return 'Your application is already being submitted.';
    }
    if (!agreeTerms.value) {
      return 'Accept the loan terms on the amount step.';
    }
    if (!allUploaded()) {
      return 'Upload the front and back of your ID and a selfie.';
    }
    final personalInformationError = _personalInformationError();
    if (personalInformationError != null) {
      return personalInformationError;
    }
    if (!isValid) {
      return 'Enter a valid payout provider, account holder, and account number with at least 4 characters.';
    }
    if (!signatureController.isNotEmpty) {
      return 'Add your signature before submitting.';
    }
    return null;
  }

  String? _personalInformationError() {
    if (actualName.value.trim().length < 2) {
      return 'Enter your full legal name.';
    }
    if (idCardNo.value.trim().length < 4) {
      return 'Enter an ID card number with at least 4 characters.';
    }
    if (currentJob.value.trim().length < 2) {
      return 'Enter your current job.';
    }
    if (gender.value.trim().isEmpty) {
      return 'Select your gender.';
    }
    if (stableIncome.value <= 0) {
      return 'Enter a stable monthly income greater than zero.';
    }
    if (loanPurpose.value.trim().length < 2) {
      return 'Enter the purpose of this loan.';
    }
    if (currentAddress.value.trim().length < 5) {
      return 'Enter a current address with at least 5 characters.';
    }
    if (guarantorName.value.trim().length < 2) {
      return 'Enter the guarantor full name.';
    }
    if (guarantorPhone.value.trim().length < 7) {
      return 'Enter a guarantor phone number with at least 7 characters.';
    }
    return null;
  }

  String _correctionRoute() {
    if (!agreeTerms.value) {
      return LoanRoutes.amount;
    }
    if (!allUploaded()) {
      return LoanRoutes.documents;
    }
    if (_personalInformationError() != null) {
      return LoanRoutes.personalInformation;
    }
    if (!isValid) {
      return LoanRoutes.payoutAccount;
    }
    return '';
  }

  @override
  void onClose() {
    signatureController.removeListener(_syncSignatureState);
    signatureController.dispose();
    super.onClose();
  }
}
