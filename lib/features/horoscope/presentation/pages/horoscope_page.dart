import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_background.dart';

class HoroscopePage extends StatelessWidget {
  static const routeName = '/horoscope';

  const HoroscopePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Header with back button
              _buildHeader(context),
              // Progress indicator
              const _HoroscopeToggle(),
              const SizedBox(height: 24),
              // Logo and text
              const _LogoSection(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          'Mercury Retrograde',
                          style: GoogleFonts.literata(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.048,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Dec 13,',
                              style: GoogleFonts.literata(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '2023',
                              style: GoogleFonts.literata(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Info Card
                        const _InfoCard(),
                        const SizedBox(height: 24),
                        // Go Deeper Button
                        _PrimaryButton(
                          label: 'Go Deeper',
                          onTap: () {},
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfacePrimary,
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfacePrimary,
              borderRadius: BorderRadius.circular(56),
              border: Border.all(color: Colors.white, width: 0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(56),
              child: Image.asset(
                'assets/images/app/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UPDATE',
                style: GoogleFonts.literata(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 0.24,
                ),
              ),
              Text(
                'From Adviser',
                style: GoogleFonts.literata(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.literata(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.surfacePrimary,
              letterSpacing: 0.036,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        'Starting on December 13, 2023, Mercury will begin to "back away", returning to its normal trajectory only in 2024. In December 2023, Mercury will be retrograde for 18 days. This period will end on January 2, 2024. During this time, the planet will first be in the sign of Capricorn, and then in the sign of Aquarius.',
        style: GoogleFonts.literata(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1.75,
        ),
      ),
    );
  }
}

class _HoroscopeToggle extends StatelessWidget {
  const _HoroscopeToggle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // First bar - 75% filled
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.75,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Other bars - empty
          for (int i = 0; i < 4; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

