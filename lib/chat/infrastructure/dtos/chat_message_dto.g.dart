// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) =>
    _ChatMessageDto(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sender: json['sender'] as String? ?? 'user',
      timestamp: json['timestamp'] as String? ?? '',
    );

Map<String, dynamic> _$ChatMessageDtoToJson(_ChatMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'sender': instance.sender,
      'timestamp': instance.timestamp,
    };
