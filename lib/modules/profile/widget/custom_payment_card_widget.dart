// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:loan_app/modules/profile/widget/custom_item_row_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_status_badge_widget.dart';

class CustomPaymentCardWidget extends StatelessWidget {
  const CustomPaymentCardWidget({
    super.key,
    this.status,
    this.month,
    this.dueDate,
    this.principal,
    this.interest,
    this.balance,
  });

  final String? status;
  final int? month;
  final String? dueDate;
  final String? principal;
  final String? interest;
  final String? balance;

  @override
  Widget build(BuildContext context) {
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
              CustomStatusBadgeWidget(status: status ?? ''),
            ],
          ),

          const SizedBox(height: 10),

          CustomItemRowWidget(label: "Due Date", value: dueDate),
          CustomItemRowWidget(label: "Principal", value: principal),
          CustomItemRowWidget(label: "Interest", value: interest),
          CustomItemRowWidget(label: "Remaining Balance", value: balance),
        ],
      ),
    );
  }
}
