import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_safe_image.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../data/datasources/match_remote_data_source.dart';
import '../../data/repositories/match_repository_impl.dart';
import '../../domain/entities/match_profile.dart';

class MatchPage extends StatefulWidget {
  static const routeName = '/match';

  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late final MatchRepositoryImpl _repository;
  late Future<Map<String, List<MatchProfile>>> _future;

  @override
  void initState() {
    super.initState();
    _repository = MatchRepositoryImpl(
      MatchRemoteDataSource(FirebaseFirestore.instance),
    );
    _future = _repository.fetchMatchSections();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.only(
          top: topPadding + 16,
          left: 20,
          right: 20,
          bottom: 16,
        ),
        child: SafeArea(
          top: false,
          child: FutureBuilder<Map<String, List<MatchProfile>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unable to load match suggestions.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _future = _repository.fetchMatchSections();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final data = snapshot.data!;
              return ListView(
                children: [
                  _MatchSection(
                    title: 'Friendship Partner',
                    subtitle: 'New York, NY',
                    profiles: data['friendship'] ?? const [],
                  ),
                  const SizedBox(height: 24),
                  const _PremiumCard(),
                  const SizedBox(height: 24),
                  _MatchSection(
                    title: 'Romantic Partners',
                    subtitle: 'For your Venus & Mars',
                    profiles: data['romantic'] ?? const [],
                  ),
                  const SizedBox(height: 24),
                  _MatchSection(
                    title: 'New people Today',
                    subtitle: 'Fresh energies nearby',
                    profiles: data['new'] ?? const [],
                  ),
                  const SizedBox(height: 120),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MatchSection extends StatelessWidget {
  const _MatchSection({
    required this.title,
    required this.subtitle,
    required this.profiles,
  });

  final String title;
  final String subtitle;
  final List<MatchProfile> profiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: title,
          subtitle: subtitle,
          action: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(ChatPage.routeName),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
        ...profiles.map(
          (profile) => _MatchCard(profile: profile),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.profile});

  final MatchProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          AppSafeImage(
            imageUrl: profile.avatarUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(profile.pronouns, style: theme.textTheme.labelLarge),
                    const Spacer(),
                    Text(profile.location, style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(profile.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('${profile.sunSign}  •  ${profile.moonSign}',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(profile.bio, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: profile.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.surfacePrimary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(ChatPage.routeName),
                    child: const Text('Chat with Advisor'),
                  ),
                ),
              ],
            ),
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

