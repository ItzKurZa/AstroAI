import 'package:flutter/material.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  static const String routeName = '/splash';

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
      Navigator.of(context).pushNamed('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset('assets/images/app/Logo.png', width: 120, height: 120),
            const SizedBox(height: KSizes.margin8x),
            Text('Advisor', style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
      ),
    );
  }
}
