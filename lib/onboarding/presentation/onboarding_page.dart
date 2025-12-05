import 'package:flutter/material.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

class _OnboardingData {
  final String image;
  final String title;
  const _OnboardingData({required this.image, required this.title});
}

class OnboardingPage extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'assets/images/app/onboarding1.png',
      title: 'Astrology personalized\nto the exact time & place you were born',
    ),
    _OnboardingData(
      image: 'assets/images/app/onboarding2.png',
      title: 'Horoscope based\non NASA data',
    ),
    _OnboardingData(
      image: 'assets/images/app/onboarding3.png',
      title: 'Add friends to see\nhow compatible you are',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KSizes.margin8x,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(data.image, width: 220, height: 220),
                        const SizedBox(height: KSizes.margin8x),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 24,
                  ),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFFB9A4F4)
                        : const Color(0xFF3B2B6B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KSizes.margin8x,
                vertical: KSizes.margin4x,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9A4F4),
                  minimumSize: const Size.fromHeight(KSizes.buttonHeight),
                ),
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
