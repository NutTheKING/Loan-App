import 'package:flutter/material.dart';

class DepositCard extends StatelessWidget {
  final String amount;
  const DepositCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      width: w,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1e88e5),
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xff2196f3), Color(0xff64b5f6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),

          const SizedBox(height: 8),

          Text(
            "\$$amount",
            style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text("Deposit Now"),
            ),
          ),
        ],
      ),
    );
  }
}
