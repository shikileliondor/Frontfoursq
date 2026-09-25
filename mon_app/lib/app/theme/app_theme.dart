import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primaryBlue = Color(0xFF102A63);
  static const actionRed = Color(0xFFE31E2D);

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryBlue,
          secondary: actionRed,
          surface: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(letterSpacing: 0),
        titleMedium: TextStyle(letterSpacing: 0),
        bodyLarge: TextStyle(letterSpacing: 0),
        labelLarge: TextStyle(letterSpacing: 0, fontWeight: FontWeight.w700),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: actionRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: primaryBlue,
        ),
      ),
    );
  }
}
