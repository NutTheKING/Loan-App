import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/exchange_rate/controller/exchange_rate_controller.dart';

class ExchangeScreen extends StatelessWidget {
  final ExchangeController ec = Get.put(ExchangeController());

  ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exchange Rate")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: ec.fromCurrency.value,
                      items: [
                        "USD",
                        "EUR",
                        "JPY",
                        "PHP",
                      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (e) => ec.setFromCurrency,
                      decoration: const InputDecoration(labelText: "From", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.swap_horiz),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: ec.toCurrency.value,
                      items: [
                        "USD",
                        "EUR",
                        "JPY",
                        "PHP",
                      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (e) => ec.setToCurrency,
                      decoration: const InputDecoration(labelText: "To", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount in ${ec.fromCurrency.value}",
                  border: const OutlineInputBorder(),
                ),
                onChanged: ec.setAmount,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ec.isLoading.value
                  ? const CircularProgressIndicator()
                  : Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "Rate: 1 ${ec.fromCurrency.value} = ${ec.rate.value.toStringAsFixed(4)} ${ec.toCurrency.value}",
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Converted: ${ec.convertedAmount.value.toStringAsFixed(2)} ${ec.toCurrency.value}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("Last Updated: ${ec.lastUpdated.value.toLocal().toString().split('.')[0]}"),
                          ],
                        ),
                      ),
                    ),
            ),
            const Spacer(),
            Obx(
              () => ElevatedButton.icon(
                onPressed: ec.fetchRate,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Rate"),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
