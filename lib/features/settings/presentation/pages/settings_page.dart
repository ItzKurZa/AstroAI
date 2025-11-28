import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_astrologer/core/constants/app_colors.dart';
import 'package:ai_astrologer/core/utils/current_user.dart';
import 'package:ai_astrologer/core/widgets/app_background.dart';
import 'package:ai_astrologer/core/widgets/app_bottom_nav.dart';
import 'package:ai_astrologer/core/widgets/app_safe_image.dart';
import 'package:ai_astrologer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_astrologer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ai_astrologer/features/profile/domain/entities/user_profile.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ProfileRepositoryImpl _profileRepository;
  late Future<UserProfile> _future;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    _profileRepository =
        ProfileRepositoryImpl(ProfileRemoteDataSource(firestore));
    _future = _profileRepository.fetchProfile(currentUserId);
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
      body: AppBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          bottom: false,
          child: FutureBuilder<UserProfile>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Unable to load settings'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _future =
                                _profileRepository.fetchProfile(currentUserId);
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return _SettingsContent(profile: snapshot.data!);
            },
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        items: navItems,
        currentIndex: 3, // Profile tab is selected
        onChanged: (index) {
          Navigator.of(context).pop(); // Go back to AppShell
        },
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header: Back + Settings
        _buildHeader(context),
        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Bio Table
                _buildBioTable(context),
                // Account Table
                _buildAccountTable(context),
                // Log Out Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _LogOutButton(onTap: () {}),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
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
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: GoogleFonts.literata(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioTable(BuildContext context) {
    return Column(
      children: [
        // Edit row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Edit',
                style: GoogleFonts.literata(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        // Profile Photo
        _SettingsRow(
          title: 'Profile Photo',
          trailing: AppAvatar(
            imageUrl: profile.avatarUrl,
            size: 32,
            borderColor: Colors.white,
          ),
        ),
        // User Name
        _SettingsRow(
          title: 'User Name',
          value: profile.displayName,
        ),
        // Birth Day
        _SettingsRow(
          title: 'Birth Day',
          value: profile.birthDate,
        ),
        // Birth Place
        _SettingsRow(
          title: 'Birth Place',
          value: profile.birthPlace,
        ),
        // Birth Time
        _SettingsRow(
          title: 'Birth Time',
          value: profile.birthTime,
        ),
      ],
    );
  }

  Widget _buildAccountTable(BuildContext context) {
    return Column(
      children: [
        // Account header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 1),
            ),
          ),
          child: Text(
            'Account',
            style: GoogleFonts.literata(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ),
        // Support
        _SettingsRow(
          title: 'Support',
          showArrow: true,
        ),
        // Change Password
        _SettingsRow(
          title: 'Change Password',
          showArrow: true,
        ),
        // Change Number
        _SettingsRow(
          title: 'Change Number',
          showArrow: true,
        ),
        // Restore Purchase
        _SettingsRow(
          title: 'Restore Purchase',
          showArrow: true,
        ),
        // Wipe Account
        _SettingsRow(
          title: 'Wipe Account',
          showArrow: true,
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    this.value,
    this.trailing,
    this.showArrow = false,
  });

  final String title;
  final String? value;
  final Widget? trailing;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.literata(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
          if (trailing != null)
            trailing!
          else if (value != null)
            Text(
              value!,
              style: GoogleFonts.literata(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 0.036,
              ),
            )
          else if (showArrow)
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
        ],
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Center(
          child: Text(
            'Log Out',
            style: GoogleFonts.literata(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.surfacePrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
