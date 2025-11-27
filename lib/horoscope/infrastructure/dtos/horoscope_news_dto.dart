import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/horoscope_news_model.dart';

part 'horoscope_news_dto.freezed.dart';
part 'horoscope_news_dto.g.dart';

@freezed
abstract class HoroscopeNewsDto with _$HoroscopeNewsDto {
  const factory HoroscopeNewsDto({
    @Default('') String id,
    @Default('') String title,
    @Default('') String summary,
    @Default('') String imageUrl,
    @Default('') String publishedAt,
    @Default('') String source,
    @Default('') String url,
  }) = _HoroscopeNewsDto;

  factory HoroscopeNewsDto.fromJson(Map<String, dynamic> json) =>
      _$HoroscopeNewsDtoFromJson(json);
}

extension HoroscopeNewsDtoX on HoroscopeNewsDto {
  HoroscopeNewsModel toDomain() => HoroscopeNewsModel(
    id: id,
    title: title,
    summary: summary,
    imageUrl: imageUrl,
    publishedAt: publishedAt,
    source: source,
    url: url,
  );
}