import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_safe_image.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/astrology_sync_on_login.dart';
import '../../../../core/firebase/firestore_seeder.dart';
import '../widgets/onboarding_primitives.dart';

class OnboardingPage extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _totalSlides = 4;
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    if (mounted) {
    setState(() => _currentPage = index);
    }
  }

  void _goToPage(int index) {
    _controller.animateToPage(
      index.clamp(0, _totalSlides - 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleArrowTap(int slideIndex) {
    if (slideIndex < _totalSlides - 1) {
      _goToPage(slideIndex + 1);
    } else {
      _navigateToSignUp();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushNamed('/auth/login');
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushNamed('/auth/signup-flow');
  }

  void _skipToFriends() {
    _goToPage(_totalSlides - 1);
  }

  Future<void> _handleGoogleSignUp(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign in with Google
      final authService = AuthService.instance;
      final userCredential = await authService.signInWithGoogle();
      
      if (userCredential.user == null) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to sign in with Google'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final userId = userCredential.user!.uid;
      
      // Ensure user content is seeded
      final seeder = FirestoreSeeder(FirebaseFirestore.instance);
      await seeder.ensureUserContent(userId);
      
      // Sync astrology data for the user
      try {
        final syncService = AstrologySyncOnLogin.instance;
        await syncService.syncAfterLogin();
      } catch (e) {
        print('⚠️ Error syncing astrology data: $e');
        // Continue even if sync fails
      }

      // Close loading
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/app');
      }
    } catch (e) {
      print('❌ Google sign-in error: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: PageView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _handlePageChanged,
            children: [
              _StartSlide(
                activeIndex: _currentPage,
                totalSlides: _totalSlides,
                onLogin: _navigateToLogin,
                onSignUp: _navigateToSignUp,
              ),
              _FeatureSlide(
                activeIndex: _currentPage,
                totalSlides: _totalSlides,
                headline:
                    'Astrology personalized\nto the exact time & place you were born',
                hero: const _ZodiacWheel(),
                onArrowTap: () => _handleArrowTap(1),
                onLogin: _navigateToLogin,
                onSkip: _skipToFriends,
                onSignUp: _navigateToSignUp,
                onGoogleSignUp: () => _handleGoogleSignUp(context),
              ),
              _FeatureSlide(
                activeIndex: _currentPage,
                totalSlides: _totalSlides,
                headline: 'Horoscope based\non NASA data',
                hero: const _HoroscopeCard(),
                onArrowTap: () => _handleArrowTap(2),
                onLogin: _navigateToLogin,
                onSkip: _skipToFriends,
                onSignUp: _navigateToSignUp,
                onGoogleSignUp: () => _handleGoogleSignUp(context),
              ),
              _FeatureSlide(
                activeIndex: _currentPage,
                totalSlides: _totalSlides,
                headline: 'Add friends to see\nhow compatible you are',
                hero: const _FriendsPreview(),
                onArrowTap: () => _handleArrowTap(3),
                onLogin: _navigateToLogin,
                onSkip: _skipToFriends,
                onSignUp: _navigateToSignUp,
                onGoogleSignUp: () => _handleGoogleSignUp(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartSlide extends StatelessWidget {
  const _StartSlide({
    required this.activeIndex,
    required this.totalSlides,
    required this.onSignUp,
    required this.onLogin,
  });

  final int activeIndex;
  final int totalSlides;
  final VoidCallback onSignUp;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Text('Advisor', style: OnboardingTypography.title),
          const SizedBox(height: 12),
          _OnboardingIndicator(activeIndex: activeIndex, total: totalSlides),
          const SizedBox(height: 48),
          const LogoBadge(size: 256),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withValues(alpha: 0.3), thickness: 1),
          const SizedBox(height: 32),
          _PrimaryButton(label: 'Sign Up', onTap: onSignUp),
          const SizedBox(height: 16),
          _OutlineButton(label: 'Log In', onTap: onLogin),
          const SizedBox(height: 32),
          const _PolicyLinks(),
        ],
      ),
    );
  }
}

class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({
    required this.activeIndex,
    required this.totalSlides,
    required this.headline,
    required this.hero,
    required this.onArrowTap,
    required this.onLogin,
    required this.onSkip,
    required this.onSignUp,
    this.onGoogleSignUp,
  });

  final int activeIndex;
  final int totalSlides;
  final String headline;
  final Widget hero;
  final VoidCallback onArrowTap;
  final VoidCallback onLogin;
  final VoidCallback onSkip;
  final VoidCallback onSignUp;
  final VoidCallback? onGoogleSignUp;

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _TextButtonLink(label: 'Log In', onTap: onLogin),
              const Spacer(),
              _TextButtonLink(label: 'SKIP', onTap: onSkip, isUppercase: true),
            ],
          ),
          const SizedBox(height: 16),
          Text('Advisor', style: OnboardingTypography.title),
          const SizedBox(height: 12),
          _OnboardingIndicator(activeIndex: activeIndex, total: totalSlides),
          const SizedBox(height: 24),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: OnboardingTypography.subtitle,
          ),
          const SizedBox(height: 32),
          hero,
          const SizedBox(height: 32),
          _ArrowButton(onTap: onArrowTap),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withValues(alpha: 0.3), thickness: 1),
          const SizedBox(height: 24),
          _PrimaryButton(label: 'Enter Your Number', onTap: onSignUp),
          const SizedBox(height: 24),
          const _OrDivider(),
          const SizedBox(height: 24),
          _SocialButton(
            icon: Icons.g_mobiledata,
            label: 'Sign Up with Google',
            onTap: onGoogleSignUp,
          ),
          const SizedBox(height: 16),
          const _SocialButton(icon: Icons.apple, label: 'Sign Up with Apple'),
        ],
      ),
    );
  }
}

class _ZodiacWheel extends StatelessWidget {
  const _ZodiacWheel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OnboardingPalette.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Image.asset(
        'assets/images/app/logo.png',
        height: 220,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _HoroscopeCard extends StatelessWidget {
  const _HoroscopeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E165A), Color(0xFF421C74)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'May 23 - June 7',
            style: OnboardingTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pluto square natal Mercury',
            style: OnboardingTypography.subtitle.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Because of an impulsive decision, there will be a chance opportunity '
            'that affects your natural sense of imagination. There will be an '
            'opportunity that you can use to get what you really want. Resist '
            'cynicism and be courageous.',
            style: OnboardingTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FriendsPreview extends StatelessWidget {
  const _FriendsPreview();

  @override
  Widget build(BuildContext context) {
    const friends = [
      _Friend(
        name: 'Amanda Bynes',
        signs: ['Virgo', 'Leo', 'Libra'],
        avatarUrl: 'assets/images/app/navigation/Profile-pressed.png',
      ),
      _Friend(
        name: 'Natalie Haris',
        signs: ['Libra', 'Sagittarius', 'Cancer'],
        avatarUrl: 'assets/images/app/navigation/Profile-default.png',
      ),
      _Friend(
        name: 'Calvin Maro',
        signs: ['Capricorn', 'Scorpio', 'Aries'],
        avatarUrl: 'assets/images/app/logo.png',
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < friends.length; i++) ...[
            if (i != 0)
              Divider(color: Colors.white.withValues(alpha: 0.18), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _FriendTile(friend: friends[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend});

  final _Friend friend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppAvatar(
              imageUrl: friend.avatarUrl,
              size: 44,
              borderColor: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                friend.name,
                style: OnboardingTypography.subtitle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: friend.signs
              .map(
                (sign) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle_outlined,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(sign, style: OnboardingTypography.body),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Friend {
  const _Friend({
    required this.name,
    required this.signs,
    required this.avatarUrl,
  });

  final String name;
  final List<String> signs;
  final String avatarUrl;
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
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
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: OnboardingPalette.accent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        child: Text(label, style: OnboardingTypography.button),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: OnboardingPalette.accent, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: OnboardingTypography.button.copyWith(
            color: OnboardingPalette.accent,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(label, style: OnboardingTypography.body),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: OnboardingPalette.accent.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: OnboardingTypography.body),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: OnboardingPalette.accent.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}

class _PolicyLinks extends StatelessWidget {
  const _PolicyLinks();

  @override
  Widget build(BuildContext context) {
    final linkStyle = OnboardingTypography.body.copyWith(
      fontSize: 12,
      color: OnboardingPalette.accent,
      letterSpacing: 0.24,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text('Privacy Policy', style: linkStyle),
        ),
        Text(
          '  |  ',
          style: linkStyle.copyWith(fontSize: 16, letterSpacing: 0.32),
        ),
        GestureDetector(
          onTap: () {},
          child: Text('Terms of Service', style: linkStyle),
        ),
      ],
    );
  }
}

class _TextButtonLink extends StatelessWidget {
  const _TextButtonLink({
    required this.label,
    required this.onTap,
    this.isUppercase = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isUppercase;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        isUppercase ? label.toUpperCase() : label,
        style: OnboardingTypography.body.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: isUppercase ? 1 : 0,
        ),
      ),
    );
  }
}

class _OnboardingIndicator extends StatelessWidget {
  const _OnboardingIndicator({required this.activeIndex, required this.total});

  final int activeIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 12,
          width: index == activeIndex ? 28 : 12,
          decoration: BoxDecoration(
            color: index == activeIndex
                ? OnboardingPalette.accent
                : OnboardingPalette.indicatorDim,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _SlideContainer extends StatelessWidget {
  const _SlideContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}

