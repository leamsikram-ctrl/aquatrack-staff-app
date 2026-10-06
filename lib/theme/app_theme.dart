import 'package:flutter/material.dart';

class AppTheme {
  // Strict 3-Color Palette
  static const Color brandBlue = Color(0xFF1E6FD9);
  static const Color brandBlueLight = Color(0xFFF0F6FD);
  static const Color brandWhite = Color(0xFFFFFFFF);
  static const Color brandBlack = Color(0xFF000000);

  // Uniform 10px Typography
  static const double uniformFontSize = 10.0;

  static final TextStyle baseStyle = const TextStyle(
    fontFamily: 'Inter',
    fontSize: uniformFontSize,
    color: brandBlack,
    letterSpacing: 0.1,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: brandWhite,
      primaryColor: brandBlue,
      colorScheme: const ColorScheme.light(
        primary: brandBlue,
        onPrimary: brandWhite,
        surface: brandWhite,
        onSurface: brandBlack,
        error: brandBlack,
        onError: brandWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: brandWhite,
        foregroundColor: brandBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0x1A000000), width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: baseStyle.copyWith(fontWeight: FontWeight.bold),
        displayMedium: baseStyle.copyWith(fontWeight: FontWeight.bold),
        displaySmall: baseStyle.copyWith(fontWeight: FontWeight.bold),
        headlineLarge: baseStyle.copyWith(fontWeight: FontWeight.bold),
        headlineMedium: baseStyle.copyWith(fontWeight: FontWeight.bold),
        headlineSmall: baseStyle.copyWith(fontWeight: FontWeight.bold),
        titleLarge: baseStyle.copyWith(fontWeight: FontWeight.bold),
        titleMedium: baseStyle.copyWith(fontWeight: FontWeight.bold),
        titleSmall: baseStyle.copyWith(fontWeight: FontWeight.bold),
        bodyLarge: baseStyle,
        bodyMedium: baseStyle,
        bodySmall: baseStyle.copyWith(color: const Color(0xB3000000)),
        labelLarge: baseStyle.copyWith(fontWeight: FontWeight.bold),
        labelMedium: baseStyle.copyWith(fontWeight: FontWeight.w500),
        labelSmall: baseStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brandWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: baseStyle.copyWith(color: const Color(0x66000000)),
        labelStyle: baseStyle.copyWith(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x33000000), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x33000000), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: brandBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: brandWhite,
          elevation: 0,
          textStyle: baseStyle.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandBlack,
          side: const BorderSide(color: Color(0x33000000), width: 1),
          textStyle: baseStyle.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: brandWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0x1A000000), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

