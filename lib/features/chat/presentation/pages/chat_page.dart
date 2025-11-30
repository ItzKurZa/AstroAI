import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/chat_consultation_service.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  // Optional: chat about a specific user (for compatibility analysis)
  final String? targetUserId;
  final String? targetUserName;
  final String? targetSunSign;
  final String? targetMoonSign;
  final String? targetAscendantSign;

  // Optional: auto-send message about an astrological event
  final String? eventTitle;
  final String? eventDescription;
  final String? eventImpact;

  const ChatPage({
    super.key,
    this.targetUserId,
    this.targetUserName,
    this.targetSunSign,
    this.targetMoonSign,
    this.targetAscendantSign,
    this.eventTitle,
    this.eventDescription,
    this.eventImpact,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatRepositoryImpl _repository;
  late final ChatConsultationService _consultationService;
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _repository = ChatRepositoryImpl(
      ChatRemoteDataSource(FirebaseFirestore.instance),
    );
    _consultationService = ChatConsultationService();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Note: Astrology sync is handled by DataPreloaderService after login
    // No need to sync here to avoid duplicate syncs

    try {
      final userId = currentUserId; // This will throw if no user
      // Check if there are existing messages
      final messages = await _repository.watchMessages(userId).first;
      if (messages.isEmpty) {
        // Start a new session
        try {
          final userData = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          final data = userData.data() ?? {};
          
          // If chatting about a specific user, start compatibility session
          if (widget.targetUserId != null) {
            await _consultationService.startCompatibilitySession(
              userId: userId,
              userName: data['displayName'] ?? 'Seeker',
              sunSign: data['sunSign'] ?? 'Unknown',
              moonSign: data['moonSign'] ?? 'Unknown',
              ascendantSign: data['ascendantSign'] ?? 'Unknown',
              targetUserId: widget.targetUserId!,
              targetUserName: widget.targetUserName ?? 'This person',
              targetSunSign: widget.targetSunSign ?? 'Unknown',
              targetMoonSign: widget.targetMoonSign ?? 'Unknown',
              targetAscendantSign: widget.targetAscendantSign ?? 'Unknown',
            );
          } else {
            // Regular chat session
            await _consultationService.startSession(
              userId: userId,
              userName: data['displayName'] ?? 'Seeker',
              sunSign: data['sunSign'] ?? 'Unknown',
              moonSign: data['moonSign'] ?? 'Unknown',
              ascendantSign: data['ascendantSign'] ?? 'Unknown',
            );
          }
        } catch (e) {
          print('Error initializing chat: $e');
        }
      }
      setState(() => _isInitialized = true);
      
      // If there's an event to discuss, auto-send a message about it
      if (widget.eventTitle != null && widget.eventTitle!.isNotEmpty) {
        // Wait a bit for the UI to render, then send the message
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _sendEventMessage();
        }
      }
    } catch (e) {
      // If no user, navigate to login
      print('Error: No user logged in: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth/login');
      }
    }
  }

  Future<void> _sendEventMessage() async {
    if (widget.eventTitle == null || widget.eventTitle!.isEmpty) return;
    
    try {
      final userId = currentUserId;
      
      // Display message (short, like a link/title) - saved to Firestore for UI
      final displayMessage = 'I want to learn more about ${widget.eventTitle}';
      
      // Full message (with all context) - sent to AI in background
      String fullMessage = 'I want to learn more about ${widget.eventTitle}';
      
      // Add description and impact as context for AI to provide detailed response
      if (widget.eventDescription != null && widget.eventDescription!.isNotEmpty) {
        fullMessage += '\n\nHere is the description: ${widget.eventDescription}';
      }
      if (widget.eventImpact != null && widget.eventImpact!.isNotEmpty) {
        fullMessage += '\n\nHere is the impact: ${widget.eventImpact}';
      }
      
      fullMessage += '\n\nPlease provide a detailed explanation about this astrological event and how it might affect me personally based on my birth chart.';
      
      setState(() => _isLoading = true);
      
      // Save short message to Firestore (for UI display)
      await _repository.sendMessage(userId, displayMessage);
      
      // Send full message to AI (in background, not saved to Firestore as user message)
      // ChatConsultationService will save the AI response
      await _consultationService.sendMessage(userId, fullMessage, saveUserMessage: false);
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error sending event message: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;
    
    _controller.clear();
    setState(() => _isLoading = true);
    
    try {
      final userId = currentUserId; // This will throw if no user
      
      // Get AI response (ChatConsultationService will save both user message and AI response)
      // Use compatibility message if chatting about a specific user
      if (widget.targetUserId != null) {
        await _consultationService.sendCompatibilityMessage(
          userId,
          widget.targetUserId!,
          text,
        );
      } else {
        await _consultationService.sendMessage(userId, text);
      }
    } catch (e) {
      print('Error sending message: $e');
      // Check if error is due to no user logged in
      if (e.toString().contains('No user logged in')) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth/login');
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get response. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.only(
          top: topPadding + 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _ChatHeader(
                targetUserId: widget.targetUserId,
                targetUserName: widget.targetUserName,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: !_isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : Builder(
                        builder: (context) {
                          try {
                            final userId = currentUserId;
                            return StreamBuilder<List<ChatMessage>>(
                              stream: _repository.watchMessages(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          size: 48,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Ask the stars anything...',
                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Love, career, health, or daily guidance',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                        ),
                      );
                    }
                    return ListView.separated(
                      reverse: true,
                      padding: EdgeInsets.zero,
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                                    final message = messages[messages.length - 1 - index];
                        return _ChatCard(message: message);
                      },
                    );
                  },
                            );
                          } catch (e) {
                            // If no user, show error and navigate to login
                            if (mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(context).pushReplacementNamed('/auth/login');
                              });
                            }
                            return const Center(
                              child: Text('Please login to continue'),
                            );
                          }
                        },
                      ),
              ),
              // Loading indicator when AI is responding
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Advisor is reading the stars...'),
                    ],
                ),
              ),
              const SizedBox(height: 12),
              _InputBar(
                controller: _controller,
                onSend: _handleSend,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      // Show bottom nav ONLY when ChatPage is pushed from HoroscopePage with event info
      // When ChatPage is a tab in AppShell (no eventTitle), AppShell already has bottom nav
      // Using eventTitle as indicator: if present, ChatPage was pushed from HoroscopePage
      bottomNavigationBar: widget.eventTitle != null && widget.eventTitle!.isNotEmpty
          ? _buildBottomNav(context)
          : null,
    );
  }

  Widget? _buildBottomNav(BuildContext context) {
    final navItems = [
      AppBottomNavItem(
        label: 'Home',
        defaultIcon: 'assets/images/app/navigation/Home.png',
        selectedIcon: 'assets/images/app/navigation/Home-pressed.png',
      ),
      AppBottomNavItem(
        label: 'AstroAI',
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

    return AppBottomNav(
      items: navItems,
      currentIndex: 1, // AstroAI is at index 1
      onChanged: (index) {
        if (index == 1) return; // Already on AstroAI
        Navigator.of(context).pop(); // Go back to previous page (HoroscopePage)
        // AppShell will handle tab switching when user returns
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    this.targetUserId,
    this.targetUserName,
  });

  final String? targetUserId;
  final String? targetUserName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B3CFF), Color(0xFFB44CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            targetUserId != null 
                ? 'Chat about ${targetUserName ?? "this person"}'
                : 'Advisor Match Chat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.surfacePrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            targetUserId != null
                ? 'Ask me about compatibility, personality, or relationship insights.'
                : 'Swipe cards to see how planets respond today. Built from the Match screen visuals you approved.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.surfacePrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF4C2A90), Color(0xFF291551)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF321C61), Color(0xFF1A0F2F)],
                ),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  message.isUser ? 'You' : 'Advisor AI',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  TimeOfDay.fromDateTime(message.createdAt).format(context),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(message.text, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: enabled ? 'Ask Advisor anything…' : 'Please wait...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

