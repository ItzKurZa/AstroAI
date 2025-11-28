import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/k_sizes.dart';

class OnboardingPalette {
  const OnboardingPalette._();

  static const background = AppColors.background;
  static const surface = AppColors.surfacePrimary;
  static const accent = AppColors.primary;
  static const indicatorDim = Color(0xFF2F1B52);
}

class OnboardingTypography {
  const OnboardingTypography._();

  static TextStyle get title => GoogleFonts.literata(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.64,
        height: 1.5,
      );

  static TextStyle get subtitle => GoogleFonts.literata(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
        letterSpacing: 0.2,
      );

  static TextStyle get body => GoogleFonts.literata(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.85),
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.literata(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.9),
      );

  static TextStyle get button => GoogleFonts.literata(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1D0E42),
      );
}

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: OnboardingPalette.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusCircular),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset('assets/images/app/logo.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class HomeIndicatorBar extends StatelessWidget {
  const HomeIndicatorBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

