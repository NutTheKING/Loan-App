import 'package:flutter/material.dart';

class AppTextTheme {
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(fontFamily: "Larken", fontWeight: FontWeight.bold, height: 1.2, fontSize: 48),
    headlineMedium: TextStyle(fontFamily: "Larken", fontWeight: FontWeight.w600, fontSize: 28, height: 1.2),
    titleLarge: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w700, fontSize: 18),
    bodyLarge: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w500, fontSize: 16),
    bodyMedium: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.normal, fontSize: 14),
    labelSmall: TextStyle(fontFamily: "DMSans", fontWeight: FontWeight.w300, fontSize: 11),
  );
}
