import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/firebase/firestore_seeder.dart';
import 'core/firebase/sample_data.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/horoscope/presentation/pages/horoscope_page.dart';
import 'features/match/presentation/pages/match_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'core/firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  final currentUid = FirebaseAuth.instance.currentUser?.uid ?? demoUserId;
  final seeder = FirestoreSeeder(FirebaseFirestore.instance);
  await seeder.ensureInitialContent(currentUid);
  runApp(const AdvisorApp());
}

class AdvisorApp extends StatelessWidget {
  const AdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advisor',
      theme: AppTheme.light,
      initialRoute: SplashPage.routeName,
      routes: {
        SplashPage.routeName: (_) => const SplashPage(),
        OnboardingPage.routeName: (_) => const OnboardingPage(),
        LoginPage.routeName: (_) => const LoginPage(),
        SignUpFlowPage.routeName: (_) => const SignUpFlowPage(),
        AppShell.routeName: (_) => const AppShell(),
        SettingsPage.routeName: (_) => const SettingsPage(),
        NotificationsPage.routeName: (_) => const NotificationsPage(),
        ChatPage.routeName: (_) => const ChatPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/app') {
          return MaterialPageRoute(builder: (_) => const AppShell());
        }
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      },
    );
  }
}

class AppShell extends StatefulWidget {
  static const routeName = '/app';

  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    MatchPage(),
    HoroscopePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = [
      AppBottomNavItem(
        label: 'Home',
        defaultIcon: 'assets/images/app/navigation/Home.png',
        selectedIcon: 'assets/images/app/navigation/Home-pressed.png',
      ),
      AppBottomNavItem(
        label: 'Match',
        defaultIcon: 'assets/images/app/navigation/Chat-default.png',
        selectedIcon: 'assets/images/app/navigation/Chat-pressed.png',
      ),
      AppBottomNavItem(
        label: 'Horoscope',
        defaultIcon: 'assets/images/app/navigation/Horoscope-default.png',
        selectedIcon: 'assets/images/app/navigation/Horoscope-pressed.png',
      ),
      AppBottomNavItem(
        label: 'Profile',
        defaultIcon: 'assets/images/app/navigation/Profile-default.png',
        selectedIcon: 'assets/images/app/navigation/Profile-pressed.png',
      ),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        items: navItems,
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
