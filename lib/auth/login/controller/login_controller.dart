import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/core/auth/auth_session.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _authApi = AuthApi();

  RxBool hidePassword = true.obs;
  RxBool loading = false.obs;
  RxBool loginSuccess = false.obs;
  RxBool formIsValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  bool get isValid => formIsValid.value;

  void _validateForm() {
    formIsValid.value =
        GetUtils.isEmail(emailController.text.trim()) &&
        passwordController.text.length >= 12;
  }

  Future<AuthUser?> signIn() async {
    if (!isValid || loading.value) {
      return null;
    }
    loading.value = true;
    loginSuccess.value = false;

    try {
      final session = await _authApi.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      loginSuccess.value = true;
      return session.user;
    } on ApiException catch (error) {
      Get.snackbar(
        'Login failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } catch (error) {
      debugPrint('Unexpected login failure: $error');
      Get.snackbar(
        'Login failed',
        'Unable to complete sign-in. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
