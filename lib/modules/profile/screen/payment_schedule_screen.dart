import 'package:flutter/material.dart';

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
                  _summaryRow("Loan Amount", "₱ 350,000"),
                  _summaryRow("Monthly Payment", "₱ 12,800"),
                  _summaryRow("Interest Rate", "0.5% / month"),
                  _summaryRow("Period", "24 Months"),
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
                  return _paymentCard(
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

  // ------------------- SUMMARY ROW -----------------------
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ------------------- PAYMENT CARD -----------------------
  Widget _paymentCard({
    required int month,
    required String dueDate,
    required String principal,
    required String interest,
    required String balance,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == "paid"
              ? Colors.green.withOpacity(0.5)
              : status == "due"
              ? Colors.orange.withOpacity(0.6)
              : Colors.blueGrey.shade100,
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Month $month", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 10),

          _itemRow("Due Date", dueDate),
          _itemRow("Principal", principal),
          _itemRow("Interest", interest),
          _itemRow("Remaining Balance", balance),
        ],
      ),
    );
  }

  // ------------------- ITEM ROW -----------------------
  Widget _itemRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ------------------- STATUS BADGE -----------------------
  Widget _statusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case "paid":
        color = Colors.green;
        text = "PAID";
        break;
      case "due":
        color = Colors.orange;
        text = "DUE";
        break;
      default:
        color = Colors.blueGrey;
        text = "PENDING";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
