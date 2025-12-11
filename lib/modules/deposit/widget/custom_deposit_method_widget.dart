import 'package:flutter/material.dart';

class DepositMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DepositMethodTile({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),

        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),

        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {},
      ),
    );
  }
}
