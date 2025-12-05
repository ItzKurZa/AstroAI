import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchMessages(String threadId);
  Future<void> sendMessage(String threadId, String message);
  Future<void> sendAdvisorMessage(String userId, String message);
}

