import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_safe_image.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/daily_section.dart';
import '../../domain/entities/home_content.dart';
import '../../domain/entities/planet_entry.dart';
import '../../domain/entities/tip_of_day.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeRepositoryImpl _repository;
  late Future<HomeContent> _contentFuture;

  @override
  void initState() {
    super.initState();
    _repository = HomeRepositoryImpl(
      HomeRemoteDataSource(FirebaseFirestore.instance),
    );
    _contentFuture = _repository.fetchHomeContent(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          bottom: false,
          child: FutureBuilder<HomeContent>(
            future: _contentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unable to load your dashboard.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _contentFuture =
                                _repository.fetchHomeContent(currentUserId);
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return _HomeContentView(content: snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}

class _HomeContentView extends StatelessWidget {
  const _HomeContentView({required this.content});

  final HomeContent content;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _UserHeader(user: content.user),
              const SizedBox(height: 8),
              const _WeekDatePicker(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: 16),
              _PlanetsTodaySection(planets: content.planets),
              const SizedBox(height: 24),
              const _PremiumCard(),
              const SizedBox(height: 32),
              _YouTodaySection(sections: content.sections),
              const SizedBox(height: 24),
              _TipCard(tip: content.tip),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final UserProfile user;

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
        children: [
          // Avatar + Name
          AppAvatar(
            imageUrl: user.avatarUrl,
            size: 24,
            borderColor: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            user.displayName,
            style: const TextStyle(
              fontFamily: 'Literata',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Planets & Signs
          Row(
            children: [
              _PlanetSign(icon: Icons.wb_sunny_outlined, sign: user.sunSign),
              const SizedBox(width: 8),
              _PlanetSign(icon: Icons.nightlight_outlined, sign: user.moonSign),
              const SizedBox(width: 8),
              _PlanetSign(icon: Icons.person_outline, sign: user.ascendantSign),
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
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 2),
        Text(
          sign,
          style: const TextStyle(
            fontFamily: 'Literata',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _WeekDatePicker extends StatefulWidget {
  const _WeekDatePicker();

  @override
  State<_WeekDatePicker> createState() => _WeekDatePickerState();
}

class _WeekDatePickerState extends State<_WeekDatePicker> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = _getWeekDays(_selectedDate);
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  String _getDayName(int weekday) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfacePrimary,
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Day names row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((day) {
              final isSelected = day.day == _selectedDate.day &&
                  day.month == _selectedDate.month;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      _getDayName(day.weekday),
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.surfacePrimary
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // Day numbers row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((day) {
              final isSelected = day.day == _selectedDate.day &&
                  day.month == _selectedDate.month;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: isSelected
                            ? AppColors.surfacePrimary
                            : Colors.white,
                        letterSpacing: 0.036,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PlanetSignatureRow extends StatelessWidget {
  const _PlanetSignatureRow({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planets = [
      ('Sun', user.sunSign),
      ('Moon', user.moonSign),
      ('AC', user.ascendantSign),
    ];
    return Row(
      children: planets
          .map(
            (entry) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(entry.$1, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      entry.$2,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlanetsTodaySection extends StatelessWidget {
  const _PlanetsTodaySection({required this.planets});

  final List<PlanetEntry> planets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Planets Today'),
        SizedBox(
          height: 365,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 8),
            itemCount: planets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _PlanetCard(
              data: planets[index],
              isHighlighted: index == 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanetCard extends StatelessWidget {
  const _PlanetCard({required this.data, this.isHighlighted = false});

  final PlanetEntry data;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 361,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        gradient: isHighlighted
            ? const LinearGradient(
                colors: [
                  Color(0xFF412C8E),
                  Color(0xFF6D3E9E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFF2A1A4D),
                  Color(0xFF1B1036),
                ],
              ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: AppSafeImage(
                imageUrl: data.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholderAsset: 'assets/images/app/planets/Sun.png',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(data.zodiac, style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.degrees,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              data.description,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}

class _YouTodaySection extends StatelessWidget {
  const _YouTodaySection({required this.sections});

  final List<DailySection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'You Today'),
        ...sections.map(
          (section) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _YouTodayCard(section: section),
          ),
        ),
      ],
    );
  }
}

class _YouTodayCard extends StatelessWidget {
  const _YouTodayCard({required this.section});

  final DailySection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(section.title.toUpperCase(),
                  style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 16),
          Text(section.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: section.planets
                .map(
                  (planet) => Chip(
                    label: Text('${planet.planet} → ${planet.zodiac}'),
                    backgroundColor: AppColors.surfacePrimary,
                    labelStyle: theme.textTheme.bodyMedium,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final TipOfDay tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From Advisor', style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          Text(
            tip.text,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF422D8E), Color(0xFFBCA8F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ADVISOR',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.surfacePrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try Premium',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.surfacePrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '-30% DISCOUNT',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.surfacePrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

