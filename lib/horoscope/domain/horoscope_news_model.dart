import 'package:freezed_annotation/freezed_annotation.dart';

part 'horoscope_news_model.freezed.dart';
part 'horoscope_news_model.g.dart';

@freezed
abstract class HoroscopeNewsModel with _$HoroscopeNewsModel {
  const factory HoroscopeNewsModel({
    @Default('') String id,
    @Default('') String title,
    @Default('') String summary,
    @Default('') String imageUrl,
    @Default('') String publishedAt,
    @Default('') String source,
    @Default('') String url,
  }) = _HoroscopeNewsModel;

  factory HoroscopeNewsModel.fromJson(Map<String, dynamic> json) =>
      _$HoroscopeNewsModelFromJson(json);
}
