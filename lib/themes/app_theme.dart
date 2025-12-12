import 'package:flutter/material.dart';
import 'package:loan_app/themes/app_color.dart';
import 'package:loan_app/themes/app_text_theme.dart';

class ThemeBase {
  // 🌞 LIGHT THEME
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.cool,
      fontFamily: "DMSans",

      colorScheme: ColorScheme.light(primary: AppColors.primary, secondary: AppColors.impact, surface: AppColors.cool),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cool,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.strength),
        titleTextStyle: TextStyle(fontFamily: "Larken", fontSize: 20, color: AppColors.strength),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cool,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.strength,
      ),

      textTheme: AppTextTheme.textTheme,
    );
  }

  // 🌚 DARK THEME
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.strength,
      fontFamily: "DMSans",

      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.impact,
        surface: AppColors.strength,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.strength,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.cool),
        titleTextStyle: TextStyle(fontFamily: "Larken", fontSize: 20, color: AppColors.cool),
      ),

      cardTheme: CardThemeData(
        color: AppColors.impact.withOpacity(.15),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.strength,
      ),

      textTheme: AppTextTheme.textTheme.apply(bodyColor: AppColors.cool, displayColor: AppColors.cool),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../core/constants.dart';

// class AppTheme {
//   ThemeData lightTheme = ThemeData(
//     brightness: Brightness.light,
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: AppColors.homeBackground,
//     fontFamily: 'Roboto',
//     appBarTheme: const AppBarTheme(
//       elevation: 0,
//       backgroundColor: AppColors.homeBackground,
//       iconTheme: IconThemeData(color: Colors.black87),
//     ),
//   );

//   static ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: Colors.black,
//     appBarTheme: const AppBarTheme(elevation: 0),
//   );
// }

// ThemeData theme() {
//   return ThemeData.light().copyWith(
//     primaryColor: AppColors.primary,
//     appBarTheme: AppBarTheme(
//       backgroundColor: Colors.white,
//       centerTitle: true,
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       iconTheme: const IconThemeData(color: Colors.black),
//       titleTextStyle: TextStyle(
//         // fontFamily: local.toLowerCase() == 'khm'
//         //     ? 'nokora_regular'
//         //     : Platform.isAndroid
//         //         ? 'roboto_regular'
//         //         : Platform.isAndroid
//         //             ? 'roboto_regular'
//         //             : 'sf_pro_display',
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//       ),
//       elevation: 1.5,
//       shadowColor: Colors.white30,
//     ),
//   );
// }
