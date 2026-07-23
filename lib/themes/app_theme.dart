import 'package:flutter/material.dart';
import 'package:loan_app/themes/app_color.dart';
import 'package:loan_app/themes/app_text_theme.dart';

class ThemeBase {
  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: dark ? const Color(0xFF53E7EC) : const Color(0xFF007F87),
      onPrimary: dark ? AppColors.strength : Colors.white,
      primaryContainer: dark
          ? const Color(0xFF004F54)
          : const Color(0xFFC9F7F8),
      onPrimaryContainer: dark
          ? const Color(0xFFB8F3F5)
          : const Color(0xFF00373B),
      secondary: dark ? const Color(0xFFB9A4FF) : AppColors.impact,
      onSecondary: dark ? const Color(0xFF26007B) : Colors.white,
      secondaryContainer: dark
          ? const Color(0xFF3B148D)
          : const Color(0xFFE9E1FF),
      onSecondaryContainer: dark
          ? const Color(0xFFE8DEFF)
          : const Color(0xFF25006E),
      tertiary: dark ? const Color(0xFFFFB1C6) : AppColors.potential,
      onTertiary: dark ? const Color(0xFF650027) : Colors.white,
      tertiaryContainer: dark
          ? const Color(0xFF8F003A)
          : const Color(0xFFFFD9E2),
      onTertiaryContainer: dark
          ? const Color(0xFFFFD9E2)
          : const Color(0xFF3F0017),
      error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFB42318),
      onError: dark ? const Color(0xFF690005) : Colors.white,
      errorContainer: dark ? const Color(0xFF93000A) : const Color(0xFFFFDAD6),
      onErrorContainer: dark
          ? const Color(0xFFFFDAD6)
          : const Color(0xFF410002),
      surface: dark ? const Color(0xFF17181F) : AppColors.cool,
      onSurface: dark ? const Color(0xFFE6E1E9) : AppColors.strength,
      surfaceContainerHighest: dark
          ? const Color(0xFF30313A)
          : const Color(0xFFE7ECEF),
      onSurfaceVariant: dark
          ? const Color(0xFFCAC4D0)
          : const Color(0xFF53565F),
      outline: dark ? const Color(0xFF948F99) : const Color(0xFF74777F),
      outlineVariant: dark ? const Color(0xFF49454F) : const Color(0xFFC4C7CE),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: dark ? const Color(0xFFE6E1E9) : const Color(0xFF303039),
      onInverseSurface: dark
          ? const Color(0xFF303039)
          : const Color(0xFFF5EFF7),
      inversePrimary: dark ? const Color(0xFF007F87) : const Color(0xFF53E7EC),
      surfaceTint: dark ? const Color(0xFF53E7EC) : const Color(0xFF007F87),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'AppSans',
      textTheme: AppTextTheme.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF20212A) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF20212A) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}
