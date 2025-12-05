import 'package:flutter/material.dart';
import '../../domain/chat_message_model.dart';
import '../../../core/constants/k_sizes.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;
  const ChatBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: KSizes.margin2x,
          horizontal: KSizes.margin2x,
        ),
        padding: EdgeInsets.all(KSizes.margin2x),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(KSizes.radiusDefault),
        ),
        child: Text(message.text),
      ),
    );
  }
}
