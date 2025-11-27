import 'package:result_type/result_type.dart';
import 'chat_message_model.dart';

enum ChatError { network, api, unknown }

class ChatException implements Exception {
  final ChatError error;
  final String? message;
  ChatException(this.error, [this.message]);

  @override
  String toString() => message ?? error.toString();
}

abstract class IChatService {
  /// Sends a user message and receives an AI response.
  ///
  /// Returns [Result.failure] with [ChatException] if the API call fails.
  Future<Result<List<ChatMessageModel>, ChatException>> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
  });
}
