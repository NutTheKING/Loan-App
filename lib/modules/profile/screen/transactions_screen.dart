import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';
import 'package:loan_app/modules/profile/widget/custom_filter_chip_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_show_transaction_detail_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_transaction_card_widget.dart';

class TransactionsScreen extends StatelessWidget {
  final ProfileController tc = Get.put(ProfileController());

  TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transactions"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search transactions",
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 12),

            // 🏷 Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomFilterChipWidget(label: "All", selectedValue: tc.filter),
                CustomFilterChipWidget(label: "This Week", selectedValue: tc.filter),
                CustomFilterChipWidget(label: "This Month", selectedValue: tc.filter),
                CustomFilterChipWidget(label: "Toda Year", selectedValue: tc.filter),
              ],
            ),

            SizedBox(height: 16),

            // 📋 Transaction List
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: tc.transactions.length,
                  itemBuilder: (_, i) {
                    final t = tc.transactions[i];
                    return CustomTransactionCardWidget(
                      type: t['type'].toString(),
                      date: t['date'].toString(),
                      amount: double.tryParse(t['amount'].toString()) ?? 0.0,
                      status: t['status'].toString(),
                      onTap: () => TransactionDetail(transaction: t),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📄 Bottom Sheet – Details
  // void _showTransactionDetail(Map t) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Center(
  //             child: Container(
  //               width: 50,
  //               height: 5,
  //               decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
  //             ),
  //           ),

  //           SizedBox(height: 20),

  //           Text(t['type'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

  //           SizedBox(height: 10),
  //           Text("Date: ${t['date']}"),
  //           Text("Status: ${t['status']}"),

  //           SizedBox(height: 20),

  //           Text(
  //             "Amount: ${t['amount']}",
  //             style: TextStyle(
  //               color: t['amount'] > 0 ? Colors.green : Colors.red,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 18,
  //             ),
  //           ),

  //           SizedBox(height: 20),

  //           ElevatedButton.icon(
  //             onPressed: () {},
  //             icon: Icon(Icons.download),
  //             label: Text("Download Receipt"),
  //             style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
