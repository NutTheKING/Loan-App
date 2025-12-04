import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/auth/signup/model/register_model.dart';

class RegisterController extends GetxController {
  var isLoading = false.obs;
  var model = RegisterModel(fullName: '', sex: '', dob: DateTime.now(), email: '', idNumber: '').obs;

  Future<void> submit() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    // TODO: send to backend
    isLoading.value = false;
    GoRouter.of(Get.context!).go('/home');
  }
}
