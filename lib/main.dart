import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/firebase/firestore_seeder.dart';
import 'core/services/gemini_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/horoscope/presentation/pages/horoscope_page.dart';
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
  // Initialize Gemini Service
  try {
    GeminiService.instance.initialize();
    print('✅ Gemini Service initialized successfully');
  } catch (e) {
    print('⚠️ Failed to initialize Gemini Service: $e');
  }

  // Seed general content (not user-specific)
  final seeder = FirestoreSeeder(FirebaseFirestore.instance);
  await seeder.ensureGeneralContent();
  
  // Note: User must login/signup to access the app
  // No anonymous sign-in - all users must register with real data
  
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

  // Pages corresponding to navigation items: Home, AstroAI (Chat), Horoscope, Profile
  // Cache pages to prevent rebuilding
  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    // Initialize pages once in initState to prevent rebuilds
    _pages = [
      HomePage(),
      ChatPage(), // Changed from MatchPage to ChatPage for AstroAI
      HoroscopePage(),
      ProfilePage(),
    ];
    
    // Check authentication when AppShell is created
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // No user logged in, navigate to login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      AppBottomNavItem(
        label: 'Home',
        defaultIcon: 'assets/images/app/navigation/Home.png',
        selectedIcon: 'assets/images/app/navigation/Home-pressed.png',
      ),
      AppBottomNavItem(
        label: 'AstroAI',
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

    return PopScope(
      canPop: false, // Prevent exiting app from main tabs
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Show confirmation dialog before exiting
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App?'),
              content: const Text('Do you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (shouldExit == true && mounted) {
            // Exit app (this will work on mobile, on web it will just close the dialog)
            // For web, we can't actually exit, so just allow the pop
          }
        }
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: AppBottomNav(
          items: navItems,
          currentIndex: _currentIndex,
          onChanged: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
