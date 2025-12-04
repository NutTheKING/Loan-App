import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

class AppTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.homeBackground,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.homeBackground,
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(elevation: 0),
  );
}

ThemeData theme() {
  return ThemeData.light().copyWith(
    primaryColor: AppColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        // fontFamily: local.toLowerCase() == 'khm'
        //     ? 'nokora_regular'
        //     : Platform.isAndroid
        //         ? 'roboto_regular'
        //         : Platform.isAndroid
        //             ? 'roboto_regular'
        //             : 'sf_pro_display',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 1.5,
      shadowColor: Colors.white30,
    ),
  );
}
