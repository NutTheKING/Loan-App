import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';

class RegisterController extends GetxController {
  RegisterController({AuthApi? authApi}) : _authApi = authApi ?? AuthApi();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final idNumberController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final currentStep = 0.obs;
  final dateOfBirth = Rxn<DateTime>();
  final gender = ''.obs;
  final acceptedTerms = false.obs;
  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;
  final isLoading = false.obs;
  final formIsValid = false.obs;
  final errorMessage = ''.obs;
  final AuthApi _authApi;

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      fullNameController,
      emailController,
      phoneController,
      idNumberController,
      addressController,
      passwordController,
      confirmPasswordController,
    ]) {
      controller.addListener(_validateForm);
    }
  }

  bool get isValid => formIsValid.value;
  bool get canContinue => isStepValid(currentStep.value);
  bool get passwordMatches =>
      passwordController.text == confirmPasswordController.text;

  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return fullNameController.text.trim().length >= 2 &&
            GetUtils.isEmail(emailController.text.trim()) &&
            isPhoneValid(phoneController.text);
      case 1:
        return idNumberController.text.trim().length >= 4 &&
            dateOfBirth.value != null &&
            isAdult(dateOfBirth.value!) &&
            gender.value.isNotEmpty &&
            addressController.text.trim().length >= 5;
      case 2:
        return passwordController.text.length >= 12 &&
            passwordMatches &&
            acceptedTerms.value;
      default:
        return false;
    }
  }

  void _validateForm() {
    formIsValid.value = List.generate(3, isStepValid).every((valid) => valid);
  }

  void setDateOfBirth(DateTime value) {
    dateOfBirth.value = DateTime(value.year, value.month, value.day);
    _validateForm();
  }

  void setGender(String? value) {
    gender.value = value ?? '';
    _validateForm();
  }

  void setAcceptedTerms(bool? value) {
    acceptedTerms.value = value ?? false;
    _validateForm();
  }

  void nextStep() {
    if (canContinue && currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0 && !isLoading.value) {
      currentStep.value--;
    }
  }

  Future<bool> submit() async {
    if (!isValid || isLoading.value) {
      return false;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _authApi.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        idNumber: idNumberController.text.trim(),
        dateOfBirth: dateOfBirth.value!,
        gender: gender.value,
        address: addressController.text.trim(),
        acceptedTerms: acceptedTerms.value,
      );
      return true;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  static bool isPhoneValid(String value) =>
      value.replaceAll(RegExp(r'\D'), '').length >= 7;

  static bool isAdult(DateTime dateOfBirth, {DateTime? today}) {
    final currentDate = today ?? DateTime.now();
    var age = currentDate.year - dateOfBirth.year;
    if (currentDate.month < dateOfBirth.month ||
        (currentDate.month == dateOfBirth.month &&
            currentDate.day < dateOfBirth.day)) {
      age--;
    }
    return age >= 18;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    idNumberController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
