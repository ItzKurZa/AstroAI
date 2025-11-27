import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/chat_message_model.dart';

part 'chat_state.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessageModel> messages,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
  }) = _ChatState;

  factory ChatState.initial() => const ChatState();
}
