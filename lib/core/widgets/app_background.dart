import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Wraps content with the brand gradient background used across screens.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.background,
            Color(0xFF0F032F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

