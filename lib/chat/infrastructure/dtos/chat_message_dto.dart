import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/chat_message_model.dart';

part 'chat_message_dto.freezed.dart';
part 'chat_message_dto.g.dart';

@freezed
abstract class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    @Default('') String id,
    @Default('') String text,
    @Default('user') String sender,
    @Default('') String timestamp,
  }) = _ChatMessageDto;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);
}

extension ChatMessageDtoX on ChatMessageDto {
  ChatMessageModel toDomain() => ChatMessageModel(
    id: id,
    text: text,
    sender: sender,
    timestamp: timestamp,
  );
}
