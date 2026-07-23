import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/core/auth/auth_session.dart';
import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/features/auth/data/auth_api.dart';
import 'package:loan_app/routers/app_router.dart';
import 'package:loan_app/utils/local_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileController extends GetxController {
  ProfileController({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  static ProfileController ensure() => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  static const _darkModeKey = 'settings_dark_mode';
  static const _paymentReminderKey = 'settings_payment_reminder';
  static const _promotionReminderKey = 'settings_promotion_reminder';
  static const _systemAlertKey = 'settings_system_alert';
  static const _biometricKey = 'settings_biometric';

  final ApiClient _client;
  final user = Rxn<AuthUser>();
  final loans = <Map<String, dynamic>>[].obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final appVersion = 'Loading…'.obs;

  final isDarkMode = false.obs;
  final paymentReminder = true.obs;
  final promotionReminder = true.obs;
  final systemAlert = true.obs;
  final biometricEnabled = false.obs;

  Map<String, dynamic>? get latestLoan => loans.firstOrNull;

  List<Map<String, dynamic>> get repayments {
    final value = latestLoan?['repayments'];
    return _mapList(value);
  }

  String get fullName => user.value?.fullName ?? 'Loan customer';
  String get email => user.value?.email ?? '';
  String get role => user.value?.role ?? 'CUSTOMER';
  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  String get maskedId => _mask(user.value?.idNumber);
  String get maskedAccount => _mask('${latestLoan?['accountNumber'] ?? ''}');

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    loadVersion();
    loadAccount();
  }

  Future<void> loadAccount() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final responses = await Future.wait([
        _client.get('/auth/me'),
        _client.get('/loans'),
        _client.get('/dashboard'),
      ]);
      user.value = AuthUser.fromJson(
        Map<String, dynamic>.from(responses[0]['user'] as Map),
      );
      loans.assignAll(_mapList(responses[1]['loans']));
      transactions.assignAll(_mapList(responses[2]['transactions']));
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    await LocalStorage.storeData(key: _darkModeKey, value: value);
  }

  Future<void> setPaymentReminder(bool value) =>
      _setPreference(paymentReminder, _paymentReminderKey, value);

  Future<void> setPromotionReminder(bool value) =>
      _setPreference(promotionReminder, _promotionReminderKey, value);

  Future<void> setSystemAlert(bool value) =>
      _setPreference(systemAlert, _systemAlertKey, value);

  Future<void> setBiometric(bool value) =>
      _setPreference(biometricEnabled, _biometricKey, value);

  Future<void> _setPreference(RxBool setting, String key, bool value) async {
    setting.value = value;
    await LocalStorage.storeData(key: key, value: value);
  }

  Future<void> _loadPreferences() async {
    isDarkMode.value = await LocalStorage.getBooleanValue(key: _darkModeKey);
    paymentReminder.value = await _readDefaultTrue(_paymentReminderKey);
    promotionReminder.value = await _readDefaultTrue(_promotionReminderKey);
    systemAlert.value = await _readDefaultTrue(_systemAlertKey);
    biometricEnabled.value = await LocalStorage.getBooleanValue(
      key: _biometricKey,
    );
    if (isDarkMode.value) {
      Get.changeThemeMode(ThemeMode.dark);
    }
  }

  Future<bool> _readDefaultTrue(String key) async {
    final preferences = await LocalStorage.init();
    return preferences.containsKey(key)
        ? preferences.getBool(key) ?? true
        : true;
  }

  Future<void> contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@loanapp.com',
      queryParameters: {'subject': 'Loan app support request'},
    );
    if (!await launchUrl(uri)) {
      Get.snackbar(
        'Support email unavailable',
        'Email support@loanapp.com and our team will help you.',
      );
    }
  }

  void logout() {
    Get.defaultDialog(
      title: 'Sign out',
      middleText: 'Are you sure you want to sign out on this device?',
      textCancel: 'Cancel',
      textConfirm: 'Sign out',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await AuthApi().signOut();
        appRouter.go('/login');
      },
    );
  }

  static List<Map<String, dynamic>> _mapList(Object? value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const [];

  static String _mask(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Not available';
    if (text.length <= 4) return '••••';
    return '•••• •••• ${text.substring(text.length - 4)}';
  }
}
