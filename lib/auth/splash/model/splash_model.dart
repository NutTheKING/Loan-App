// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:get/get.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';
import 'package:loan_app/routers/app_router.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _goToInitialRoute();
  }

  Future<void> _goToInitialRoute() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final authenticated = await AuthApi().hasSession();
    appRouter.go(authenticated ? '/home' : '/login');
  }
}
