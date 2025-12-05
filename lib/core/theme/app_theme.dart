import 'package:flutter/material.dart';
import '../constants/k_sizes.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFF1A1042),
      primaryColor: const Color(0xFFB9A4F4),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xFFB9A4F4),
        secondary: const Color(0xFFB9A4F4),
        surface: const Color(0xFF24124A),
        background: const Color(0xFF1A1042),
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: KSizes.fontSizeL,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: const TextStyle(
          fontSize: KSizes.fontSizeM,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: KSizes.fontSizeM,
          color: Colors.white,
        ),
        bodyMedium: const TextStyle(
          fontSize: KSizes.fontSizeS,
          color: Colors.white,
        ),
        labelLarge: const TextStyle(
          fontSize: KSizes.fontSizeS,
          color: Color(0xFFB9A4F4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF24124A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusDefault),
          borderSide: const BorderSide(
            color: Color(0xFFB9A4F4),
            width: KSizes.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusDefault),
          borderSide: const BorderSide(
            color: Color(0xFFB9A4F4),
            width: KSizes.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusDefault),
          borderSide: const BorderSide(
            color: Color(0xFFB9A4F4),
            width: KSizes.borderWidth,
          ),
        ),
        labelStyle: const TextStyle(color: Color(0xFFB9A4F4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB9A4F4),
          foregroundColor: Colors.white,
          minimumSize: Size.fromHeight(KSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusDefault),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB9A4F4),
          side: const BorderSide(
            color: Color(0xFFB9A4F4),
            width: KSizes.borderWidth,
          ),
          minimumSize: Size.fromHeight(KSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusDefault),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFB9A4F4),
        thickness: KSizes.divider,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFB9A4F4),
        size: KSizes.iconM,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1042),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFB9A4F4)),
        titleTextStyle: TextStyle(
          fontSize: KSizes.fontSizeM,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
