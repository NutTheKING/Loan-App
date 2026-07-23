import 'package:get/get.dart';
import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/utils/local_storage.dart';

class HomeController extends GetxController {
  HomeController({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;
  final recentTransactions = <Map<String, dynamic>>[].obs;
  final loans = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final hasPendingLoan = false.obs;
  final balance = 0.0.obs;
  final displayName = 'Member'.obs;

  Map<String, dynamic>? get pendingLoan =>
      loans.firstWhereOrNull((loan) => loan['status'] == 'PENDING');

  double get availableBalance => balance.value;

  @override
  void onInit() {
    super.onInit();
    _loadIdentity();
    loadDashboard();
  }

  Future<void> _loadIdentity() async {
    final fullName = await LocalStorage.getStringValue(
      key: LocalStorage.userNameKey,
    );
    if (fullName.trim().isNotEmpty) {
      displayName.value = fullName.trim().split(RegExp(r'\s+')).first;
    }
  }

  Future<void> loadDashboard() async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _client.get('/dashboard');
      loans.assignAll(_mapList(response['loans']));
      recentTransactions.assignAll(_mapList(response['transactions']));
      hasPendingLoan.value =
          response['hasPendingLoan'] == true || pendingLoan != null;
      balance.value = _number(response['availableBalance']);
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  static List<Map<String, dynamic>> _mapList(Object? value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const [];

  static double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
