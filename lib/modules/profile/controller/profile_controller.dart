import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';
import 'package:loan_app/modules/profile/model/beneficiary_information_model.dart';
import 'package:loan_app/modules/profile/model/personal_information_model.dart';
import 'package:loan_app/modules/profile/model/profile_model.dart';
import 'package:loan_app/routers/app_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  //========setting========

  var isDarkMode = false.obs;
  var paymentReminder = true.obs;
  var promotionReminder = true.obs;
  var systemAlert = true.obs;
  var biometricEnabled = false.obs;

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
      onConfirm: () async {
        Get.back();
        await AuthApi().signOut();
        appRouter.go('/login');
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

    final last4 = users.value.idCardNumber.substring(
      users.value.idCardNumber.length - 4,
    );
    return "*** *** $last4";
  }

  void toggleShowId() {
    users.update((u) {
      u!.showFullId = !u.showFullId;
    });
  }

  final Rx<Beneficiary> b = Beneficiary(
    fullName: "",
    phoneNumber: "",
    idCard: "",
    relationship: "",
    address: "",
  ).obs;

  String get maskedBeneficiaInfoId {
    if (b.value.showFullId) return b.value.idCard;
    if (b.value.idCard.length < 4) return "***";

    final last4 = b.value.idCard.substring(b.value.idCard.length - 4);
    return "*** *** $last4";
  }

  void toggleId() {
    b.update((data) {
      data!.showFullId = !data.showFullId;
    });
  }

  //============= Transactions ===================

  var filter = 'All'.obs;

  var transactions = [
    {
      'type': 'Loan Payment',
      'date': '2025-01-10 14:22',
      'amount': -3500.0,
      'status': 'Success',
    },
    {
      'type': 'Loan Disbursement',
      'date': '2025-01-01 09:00',
      'amount': 150000.0,
      'status': 'Completed',
    },
    {
      'type': 'Late Fee',
      'date': '2024-12-29 18:40',
      'amount': -200.0,
      'status': 'Pending',
    },
  ].obs;

  //============ Open telegram ===============
  Future<void> openTelegram() async {
    final Uri telegramUri = Uri.parse("https://t.me/keyscript1123");

    if (!await launchUrl(telegramUri, mode: LaunchMode.externalApplication)) {
      throw "Could not launch Telegram";
    }
  }
}
