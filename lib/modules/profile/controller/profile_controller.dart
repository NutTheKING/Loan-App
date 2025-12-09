import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/model/personal_information_model.dart';
import 'package:loan_app/modules/profile/model/profile_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

// class ProfileController extends GetxController {
//   var fullName = 'John Doe'.obs;
//   var email = 'john@example.com'.obs;
//   var dob = DateTime(1990, 1, 1).obs;
//   var idNumber = '1234567890'.obs;

//   void logout() {
//     SnackBar(
//       content: Text("Logout?"),
//       action: SnackBarAction(label: "logout", onPressed: () => appRouter.push('/login')),
//     );
//   }
// }

class ProfileController extends GetxController {
  var user = UserProfileModel(
    fullName: "Tinut Chan",
    email: "tinut@example.com",
    phone: "09123456789",
    address: "Phnom Penh, Cambodia",
    creditLimit: 5000,
    job: "Software Developer",
    gender: "Male",
  ).obs;

  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.offAllNamed("/login");
      },
    );
  }

  //------ App Version  -------

  final appVersion = "Loading...".obs;

  @override
  void onInit() {
    super.onInit();
    loadVersion();
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = "${info.version} (${info.buildNumber})";
  }

  Rx<UserProfile> users = UserProfile(
    profileUrl: "",
    phoneNumber: "",
    actualName: "",
    idCardNumber: "",
    gender: "",
    currentJob: "",
    stableIncome: 0,
    loanPurpose: "",
    currentAddress: "",
    guarantorName: "",
    guarantorPhone: "",
    borrowingAmount: 0,
    months: 0,
    monthlyPayment: 0,
  ).obs;

  String get maskedId {
    if (users.value.showFullId) return users.value.idCardNumber;
    if (users.value.idCardNumber.length < 4) return "***";

    final last4 = users.value.idCardNumber.substring(users.value.idCardNumber.length - 4);
    return "*** *** $last4";
  }

  void toggleShowId() {
    users.update((u) {
      u!.showFullId = !u.showFullId;
    });
  }
}
