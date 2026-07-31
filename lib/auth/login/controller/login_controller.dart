import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/core/auth/auth_session.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';

class SignInController extends GetxController {
  SignInController({AuthApi? authApi}) : _authApi = authApi ?? AuthApi();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthApi _authApi;

  RxBool hidePassword = true.obs;
  RxBool loading = false.obs;
  RxBool loginSuccess = false.obs;
  RxBool formIsValid = false.obs;
  RxString errorMessage = ''.obs;

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
        passwordController.text.isNotEmpty;
  }

  Future<AuthUser?> signIn() async {
    if (!isValid || loading.value) {
      return null;
    }
    loading.value = true;
    loginSuccess.value = false;
    errorMessage.value = '';

    try {
      final session = await _authApi.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      loginSuccess.value = true;
      return session.user;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      return null;
    } catch (error) {
      debugPrint('Unexpected login failure: $error');
      errorMessage.value = 'Unable to complete sign-in. Please try again.';
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
