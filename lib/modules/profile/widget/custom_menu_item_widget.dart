import 'package:flutter/material.dart';

class CustomMenuItemWidget extends StatelessWidget {
  const CustomMenuItemWidget({super.key, this.icon, this.title, this.onTap});

  final IconData? icon;
  final String? title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title ?? ''),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
