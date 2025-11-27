import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../dtos/chat_message_dto.dart';

part 'chat_api_client.g.dart';

@RestApi()
abstract class ChatApiClient {
  factory ChatApiClient(Dio dio, {String baseUrl}) = _ChatApiClient;

  @POST('/chat')
  Future<List<ChatMessageDto>> sendMessage(@Body() Map<String, dynamic> body);
}
