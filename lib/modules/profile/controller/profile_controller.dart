import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/routers/app_router.dart';

class ProfileController extends GetxController {
  var fullName = 'John Doe'.obs;
  var email = 'john@example.com'.obs;
  var dob = DateTime(1990, 1, 1).obs;
  var idNumber = '1234567890'.obs;

  void logout() {
    SnackBar(
      content: Text("Logout?"),
      action: SnackBarAction(label: "logout", onPressed: () => appRouter.push('/login')),
    );
  }
}
