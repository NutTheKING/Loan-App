import 'package:flutter/material.dart';
import 'package:loan_app/modules/deposit/widget/custom_deposit_method_widget.dart';
import 'package:loan_app/modules/deposit/widget/custome_deposit_card_widget.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deposit"), centerTitle: true),
      backgroundColor: const Color(0xfff3f6f9),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DepositCard(amount: "0.00"),

            const SizedBox(height: 20),
            const Text("Deposit Methods", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: const [
                  DepositMethodTile(
                    icon: Icons.account_balance_wallet,
                    title: "Bank Transfer",
                    subtitle: "Instant | No fees",
                  ),
                  DepositMethodTile(
                    icon: Icons.credit_card,
                    title: "Visa / Mastercard",
                    subtitle: "Secure online payment",
                  ),
                  DepositMethodTile(icon: Icons.qr_code_2, title: "QR Payment", subtitle: "Scan & pay instantly"),
                  DepositMethodTile(
                    icon: Icons.store,
                    title: "Cash Deposit",
                    subtitle: "Available at all partner stores",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
