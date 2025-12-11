import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExchangeController extends GetxController {
  var fromCurrency = "USD".obs;
  var toCurrency = "PHP".obs;
  var amount = 1.0.obs;
  var convertedAmount = 0.0.obs;
  var rate = 0.0.obs;
  var lastUpdated = DateTime.now().obs;
  var isLoading = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchRate();
    // Auto refresh every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => fetchRate());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void setFromCurrency(String value) => fromCurrency.value = value;
  void setToCurrency(String value) => toCurrency.value = value;
  void setAmount(String value) {
    amount.value = double.tryParse(value) ?? 0;
    convertedAmount.value = (amount.value * rate.value);
  }

  Future<void> fetchRate() async {
    try {
      isLoading.value = true;
      // Example API: exchangerate-api.com or use your own backend
      final url = Uri.parse(
        'https://api.exchangerate.host/latest?base=${fromCurrency.value}&symbols=${toCurrency.value}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        rate.value = (data['rates'][toCurrency.value] ?? 0).toDouble();
        convertedAmount.value = amount.value * rate.value;
        lastUpdated.value = DateTime.now();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch exchange rate");
    } finally {
      isLoading.value = false;
    }
  }
}
