import 'package:flutter/material.dart';

class CustomTransactionCardWidget extends StatelessWidget {
  final String type; // e.g. "Deposit"
  final String date; // e.g. "2025-12-12"
  final double amount; // e.g. 50.0
  final String status; // e.g. "Paid", "Pending"
  final VoidCallback? onTap;

  const CustomTransactionCardWidget({
    super.key,
    required this.type,
    required this.date,
    required this.amount,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = amount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // -------------------------------
              // Leading Icon
              // -------------------------------
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade50,
                child: Icon(Icons.receipt_long, color: Colors.blue.shade700),
              ),

              const SizedBox(width: 16),

              // -------------------------------
              // Middle Info (Title & Date)
              // -------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------
              // Amount + Status Chip
              // -------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isPositive ? '+' : ''}$amount",
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 6),

                  _statusChip(status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // Custom Status Chip (Paid, Due, Pending)
  // ------------------------------------------------
  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "paid":
        color = Colors.green;
        break;
      case "due":
        color = Colors.orange;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
