import 'package:flutter/material.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../onboarding/presentation/widgets/onboarding_primitives.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/splash';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text('Advisor', style: OnboardingTypography.title),
              const Spacer(),
              const LogoBadge(size: 256),
              const Spacer(),
              const HomeIndicatorBar(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

