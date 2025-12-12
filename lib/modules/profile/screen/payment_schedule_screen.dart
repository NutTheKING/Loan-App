import 'package:flutter/material.dart';
import 'package:loan_app/modules/profile/widget/custom_payment_card_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_summary_row_widget.dart';

class PaymentScheduleView extends StatelessWidget {
  const PaymentScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdde6ea),
      appBar: AppBar(title: const Text("Payment Schedule"), elevation: 0, backgroundColor: const Color(0xffdde6ea)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- SUMMARY HEADER ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  const Text("Loan Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  CustomSummaryRowWidget(label: "Loan Amount", value: "₱ 350,000"),
                  CustomSummaryRowWidget(label: "Monthly Payment", value: "₱ 12,800"),
                  CustomSummaryRowWidget(label: "Interest Rate", value: "0.5% / month"),
                  CustomSummaryRowWidget(label: "Period", value: "24 Months"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            // ---------------- SCHEDULE LIST ----------------
            Expanded(
              child: ListView.builder(
                itemCount: 24,
                itemBuilder: (_, index) {
                  return CustomPaymentCardWidget(
                    month: index + 1,
                    dueDate: "2025-${(index % 12) + 1}-15",
                    principal: "₱ 10,500",
                    interest: "₱ 2,300",
                    balance: "₱ ${(350000 - (index * 10500)).clamp(0, 350000)}",
                    status: index < 4
                        ? "paid"
                        : index == 4
                        ? "due"
                        : "pending",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
