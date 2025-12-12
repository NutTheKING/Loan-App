import 'package:flutter/material.dart';

class CustomeCardWidget extends StatelessWidget {
  const CustomeCardWidget({super.key, required this.onTap, required this.padding, required this.child});

  final Function() onTap;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: child,
      ),
    );
  }
}
