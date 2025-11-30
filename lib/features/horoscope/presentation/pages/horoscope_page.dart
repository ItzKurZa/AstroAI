import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../data/datasources/astrological_event_remote_data_source.dart';
import '../../domain/entities/astrological_event.dart';

class HoroscopePage extends StatefulWidget {
  static const routeName = '/horoscope';

  const HoroscopePage({super.key});

  @override
  State<HoroscopePage> createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {
  late final AstrologicalEventRemoteDataSource _dataSource;
  List<AstrologicalEvent> _events = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _dataSource = AstrologicalEventRemoteDataSource(FirebaseFirestore.instance);
    _pageController = PageController();
    _loadEvents();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      // Check if user is logged in (will throw if not)
      currentUserId; // This will throw if no user
      
      final events = await _dataSource.fetchCurrentEvents();
      print('📊 HoroscopePage: Loaded ${events.length} events');
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
        // Reset to first page if events changed
        if (_events.isNotEmpty && _pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      }
    } catch (e) {
      print('Error loading astrological events: $e');
      // Only navigate to login if it's an authentication error and page is still mounted
      final errorMessage = e.toString();
      if (mounted && (errorMessage.contains('No user logged in') || 
          errorMessage.contains('currentUserId'))) {
        // Use addPostFrameCallback to avoid navigation during build/pop
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Navigator.of(context).canPop()) {
            // Don't navigate if we can pop (user is navigating back)
            return;
          }
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/auth/login');
          }
        });
        return;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onGoDeeper() {
    if (_events.isEmpty) return;
    
    final currentEvent = _events[_currentIndex];
    
    // Navigate to chat page with event information
    // The AI will automatically receive a message about this event and ask what the user wants to know
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          eventTitle: currentEvent.title,
          eventDescription: currentEvent.description,
          eventImpact: currentEvent.impact,
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Header with back button
              _buildHeader(context),
              // Progress indicator (Stories style)
              _ProgressIndicator(
                currentIndex: _currentIndex,
                totalCount: _events.isEmpty ? 1 : _events.length,
              ),
              const SizedBox(height: 24),
              // Logo and "UPDATE From Adviser" section
              const _LogoSection(),
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _events.isEmpty
                        ? _EmptyState()
                        : Column(
                            children: [
                              // PageView for swiping between events
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: _onPageChanged,
                                  itemCount: _events.length,
                                  itemBuilder: (context, index) {
                                    final event = _events[index];
                                    return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                                            // Event Title
                        Text(
                                              event.title,
                          style: GoogleFonts.literata(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.048,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                                            // Event Date
                            Text(
                                              _formatEventDate(event),
                              style: GoogleFonts.literata(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                                color: AppColors.primary,
                            ),
                                              textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                                            // Astrological Explanation Block
                                            _InfoCard(
                                              description: event.description,
                                              impact: event.impact,
                                            ),
                        const SizedBox(height: 24),
                        // Go Deeper Button
                        _PrimaryButton(
                          label: 'Go Deeper',
                                              onTap: _onGoDeeper,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                                    );
                                  },
                                ),
                              ),
                            ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          // No back button - HoroscopePage is a tab in AppShell, not a separate page
          Text(
            'Horoscope',
            style: GoogleFonts.literata(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatEventDate(AstrologicalEvent event) {
    final startDate = DateFormat('MMM d, yyyy').format(event.startDate);
    if (event.endDate != null) {
      final endDate = DateFormat('MMM d, yyyy').format(event.endDate!);
      return '$startDate - $endDate';
    }
    return startDate;
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.currentIndex,
    required this.totalCount,
  });

  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < totalCount; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: i == currentIndex ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
            if (i < totalCount - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfacePrimary,
              borderRadius: BorderRadius.circular(56),
              border: Border.all(color: Colors.white, width: 0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(56),
              child: Image.asset(
                'assets/images/app/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UPDATE',
                style: GoogleFonts.literata(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 0.24,
                ),
              ),
              Text(
                'From Adviser',
                style: GoogleFonts.literata(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.description,
    required this.impact,
  });

  final String description;
  final String impact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description (Astrological Explanation Block)
          Text(
            description,
            style: GoogleFonts.literata(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.75,
            ),
          ),
          if (impact.isNotEmpty) ...[
            const SizedBox(height: 16),
            // Impact section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      impact,
                      style: GoogleFonts.literata(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.literata(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.surfacePrimary,
              letterSpacing: 0.036,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No astrological events at this time',
              style: GoogleFonts.literata(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for updates',
        style: GoogleFonts.literata(
                fontSize: 14,
          fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
