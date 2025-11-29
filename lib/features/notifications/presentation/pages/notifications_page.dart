import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:ai_astrologer/core/constants/app_colors.dart';
import 'package:ai_astrologer/core/utils/current_user.dart';
import 'package:ai_astrologer/core/widgets/app_background.dart';
import 'package:ai_astrologer/features/settings/data/datasources/notification_remote_data_source.dart';
import 'package:ai_astrologer/features/settings/data/repositories/notification_repository_impl.dart';
import 'package:ai_astrologer/features/settings/domain/entities/notification_prefs.dart';

class NotificationsPage extends StatefulWidget {
  static const routeName = '/notifications';

  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationRepositoryImpl _repository;
  NotificationPrefs? _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = NotificationRepositoryImpl(
      NotificationRemoteDataSource(FirebaseFirestore.instance),
    );
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await _repository.fetchPrefs(currentUserId);
    setState(() {
      _prefs = prefs;
      _loading = false;
    });
  }

  Future<void> _updatePrefs(NotificationPrefs prefs) async {
    setState(() => _prefs = prefs);
    await _repository.updatePrefs(currentUserId, prefs);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _prefs == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final prefs = _prefs!;
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('SKIP'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Accept push Notification',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Find out when friends add you and know exactly what you should expect each day',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/app/icons/Notification With News.png',
                    height: 220,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showCustomizationSheet(prefs),
                  child: const Text('Turn on Notification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomizationSheet(NotificationPrefs prefs) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        var working = prefs;
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You can customize which kinds of notifications you receive',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                _ModalToggle(
                  label: 'Daily Digests',
                  value: working.dailyDigest,
                  onChanged: (value) => setState(() {
                    working = working.copyWith(dailyDigest: value);
                  }),
                ),
                _ModalToggle(
                  label: 'Someone added you',
                  value: working.friendAdded,
                  onChanged: (value) => setState(() {
                    working = working.copyWith(friendAdded: value);
                  }),
                ),
                _ModalToggle(
                  label: 'Someone added you back',
                  value: working.friendAccepted,
                  onChanged: (value) => setState(() {
                    working = working.copyWith(friendAccepted: value);
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('No Thanks'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _updatePrefs(working);
                        },
                        child: const Text('Turn On'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _ModalToggle extends StatelessWidget {
  const _ModalToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

