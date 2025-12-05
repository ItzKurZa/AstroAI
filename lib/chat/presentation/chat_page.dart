import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/chat_cubit.dart';
import '../application/chat_state.dart';
import '../../core/constants/k_sizes.dart';

class ChatPage extends StatelessWidget {
  static const String routeName = '/chat';
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Astrology AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.isLoading && state.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load chat.'),
                        SizedBox(height: KSizes.margin2x),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Retry logic
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        state.messages[state.messages.length - 1 - index];
                    final isUser = message.sender == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: KSizes.margin2x,
                          horizontal: KSizes.margin2x,
                        ),
                        padding: EdgeInsets.all(KSizes.margin2x),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            KSizes.radiusDefault,
                          ),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(KSizes.margin2x),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about your stars...',
                    ),
                  ),
                ),
                SizedBox(width: KSizes.margin2x),
                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: state.isLoading
                          ? null
                          : () {
                              final text = controller.text.trim();
                              if (text.isNotEmpty) {
                                context.read<ChatCubit>().sendMessage(text);
                                controller.clear();
                              }
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
