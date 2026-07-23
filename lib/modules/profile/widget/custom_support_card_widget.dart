import 'package:flutter/material.dart';

class CustomSupportCardWidgety extends StatelessWidget {
  const CustomSupportCardWidgety({
    super.key,
    this.color,
    required this.icon,
    this.title,
    this.subtitle,
    this.description,
    this.onTap,
    this.child,
    this.buttonText,
  });

  final Color? color;
  final IconData icon;
  final String? title;
  final String? subtitle;
  final String? description;
  final Function()? onTap;
  final Widget? child;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color!.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 14),

          Text(
            title ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),
          Text(
            subtitle ?? '',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 10),
          Text(
            description ?? '',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
              child: Text(
                buttonText ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
