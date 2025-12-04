import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/routers/app_router.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLogged = false.obs;
  final email = ''.obs;
  final password = ''.obs;

  void login() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLogged.value = true;
    isLoading.value = false;
    if (email.value == "test" && password.value == "1234") {
      appRouter.go('/home');
    }
    // Navigate to Home
    // GoRouter.of(Get.context!).go('/home');
  }

  void logout() {
    isLogged.value = false;
    GoRouter.of(Get.context!).go('/login');
  }
}
