import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool hidePassword = true.obs;
  RxBool loading = false.obs;
  RxBool loginSuccess = false.obs;

  bool isValid() {
    return emailController.text.isNotEmpty && passwordController.text.length >= 6;
  }

  Future<void> signIn() async {
    loading.value = true;
    loginSuccess.value = false;

    await Future.delayed(const Duration(seconds: 2));

    // Simulate login success
    if (emailController.text == "test@gmail.com" && passwordController.text == "123456") {
      loginSuccess.value = true;
    } else {
      Get.snackbar(
        "Login Failed",
        "Invalid email or password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }

    loading.value = false;
  }
}
