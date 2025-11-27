// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horoscope_news_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HoroscopeNewsDto _$HoroscopeNewsDtoFromJson(Map<String, dynamic> json) =>
    _HoroscopeNewsDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? '',
      source: json['source'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$HoroscopeNewsDtoToJson(_HoroscopeNewsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'imageUrl': instance.imageUrl,
      'publishedAt': instance.publishedAt,
      'source': instance.source,
      'url': instance.url,
    };
