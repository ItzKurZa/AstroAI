import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatRepositoryImpl _repository;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = ChatRepositoryImpl(
      ChatRemoteDataSource(FirebaseFirestore.instance),
    );
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _repository.sendMessage(currentUserId, text);
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
              const _ChatHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _repository.watchMessages(currentUserId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Say hi to start your astral chat.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    return ListView.separated(
                      reverse: true,
                      padding: EdgeInsets.zero,
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final message =
                            messages[messages.length - 1 - index];
                        return _ChatCard(message: message);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _InputBar(
                controller: _controller,
                onSend: _handleSend,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

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
            'Advisor Match Chat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.surfacePrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe cards to see how planets respond today. Built from the Match screen visuals you approved.',
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
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

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
              decoration: const InputDecoration(
                hintText: 'Ask Advisor anything…',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

