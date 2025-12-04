// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:get/get.dart';
import 'package:loan_app/routers/app_router.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(seconds: 2), () {
      // Navigate to login or home depending on auth
      // For demo, go to login
      appRouter.go('/login');
    });
  }
}
