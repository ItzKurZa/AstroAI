import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ai_astrologer/core/constants/app_colors.dart';
import 'package:ai_astrologer/core/utils/current_user.dart';
import 'package:ai_astrologer/core/widgets/app_background.dart';
import 'package:ai_astrologer/core/widgets/app_safe_image.dart';
import 'package:ai_astrologer/core/services/user_preferences_service.dart';
import 'package:ai_astrologer/core/services/local_cache_service.dart';
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
  Future<_ProfilePayload>? _future;
  int _reloadKey = 0; // Key to force FutureBuilder rebuild

  @override
  void initState() {
    super.initState();
    _repository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(FirebaseFirestore.instance),
    );
    _reloadProfile();
  }

  void _reloadProfile() {
    setState(() {
      _reloadKey++; // Increment key to force rebuild
      _future = _loadProfile();
    });
  }

  Future<_ProfilePayload> _loadProfile() async {
    try {
      final userId = currentUserId; // This will throw if no user
      
      // Clear local cache to force fresh data
      await LocalCacheService.instance.clearUserProfile(userId);
      
      final profile = await _repository.fetchProfile(userId);
      final characteristics = await _repository.fetchCharacteristics(userId: userId);
      final aspects = await _repository.fetchAspects(userId);
      return _ProfilePayload(profile, characteristics, aspects);
    } catch (e) {
      // If no user, navigate to login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth/login');
      }
      // Return empty payload (will be handled by UI)
      rethrow;
    }
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
            key: ValueKey('profile_future_$_reloadKey'), // Force rebuild when key changes
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unable to load profile',
                        style: GoogleFonts.literata(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          _reloadProfile();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final data = snapshot.data!;
              return _ProfileView(
                key: ValueKey('profile_${data.profile.id}_${data.profile.displayName}_${data.profile.birthDate}'), // Force rebuild when profile changes
                profile: data.profile,
                characteristics: data.characteristics,
                aspects: data.aspects,
                onProfileUpdated: () {
                  // Reload profile when updated from settings
                  _reloadProfile();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfilePayload {
  const _ProfilePayload(this.profile, this.characteristics, this.aspects);

  final UserProfile profile;
  final List<Characteristic> characteristics;
  final List<Map<String, dynamic>> aspects;
}

class _ProfileView extends StatefulWidget {
  const _ProfileView({
    super.key,
    required this.profile,
    required this.characteristics,
    required this.aspects,
    this.onProfileUpdated,
  });

  final UserProfile profile;
  final List<Characteristic> characteristics;
  final List<Map<String, dynamic>> aspects;
  final VoidCallback? onProfileUpdated;

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  int _selectedTab = 0;
  bool _loadingTab = true;

  @override
  void initState() {
    super.initState();
    _loadTabPreference();
  }

  Future<void> _loadTabPreference() async {
    final prefsService = UserPreferencesService.instance;
    final prefs = await prefsService.getPreferences(widget.profile.id);
    final tab = prefs['profileTab'] as String? ?? 'Chart';
    if (mounted) {
      setState(() {
        _selectedTab = tab == 'Chart' ? 0 : 1;
        _loadingTab = false;
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
    final tab = index == 0 ? 'Chart' : 'Aspects';
    final prefsService = UserPreferencesService.instance;
    prefsService.updateProfileTab(widget.profile.id, tab);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingTab) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(
            profile: widget.profile,
            onProfileUpdated: widget.onProfileUpdated,
          ),
          const SizedBox(height: 16),
          _TabButtons(
            userId: widget.profile.id,
            selectedTab: _selectedTab,
            onTabChanged: _onTabChanged,
          ),
          const SizedBox(height: 16),
          if (_selectedTab == 0) ...[
            _NatalChartTable(profile: widget.profile),
            const SizedBox(height: 16),
            _ShareChartButton(userId: widget.profile.id),
            const SizedBox(height: 24),
            _CharacteristicsTitle(),
            const SizedBox(height: 16),
            _CharacteristicsSection(characteristics: widget.characteristics),
          ] else ...[
            _AspectsView(profile: widget.profile, aspects: widget.aspects),
          ],
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    this.onProfileUpdated,
  });

  final UserProfile profile;
  final VoidCallback? onProfileUpdated;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar + Name | Settings
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Avatar + Name (sát bên trái)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppAvatar(
                    imageUrl: profile.avatarUrl,
                    size: 48,
                    borderColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    profile.displayName,
                    style: GoogleFonts.literata(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Right: Settings icon
              GestureDetector(
                onTap: () async {
                  // Navigate to settings and wait for result
                  final result = await Navigator.of(context).pushNamed(SettingsPage.routeName);
                  // If profile was updated, reload the profile data
                  if (result == true) {
                    onProfileUpdated?.call();
                  }
                },
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Date & Time (sát trái) | Signs (sát phải)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Date & Time (sát bên trái)
              Text(
                '${profile.birthDate}, ${profile.birthTime}',
                style: GoogleFonts.literata(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              // Right: Signs (sát bên phải, cách đều nhau)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PlanetSign(icon: Icons.wb_sunny_outlined, sign: profile.sunSign),
                  const SizedBox(width: 16),
                  _PlanetSign(icon: Icons.nightlight_outlined, sign: profile.moonSign),
                  const SizedBox(width: 16),
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
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 4),
        Text(
          sign,
          style: GoogleFonts.literata(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TabButtons extends StatelessWidget {
  const _TabButtons({
    required this.userId,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final String userId;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selectedTab == 0 ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Chart',
                    style: GoogleFonts.literata(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: selectedTab == 0 ? AppColors.surfacePrimary : AppColors.primary,
                      letterSpacing: 0.036,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selectedTab == 1 ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Aspects',
                    style: GoogleFonts.literata(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: selectedTab == 1 ? AppColors.surfacePrimary : AppColors.primary,
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
    const borderColor = Colors.white;
    const borderWidth = 1.0;

    const headerStyle = TextStyle(
      fontFamily: 'Literata',
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 20 / 12,
      color: Colors.white,
    );
    const signStyle = TextStyle(
      fontFamily: 'Literata',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
      color: Colors.white,
    );
    const planetStyle = TextStyle(
      fontFamily: 'Literata',
      fontWeight: FontWeight.w300,
      fontSize: 16,
      height: 24 / 16,
      color: Colors.white,
    );
    const houseStyle = TextStyle(
      fontFamily: 'Literata',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
      color: Colors.white,
    );

    Widget _buildSignCell(String text) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Text(text, style: signStyle),
      );
    }

    Widget _buildPlanetCell(String text, {required _PlanetKind planet}) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PlanetTableIcon(kind: planet),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                text.toUpperCase(),
                style: planetStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildHouseCell(String text) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Center(
          child: Text(text, style: houseStyle),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: borderColor, width: borderWidth),
            verticalInside: BorderSide(color: borderColor, width: borderWidth),
            left: BorderSide.none,
            top: BorderSide.none,
            right: BorderSide.none,
            bottom: BorderSide.none,
          ),
          columnWidths: const {
            0: FixedColumnWidth(120),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(90),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
          // Header row
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Text('Signs', style: headerStyle),
              ),
              const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Houses', style: headerStyle),
                ),
              ),
            ],
          ),

          // Libra / Ascendant / 1
          TableRow(
            children: [
              _buildSignCell('Libra'),
              _buildPlanetCell('Ascendant', planet: _PlanetKind.ac),
              _buildHouseCell('1'),
            ],
          ),

          // Sagittarius / Pluto / 2
          TableRow(
            children: [
              _buildSignCell('Sagittarius'),
              _buildPlanetCell('Pluto', planet: _PlanetKind.pluto),
              _buildHouseCell('2'),
            ],
          ),

          // Aquarius / Uranus + Neptune / 4
          TableRow(
            children: [
              _buildSignCell('Aquarius'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SizedBox(
                  height: 92,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PlanetTableIcon(kind: _PlanetKind.uranus),
                            const SizedBox(width: 10),
                            Text('URANUS', style: planetStyle),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PlanetTableIcon(kind: _PlanetKind.neptune),
                          const SizedBox(width: 10),
                          Text('NEPTUNE', style: planetStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildHouseCell('4'),
            ],
          ),

          // Pisces / Jupiter / 6
          TableRow(
            children: [
              _buildSignCell('Pisces'),
              _buildPlanetCell('Jupiter', planet: _PlanetKind.jupiter),
              _buildHouseCell('6'),
            ],
          ),

          // Taurus / Saturn / 7
          TableRow(
            children: [
              _buildSignCell('Taurus'),
              _buildPlanetCell('Saturn', planet: _PlanetKind.saturn),
              _buildHouseCell('7'),
            ],
          ),

          // Cancer / Venus & Mars / 9
          TableRow(
            children: [
              _buildSignCell('Cancer'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SizedBox(
                  height: 92,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PlanetTableIcon(kind: _PlanetKind.venus),
                            const SizedBox(width: 10),
                            Text('VENUS', style: planetStyle),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PlanetTableIcon(kind: _PlanetKind.mars),
                          const SizedBox(width: 10),
                          Text('MARS', style: planetStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildHouseCell('9'),
            ],
          ),

          // Leo / Sun & Mercury / 10
          TableRow(
            children: [
              _buildSignCell('Leo'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SizedBox(
                  height: 92,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PlanetTableIcon(kind: _PlanetKind.sun),
                            const SizedBox(width: 10),
                            Text('SUN', style: planetStyle),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PlanetTableIcon(kind: _PlanetKind.mercury),
                          const SizedBox(width: 10),
                          Text('MERCURY', style: planetStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildHouseCell('10'),
            ],
          ),

          // Virgo / Moon / 2
          TableRow(
            children: [
              _buildSignCell('Virgo'),
              _buildPlanetCell('Moon', planet: _PlanetKind.moon),
              _buildHouseCell('2'),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

/// Enum để map đúng icon hành tinh theo Figma.
enum _PlanetKind {
  ac,
  pluto,
  uranus,
  neptune,
  jupiter,
  saturn,
  venus,
  mars,
  sun,
  mercury,
  moon,
}

/// Icon hành tinh trong bảng Natal Chart – dùng assets `planet-icons`.
class _PlanetTableIcon extends StatelessWidget {
  const _PlanetTableIcon({required this.kind});

  final _PlanetKind kind;

  String get _assetPath {
    switch (kind) {
      case _PlanetKind.ac:
        // AC not in planets/, use planet-icons for now
        return 'assets/images/app/planet-icons/AC.png';
      case _PlanetKind.pluto:
        return 'assets/images/app/planets/Pluton.png';
      case _PlanetKind.uranus:
        return 'assets/images/app/planets/Uranus.png';
      case _PlanetKind.neptune:
        return 'assets/images/app/planets/Neptune.png';
      case _PlanetKind.jupiter:
        return 'assets/images/app/planets/Jupiter.png';
      case _PlanetKind.saturn:
        return 'assets/images/app/planets/Saturn.png';
      case _PlanetKind.venus:
        return 'assets/images/app/planets/Venus.png';
      case _PlanetKind.mars:
        return 'assets/images/app/planets/Mars.png';
      case _PlanetKind.sun:
        return 'assets/images/app/planets/Sun.png';
      case _PlanetKind.mercury:
        return 'assets/images/app/planets/Mercury.png';
      case _PlanetKind.moon:
        return 'assets/images/app/planets/Moon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}

class _ShareChartButton extends StatelessWidget {
  const _ShareChartButton({required this.userId});

  final String userId;

  Future<void> _handleShare(BuildContext context) async {
    try {
      final repository = ProfileRepositoryImpl(
        ProfileRemoteDataSource(FirebaseFirestore.instance),
      );
      
      final shareData = await repository.shareChart(userId);
      
      if (context.mounted) {
        // Show share dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Share Your Chart'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your chart has been shared!'),
                const SizedBox(height: 8),
                SelectableText(
                  shareData['shareUrl'] as String? ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _handleShare(context),
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

class _AspectsView extends StatelessWidget {
  const _AspectsView({required this.profile, required this.aspects});

  final UserProfile profile;
  final List<Map<String, dynamic>> aspects;

  @override
  Widget build(BuildContext context) {
    // Use aspects from Firebase, or fallback to placeholder if empty
    final displayAspects = aspects.isNotEmpty
        ? aspects
        : [
            {
              'planet1': 'Sun',
              'planet2': 'Moon',
              'aspect': 'Conjunction',
              'orb': '5°'
            },
            {
              'planet1': 'Mercury',
              'planet2': 'Venus',
              'aspect': 'Trine',
              'orb': '3°'
            },
            {
              'planet1': 'Mars',
              'planet2': 'Jupiter',
              'aspect': 'Square',
              'orb': '2°'
            },
            {
              'planet1': 'Saturn',
              'planet2': 'Uranus',
              'aspect': 'Opposition',
              'orb': '4°'
            },
            {
              'planet1': 'Neptune',
              'planet2': 'Pluto',
              'aspect': 'Sextile',
              'orb': '1°'
            },
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planetary Aspects',
            style: GoogleFonts.literata(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 32 / 20,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Planets',
                          style: GoogleFonts.literata(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Aspect',
                          style: GoogleFonts.literata(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Orb',
                          style: GoogleFonts.literata(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rows
                if (displayAspects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No aspects data available',
                        style: GoogleFonts.literata(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  )
                else
                  ...displayAspects.map((aspect) {
                    final planet1 = aspect['planet1'] as String? ?? '';
                    final planet2 = aspect['planet2'] as String? ?? '';
                    final aspectName = aspect['aspect'] as String? ?? aspect['aspectName'] as String? ?? '';
                    final orb = aspect['orb'] as String? ?? aspect['orbDegrees']?.toString() ?? '0°';
                    
                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '$planet1 - $planet2',
                              style: GoogleFonts.literata(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              aspectName,
                              style: GoogleFonts.literata(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              orb,
                              style: GoogleFonts.literata(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _CharacteristicsTitle(),
          const SizedBox(height: 16),
          // Characteristics should be shown in both tabs
          // But for now, let's keep it only in Chart tab as per original design
        ],
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
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 32 / 20,
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
          padding: const EdgeInsets.only(bottom: 32),
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
      margin: const EdgeInsets.only(bottom: 35),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card chính với border trắng, nền trong suốt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
            decoration: BoxDecoration(
              color: const Color(0xFF14093C).withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 1),
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      characteristic.title,
                      style: GoogleFonts.literata(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      characteristic.house,
                      style: GoogleFonts.literata(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                characteristic.description,
                style: GoogleFonts.literata(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        // Hình hành tinh ở chính giữa cạnh dưới, lớn hơn và đẹp hơn
        if (characteristic.imageUrl.isNotEmpty)
          Positioned(
            bottom: -48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: AppSafeImage(
                  imageUrl: characteristic.imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(55),
                  placeholderAsset: 'assets/images/app/planets/Sun.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
