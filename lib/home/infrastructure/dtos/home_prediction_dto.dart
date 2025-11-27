import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/home_prediction_model.dart';

part 'home_prediction_dto.freezed.dart';
part 'home_prediction_dto.g.dart';

@freezed
abstract class HomePredictionDto with _$HomePredictionDto {
  const factory HomePredictionDto({
    @Default('') String date,
    @Default('') String sunSign,
    @Default('') String prediction,
    @Default('') String luckyNumber,
    @Default('') String luckyColor,
    @Default('') String mood,
  }) = _HomePredictionDto;

  factory HomePredictionDto.fromJson(Map<String, dynamic> json) =>
      _$HomePredictionDtoFromJson(json);
}

extension HomePredictionDtoX on HomePredictionDto {
  HomePredictionModel toDomain() => HomePredictionModel(
    date: date,
    sunSign: sunSign,
    prediction: prediction,
    luckyNumber: luckyNumber,
    luckyColor: luckyColor,
    mood: mood,
  );
}
