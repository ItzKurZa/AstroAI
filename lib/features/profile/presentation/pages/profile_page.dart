import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_astrologer/core/constants/app_colors.dart';
import 'package:ai_astrologer/core/utils/current_user.dart';
import 'package:ai_astrologer/core/widgets/app_background.dart';
import 'package:ai_astrologer/core/widgets/app_safe_image.dart';
import 'package:ai_astrologer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_astrologer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ai_astrologer/features/profile/domain/entities/characteristic.dart';
import 'package:ai_astrologer/features/profile/domain/entities/user_profile.dart';
import 'package:ai_astrologer/features/settings/presentation/pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileRepositoryImpl _repository;
  late Future<_ProfilePayload> _future;

  @override
  void initState() {
    super.initState();
    _repository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(FirebaseFirestore.instance),
    );
    _future = _loadProfile();
  }

  Future<_ProfilePayload> _loadProfile() async {
    final profile = await _repository.fetchProfile(currentUserId);
    final characteristics = await _repository.fetchCharacteristics();
    return _ProfilePayload(profile, characteristics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          child: FutureBuilder<_ProfilePayload>(
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
                      const Text('Unable to load profile'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _future = _loadProfile();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final data = snapshot.data!;
              return _ProfileView(
                profile: data.profile,
                characteristics: data.characteristics,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfilePayload {
  const _ProfilePayload(this.profile, this.characteristics);

  final UserProfile profile;
  final List<Characteristic> characteristics;
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.profile, required this.characteristics});

  final UserProfile profile;
  final List<Characteristic> characteristics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 16),
          const _TabButtons(),
          const SizedBox(height: 16),
          _NatalChartTable(profile: profile),
          const SizedBox(height: 16),
          const _ShareChartButton(),
          const SizedBox(height: 24),
          _CharacteristicsTitle(),
          const SizedBox(height: 16),
          _CharacteristicsSection(characteristics: characteristics),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

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
      child: Column(
        children: [
          // Row 1: Avatar + Name | Settings
          Row(
            children: [
              AppAvatar(
                imageUrl: profile.avatarUrl,
                size: 24,
                borderColor: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                profile.displayName,
                style: GoogleFonts.literata(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(SettingsPage.routeName),
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Date & Time Birth | Signs
          Row(
            children: [
              Text(
                '${profile.birthDate}, ${profile.birthTime}',
                style: GoogleFonts.literata(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _PlanetSign(icon: Icons.wb_sunny_outlined, sign: profile.sunSign),
                  const SizedBox(width: 8),
                  _PlanetSign(icon: Icons.nightlight_outlined, sign: profile.moonSign),
                  const SizedBox(width: 8),
                  _PlanetSign(icon: Icons.person_outline, sign: profile.ascendantSign),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanetSign extends StatelessWidget {
  const _PlanetSign({required this.icon, required this.sign});

  final IconData icon;
  final String sign;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 2),
        Text(
          sign,
          style: GoogleFonts.literata(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TabButtons extends StatefulWidget {
  const _TabButtons();

  @override
  State<_TabButtons> createState() => _TabButtonsState();
}

class _TabButtonsState extends State<_TabButtons> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selected = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selected == 0 ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Chart',
                    style: GoogleFonts.literata(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _selected == 0 ? AppColors.surfacePrimary : AppColors.primary,
                      letterSpacing: 0.036,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selected = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selected == 1 ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Aspects',
                    style: GoogleFonts.literata(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _selected == 1 ? AppColors.surfacePrimary : AppColors.primary,
                      letterSpacing: 0.036,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NatalChartTable extends StatelessWidget {
  const _NatalChartTable({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final chartData = [
      ('Libra', 'Ascendant', '1'),
      ('Sagittarius', 'Pluto', '2'),
      ('Aquarius', 'Uranus\nNeptune', '4'),
      ('Pisces', 'Jupiter', '6'),
      ('Taurus', 'Saturn', '7'),
      ('Cancer', 'Venus\nMars', '9'),
      ('Leo', 'Sun\nMercury', '10'),
      ('Virgo', 'Moon', '2'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _TableCell(text: 'Signs', flex: 3, isHeader: true),
                  _TableCell(text: '', flex: 4, isHeader: true),
                  _TableCell(text: 'Houses', flex: 2, isHeader: true, centered: true),
                ],
              ),
            ),
            // Data rows
            ...chartData.map((row) => Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _TableCell(text: row.$1, flex: 3),
                  _TableCell(text: row.$2, flex: 4, withIcon: true),
                  _TableCell(text: row.$3, flex: 2, centered: true, isHouse: true),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.text,
    required this.flex,
    this.isHeader = false,
    this.centered = false,
    this.withIcon = false,
    this.isHouse = false,
  });

  final String text;
  final int flex;
  final bool isHeader;
  final bool centered;
  final bool withIcon;
  final bool isHouse;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: isHouse
            ? Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: GoogleFonts.literata(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            : withIcon
                ? Row(
                    children: [
                      const Icon(Icons.circle_outlined, color: Colors.white, size: 24),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          text,
                          style: GoogleFonts.literata(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    textAlign: centered ? TextAlign.center : TextAlign.left,
                    style: GoogleFonts.literata(
                      fontSize: isHeader ? 14 : 18,
                      fontWeight: isHeader ? FontWeight.w400 : FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
      ),
    );
  }
}

class _ShareChartButton extends StatelessWidget {
  const _ShareChartButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
          ),
          child: Center(
            child: Text(
              'Share your Chart',
              style: GoogleFonts.literata(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.surfacePrimary,
                letterSpacing: 0.036,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacteristicsTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Characteristics',
        style: GoogleFonts.literata(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.048,
        ),
      ),
    );
  }
}

class _CharacteristicsSection extends StatelessWidget {
  const _CharacteristicsSection({required this.characteristics});

  final List<Characteristic> characteristics;

  @override
  Widget build(BuildContext context) {
    if (characteristics.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: characteristics.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _CharacteristicCard(characteristic: c),
        )).toList(),
      ),
    );
  }
}

class _CharacteristicCard extends StatelessWidget {
  const _CharacteristicCard({required this.characteristic});

  final Characteristic characteristic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  characteristic.title,
                  style: GoogleFonts.literata(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    characteristic.house,
                    style: GoogleFonts.literata(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            characteristic.description,
            style: GoogleFonts.literata(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.75,
            ),
          ),
          // Planet image placeholder
          if (characteristic.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppSafeImage(
                imageUrl: characteristic.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                placeholderAsset: 'assets/images/app/planets/Sun.png',
              ),
            ),
        ],
      ),
    );
  }
}
