import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionDetail extends StatelessWidget {
  final Map transaction;
  final VoidCallback? onDownload;

  const TransactionDetail({super.key, required this.transaction, this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
            ),
          ),
          SizedBox(height: 20),

          // Transaction type
          Text(transaction['type'] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),

          // Date & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Date: ${transaction['date'] ?? ''}", style: TextStyle(color: Colors.grey[600])),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (transaction['status'] == "Completed" ? Colors.green[100] : Colors.orange[100]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction['status'] ?? '',
                  style: TextStyle(
                    color: (transaction['status'] == "Completed" ? Colors.green[800] : Colors.orange[800]),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Amount
          Text(
            "Amount: ${transaction['amount'] ?? 0}",
            style: TextStyle(
              color: (transaction['amount'] ?? 0) > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 25),

          // Download button
          ElevatedButton.icon(
            onPressed: onDownload,
            icon: Icon(Icons.download),
            label: Text("Download Receipt"),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Call this to show the bottom sheet
  static void show(Map transaction, {VoidCallback? onDownload}) {
    Get.bottomSheet(
      TransactionDetail(transaction: transaction, onDownload: onDownload),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
