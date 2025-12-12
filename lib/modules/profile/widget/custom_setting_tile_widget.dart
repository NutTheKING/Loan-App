import 'package:flutter/material.dart';

class CustomSettingTileWidget extends StatelessWidget {
  const CustomSettingTileWidget({super.key, this.title, this.icon, this.onTap});

  final String? title;
  final IconData? icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title ?? ''),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
