import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

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
              children: [_filterChip("All"), _filterChip("This Week"), _filterChip("This Month"), _filterChip("Today")],
            ),

            SizedBox(height: 16),

            // 📋 Transaction List
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: tc.transactions.length,
                  itemBuilder: (_, i) {
                    final t = tc.transactions[i];
                    return _transactionCard(t);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 Filter Chip Widget
  Widget _filterChip(String label) {
    return Obx(
      () => ChoiceChip(
        label: Text(label),
        selected: tc.filter.value == label,
        onSelected: (_) => tc.filter.value = label,
      ),
    );
  }

  // 🧾 Transaction Card
  Widget _transactionCard(Map t) {
    bool isPositive = t['amount'] > 0;

    return InkWell(
      onTap: () => _showTransactionDetail(t),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading Icon
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade50,
                child: Icon(Icons.receipt_long, color: Colors.blue),
              ),

              SizedBox(width: 16),

              // Middle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['type'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text(t['date'], style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),

              // Amount + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isPositive ? '+' : ''}${t['amount']}",
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Chip(
                    label: Text(t['status'], style: TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue.shade50,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📄 Bottom Sheet – Details
  void _showTransactionDetail(Map t) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
              ),
            ),

            SizedBox(height: 20),

            Text(t['type'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),
            Text("Date: ${t['date']}"),
            Text("Status: ${t['status']}"),

            SizedBox(height: 20),

            Text(
              "Amount: ${t['amount']}",
              style: TextStyle(
                color: t['amount'] > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.download),
              label: Text("Download Receipt"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
