import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF2D92); // rosa neón
  static const Color secondary = Color(0xFF8A2DFF); // morado neón
  static const Color accent = Color(0xFF00F5A0); // verde neón

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF050016),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    // 👇 Aquí el cambio importante: CardThemeData en lugar de CardTheme
    cardTheme: CardThemeData(
      color: const Color(0xFF130328),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      shadowColor: primary,
      margin: const EdgeInsets.all(16),
    ),
  );
}
