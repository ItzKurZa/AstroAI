import 'package:ai_astrologer/auth/presentation/login_page.dart';
import 'package:ai_astrologer/auth/presentation/signup_page.dart';
import 'package:ai_astrologer/home/presentation/home_page.dart';
import 'package:ai_astrologer/horoscope/presentation/horoscope_page.dart';
import 'package:ai_astrologer/chat/presentation/chat_page.dart';
import 'package:ai_astrologer/profile/presentation/profile_page.dart';
import 'package:ai_astrologer/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase/firebase_options.dart';
import 'package:ai_astrologer/splash/presentation/splash_page.dart';
import 'package:ai_astrologer/onboarding/presentation/onboarding_page.dart';
import 'core/widgets/navigation_bar.dart';

void main() async {
  // Function để kết nối Firebase (tạm thời tắt do chưa kết nối)
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Astrologer',
      initialRoute: AppShell.routeName,
      routes: {
        SplashPage.routeName: (context) => const SplashPage(),
        OnboardingPage.routeName: (context) => const OnboardingPage(),
        LoginPage.routeName: (context) => const LoginPage(),
        SignupPage.routeName: (context) => const SignupPage(),
        AppShell.routeName: (context) => const AppShell(),
        SettingsPage.routeName: (context) => const SettingsPage(),
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
    );
  }
}

class AppShell extends StatefulWidget {
  static const String routeName = '/app';

  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ChatPage(),
    const HoroscopePage(),
    const ProfilePage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
