import 'package:flutter/material.dart';

class CustomFaqItemWidget extends StatelessWidget {
  const CustomFaqItemWidget({super.key, this.title, this.onTap});

  final String? title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(title: Text(title ?? ''), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: onTap),
    );
  }
}
