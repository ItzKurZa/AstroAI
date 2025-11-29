import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return _remoteDataSource.watchMessages(threadId);
  }

  @override
  Future<void> sendMessage(String threadId, String message) async {
    // Only save user message - AI response will be handled by ChatConsultationService
    final userModel = ChatMessageModel(
      id: '',
      sender: 'user',
      text: message,
      createdAt: DateTime.now(),
    );
    await _remoteDataSource.sendMessage(threadId, userModel);
    // Note: AI response is handled separately by ChatConsultationService
    // to avoid duplicate responses
  }

  @override
  Future<void> sendAdvisorMessage(String threadId, String message) async {
    // threadId should be the userId (each user has their own chat thread)
    final aiModel = ChatMessageModel(
      id: '',
      sender: 'advisor',
      text: message,
      createdAt: DateTime.now(),
    );
    await _remoteDataSource.sendMessage(threadId, aiModel);
  }

  // Removed _composeAiResponse - AI responses are now handled by ChatConsultationService
  // to avoid duplicate responses
}

