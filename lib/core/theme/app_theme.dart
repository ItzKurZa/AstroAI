import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/k_sizes.dart';

class AppTheme {
  const AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    canvasColor: AppColors.surfacePrimary,
    fontFamily: GoogleFonts.literata().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfacePrimary,
    ),
    textTheme: GoogleFonts.literataTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ).copyWith(
      headlineLarge: GoogleFonts.literata(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        ),
      headlineMedium: GoogleFonts.literata(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        ),
      titleLarge: GoogleFonts.literata(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        ),
      titleMedium: GoogleFonts.literata(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        ),
      bodyLarge: GoogleFonts.literata(
        fontSize: 16,
        height: 1.5,
        color: AppColors.textPrimary,
        ),
      bodyMedium: GoogleFonts.literata(
        fontSize: 14,
        height: 1.4,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.literata(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
          ),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primary),
        ),
    iconTheme: const IconThemeData(
      color: AppColors.primary,
      size: KSizes.iconM,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfacePrimary,
          minimumSize: Size.fromHeight(KSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusDefault),
          ),
        textStyle: GoogleFonts.literata(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderStrong, width: 1.2),
          minimumSize: Size.fromHeight(KSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusDefault),
          ),
        textStyle: GoogleFonts.literata(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceSecondary,
      hintStyle: GoogleFonts.literata(
        color: AppColors.textMuted,
        fontSize: 16,
      ),
      labelStyle: GoogleFonts.literata(
        color: AppColors.primary,
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusDefault),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusDefault),
        borderSide: const BorderSide(color: AppColors.borderStrong, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusDefault),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderStrong,
      thickness: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceSecondary,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusDefault),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfacePrimary,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.textMuted),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      ),
    );
}
