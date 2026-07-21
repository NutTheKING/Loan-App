import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';

class RegisterController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final idNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final formIsValid = false.obs;
  final _authApi = AuthApi();

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      fullNameController,
      emailController,
      idNumberController,
      passwordController,
    ]) {
      controller.addListener(_validateForm);
    }
  }

  bool get isValid => formIsValid.value;

  void _validateForm() {
    formIsValid.value =
        fullNameController.text.trim().length >= 2 &&
        GetUtils.isEmail(emailController.text.trim()) &&
        idNumberController.text.trim().length >= 4 &&
        passwordController.text.length >= 12;
  }

  Future<bool> submit() async {
    if (!isValid || isLoading.value) {
      return false;
    }
    isLoading.value = true;
    try {
      await _authApi.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        idNumber: idNumberController.text.trim(),
      );
      return true;
    } on ApiException catch (error) {
      Get.snackbar(
        'Registration failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    idNumberController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
