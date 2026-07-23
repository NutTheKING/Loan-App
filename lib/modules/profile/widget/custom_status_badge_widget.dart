import 'package:flutter/material.dart';

class CustomStatusBadgeWidget extends StatelessWidget {
  final String status;

  const CustomStatusBadgeWidget({super.key, required this.status});

  Color _getColor() {
    switch (status.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "due":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      case "approved":
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  String _getText() {
    switch (status.toLowerCase()) {
      case "paid":
        return "PAID";
      case "due":
        return "DUE";
      case "rejected":
        return "REJECTED";
      case "approved":
        return "APPROVED";
      default:
        return "PENDING";
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final text = _getText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
