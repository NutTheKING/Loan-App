import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawView extends StatelessWidget {
  const WithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Request')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Amount')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Remarks')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  Get.snackbar('Submitted', 'Withdraw request sent'),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
