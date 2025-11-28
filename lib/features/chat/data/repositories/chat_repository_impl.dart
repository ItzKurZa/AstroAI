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
    final userModel = ChatMessageModel(
      id: '',
      sender: 'user',
      text: message,
      createdAt: DateTime.now(),
    );
    await _remoteDataSource.sendMessage(threadId, userModel);

    final aiResponse = _composeAiResponse(message);
    final aiModel = ChatMessageModel(
      id: '',
      sender: 'advisor',
      text: aiResponse,
      createdAt: DateTime.now(),
    );
    await _remoteDataSource.sendMessage(threadId, aiModel);
  }

  String _composeAiResponse(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('career')) {
      return 'Mars in Sagittarius highlights bold moves at work. List one courageous step you can take today and I will help you refine it.';
    }
    if (lower.contains('love') || lower.contains('relationship')) {
      return 'Venus encourages vulnerability. Share gratitude with someone close and notice how the energy shifts.';
    }
    return 'Take a deep breath. Let me know whether you want insights about health, finance, or relationships next.';
  }
}

