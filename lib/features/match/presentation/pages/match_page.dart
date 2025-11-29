import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_safe_image.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class MatchPage extends StatefulWidget {
  static const routeName = '/astroai';

  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late final ProfileRepositoryImpl _profileRepository;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(FirebaseFirestore.instance),
    );
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = currentUserId; // This will throw if no user
      final profile = await _profileRepository.fetchProfile(userId);
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // If no user, navigate to login
      if (mounted && e.toString().contains('No user logged in')) {
        Navigator.of(context).pushReplacementNamed('/auth/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-navigate to chat when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(ChatPage.routeName);
    });
    
    // Show loading while navigating
    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Opening AstroAI...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({this.userProfile});

  final UserProfile? userProfile;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Avatar + Name (sát bên trái)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAvatar(
                imageUrl: userProfile?.avatarUrl ?? '',
                size: 48,
                borderColor: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                userProfile?.displayName ?? 'User',
                style: GoogleFonts.literata(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Right: Notification icon (sát bên phải)
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(NotificationsPage.routeName);
            },
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorChatCard extends StatelessWidget {
  const _AdvisorChatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfacePrimary.withOpacity(0.1),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () {
          // Navigate to chat with advisor (no targetUserId = chat with advisor)
          Navigator.of(context).pushNamed(ChatPage.routeName);
        },
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Advisor icon/avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFBCA8F4), Color(0xFF836FF2)],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat with Advisor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ask me anything about astrology, your birth chart, or daily horoscope',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFBCA8F4), Color(0xFF836FF2)],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Advisor',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.surfacePrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try Premium',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.surfacePrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '-30% DISCOUNT',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.surfacePrimary),
          ),
        ],
      ),
    );
  }
}

