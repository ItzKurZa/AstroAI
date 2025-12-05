import 'package:dio/dio.dart';
import 'package:result_type/result_type.dart';
import '../domain/i_chat_service.dart';
import '../domain/chat_message_model.dart';
import 'dtos/chat_message_dto.dart';
import 'constants/chat_api_keys.dart';
import '../../core/api/http_client.dart';

class ChatService implements IChatService {
  final Dio _dio;

  ChatService({Dio? dio})
    : _dio = dio ?? HttpClient.createDio(baseUrl: ChatApiKeys.baseUrl);

  @override
  Future<Result<List<ChatMessageModel>, ChatException>> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
  }) async {
    try {
      final body = {
        'message': message,
        'history': history
            .map((m) => ChatMessageDto.fromJson(m.toJson()).toJson())
            .toList(),
      };
      // Simulate API call, replace with actual API client if available
      final response = await _dio.post(ChatApiKeys.chatEndpoint, data: body);
      final List<dynamic> data = response.data as List<dynamic>;
      final dtos = data
          .map((json) => ChatMessageDto.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(dtos.map((dto) => dto.toDomain()).toList());
    } on DioException catch (_) {
      return Failure(ChatException(ChatError.network));
    } catch (_) {
      return Failure(ChatException(ChatError.unknown));
    }
  }
}
