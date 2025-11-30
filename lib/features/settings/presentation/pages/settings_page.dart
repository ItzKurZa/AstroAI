import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_astrologer/core/constants/app_colors.dart';
import 'package:ai_astrologer/core/utils/current_user.dart';
import 'package:ai_astrologer/core/widgets/app_background.dart';
import 'package:ai_astrologer/core/widgets/app_safe_image.dart';
import 'package:ai_astrologer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_astrologer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ai_astrologer/features/profile/domain/entities/user_profile.dart';
import 'package:ai_astrologer/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:ai_astrologer/features/settings/data/repositories/settings_repository_impl.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ProfileRepositoryImpl _profileRepository;
  late final SettingsRepositoryImpl _settingsRepository;
  late Future<UserProfile> _future;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    _profileRepository =
        ProfileRepositoryImpl(ProfileRemoteDataSource(firestore));
    _settingsRepository = SettingsRepositoryImpl(
      SettingsRemoteDataSource(firestore, auth),
    );
    _future = _profileRepository.fetchProfile(currentUserId);
  }

  void _reloadProfile() {
    setState(() {
      _future = _profileRepository.fetchProfile(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Allow normal pop behavior - Settings is pushed on top of Profile
      onPopInvoked: (didPop) {
        // Settings page is pushed from Profile page, so pop will return to Profile
        // No special handling needed
      },
      child: Scaffold(
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
                          onPressed: _reloadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
                return _SettingsContent(
                  profile: snapshot.data!,
                  profileRepository: _profileRepository,
                  settingsRepository: _settingsRepository,
                  onProfileUpdated: _reloadProfile,
                );
            },
          ),
        ),
      ),
        // Remove bottom navigation bar - Settings is a modal page, not a main tab
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.profile,
    required this.profileRepository,
    required this.settingsRepository,
    required this.onProfileUpdated,
  });

  final UserProfile profile;
  final ProfileRepositoryImpl profileRepository;
  final SettingsRepositoryImpl settingsRepository;
  final VoidCallback onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header: Back + Settings + Edit
        _buildHeader(context),
        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Profile Information Section
                _buildProfileSection(context),
                const SizedBox(height: 24),
                // Account Section
                _buildAccountSection(context),
                const SizedBox(height: 24),
                // Log Out Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _LogOutButton(
                    onTap: () => _handleLogOut(context),
                  ),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Simply pop back to Profile page
              Navigator.of(context).pop(true); // Return true to indicate profile updated
            },
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
            'Settings',
            style: GoogleFonts.literata(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          ),
          GestureDetector(
            onTap: () => _showEditProfileDialog(context),
            child: Text(
                'Edit',
                style: GoogleFonts.literata(
                  fontSize: 18,
                fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
              ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
        // Profile Photo
        _SettingsRow(
          title: 'Profile Photo',
          trailing: AppAvatar(
            imageUrl: profile.avatarUrl,
              size: 48,
              borderColor: AppColors.primary,
          ),
        ),
          const SizedBox(height: 16),
        // User Name
        _SettingsRow(
          title: 'User Name',
          value: profile.displayName,
        ),
          const SizedBox(height: 16),
        // Birth Day
        _SettingsRow(
          title: 'Birth Day',
          value: profile.birthDate,
        ),
          const SizedBox(height: 16),
        // Birth Place
        _SettingsRow(
          title: 'Birth Place',
          value: profile.birthPlace,
        ),
          const SizedBox(height: 16),
        // Birth Time
        _SettingsRow(
          title: 'Birth Time',
          value: profile.birthTime,
        ),
      ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'Account',
            style: GoogleFonts.literata(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 16),
        // Support
          _AccountRow(
          title: 'Support',
            onTap: () => _showSupportDialog(context),
        ),
          const SizedBox(height: 12),
        // Change Password
          _AccountRow(
          title: 'Change Password',
            onTap: () => _showChangePasswordDialog(context),
        ),
          const SizedBox(height: 12),
        // Change Number
          _AccountRow(
          title: 'Change Number',
            onTap: () => _showChangeNumberDialog(context),
        ),
          const SizedBox(height: 12),
        // Wipe Account
          _AccountRow(
          title: 'Wipe Account',
            onTap: () => _showWipeAccountDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: profile.displayName);
    final birthDateController = TextEditingController(text: profile.birthDate);
    final birthTimeController = TextEditingController(text: profile.birthTime);
    final birthPlaceController = TextEditingController(text: profile.birthPlace);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceSecondary,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.literata(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: birthDateController,
                decoration: InputDecoration(
                  labelText: 'Birth Day (DD/MM/YYYY)',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: birthTimeController,
                decoration: InputDecoration(
                  labelText: 'Birth Time (HH:mm)',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: birthPlaceController,
                decoration: InputDecoration(
                  labelText: 'Birth Place',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
        ),
      ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.literata(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await profileRepository.updateProfile(
                  profile.id,
                  displayName: nameController.text.trim(),
                  birthDate: birthDateController.text.trim(),
                  birthTime: birthTimeController.text.trim(),
                  birthPlace: birthPlaceController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  onProfileUpdated();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Save', style: GoogleFonts.literata(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceSecondary,
        title: Text(
          'Change Password',
          style: GoogleFonts.literata(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.literata(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              try {
                await settingsRepository.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Change', style: GoogleFonts.literata(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showChangeNumberDialog(BuildContext context) {
    final newPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceSecondary,
        title: Text(
          'Change Phone Number',
          style: GoogleFonts.literata(color: Colors.white),
        ),
        content: TextField(
          controller: newPhoneController,
          decoration: InputDecoration(
            labelText: 'New Phone Number',
            labelStyle: GoogleFonts.literata(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          style: GoogleFonts.literata(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.literata(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await settingsRepository.changePhoneNumber(newPhoneController.text.trim());
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Phone number updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  onProfileUpdated();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Change', style: GoogleFonts.literata(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceSecondary,
        title: Text(
          'Contact Support',
          style: GoogleFonts.literata(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: GoogleFonts.literata(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.literata(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.literata(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (subjectController.text.trim().isEmpty || messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              try {
                await settingsRepository.contactSupport(
                  subject: subjectController.text.trim(),
                  message: messageController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Support request sent successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Send', style: GoogleFonts.literata(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }


  void _showWipeAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceSecondary,
        title: Text(
          'Wipe Account',
          style: GoogleFonts.literata(color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
          style: GoogleFonts.literata(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.literata(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await settingsRepository.wipeAccount();
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/auth/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: GoogleFonts.literata(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleLogOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceSecondary,
        title: Text(
          'Log Out',
          style: GoogleFonts.literata(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.literata(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.literata(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await settingsRepository.logOut();
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/auth/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Log Out', style: GoogleFonts.literata(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    this.value,
    this.trailing,
  });

  final String title;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.literata(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (value != null)
          Flexible(
            child: Text(
              value!,
              style: GoogleFonts.literata(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                letterSpacing: 0.036,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.literata(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: isDestructive ? Colors.red : Colors.white,
              letterSpacing: 0.1,
            ),
          ),
          Icon(
              Icons.arrow_forward_ios,
            color: isDestructive ? Colors.red : Colors.white70,
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
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Log Out',
            style: GoogleFonts.literata(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.surfacePrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
