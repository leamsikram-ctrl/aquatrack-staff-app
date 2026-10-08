import 'package:flutter/material.dart';

class AppTheme {
  // Strict 3-Color Palette
  // 1. Blue (Primary Brand & Interactive Accent): #1E6FD9
  // 2. White (Base Surfaces, Canvas, Cards): #FFFFFF
  // 3. Black (All Text & Structural Lines): #000000
  static const Color brandBlue = Color(0xFF1E6FD9);
  static const Color brandBlueLight = Color(0xFFF0F6FD);
  static const Color brandWhite = Color(0xFFFFFFFF);
  static const Color brandBlack = Color(0xFF000000);

  // Strict Uniform 14px Typography (Inter)
  static const double uniformFontSize = 14.0;

  static final TextStyle baseStyle = const TextStyle(
    fontFamily: 'Inter',
    fontSize: uniformFontSize,
    color: brandBlack,
    letterSpacing: 0.0,
    height: 1.4,
  );

  // Hard Shadows & Elevations (Matching Frontend SaaS Finish)
  // Card Hard Shadow: shadow-[3px_3px_0px_0px_rgba(0,0,0,0.15)]
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x26000000), // rgba(0,0,0,0.15)
      offset: Offset(3, 3),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  // Shelf Divider Shadow: shadow-[0_2px_0px_0px_rgba(0,0,0,0.06)]
  static const List<BoxShadow> shelfShadow = [
    BoxShadow(
      color: Color(0x10000000), // rgba(0,0,0,0.06)
      offset: Offset(0, 2),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  // Standard Card Box Decoration
  static BoxDecoration cardDecoration({
    Color backgroundColor = brandWhite,
    Color borderColor = const Color(0x26000000), // border-black/15
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12), // rounded-xl (12px)
      border: Border.all(color: borderColor, width: 1),
      boxShadow: withShadow ? cardShadow : null,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: brandWhite,
      primaryColor: brandBlue,
      fontFamily: 'Inter',
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
          letterSpacing: 0.2,
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
        bodySmall: baseStyle.copyWith(color: const Color(0x99000000)),
        labelLarge: baseStyle.copyWith(fontWeight: FontWeight.bold),
        labelMedium: baseStyle.copyWith(fontWeight: FontWeight.w500),
        labelSmall: baseStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brandWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: baseStyle.copyWith(color: const Color(0x66000000)),
        labelStyle: baseStyle.copyWith(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // rounded-lg (8px)
          borderSide: const BorderSide(color: Color(0x26000000), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x26000000), width: 1),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded-lg (8px)
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandBlack,
          side: const BorderSide(color: Color(0x26000000), width: 1),
          textStyle: baseStyle.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded-lg (8px)
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: brandWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // rounded-xl (12px)
          side: const BorderSide(color: Color(0x26000000), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

