import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_prediction_model.freezed.dart';
part 'home_prediction_model.g.dart';

@freezed
abstract class HomePredictionModel with _$HomePredictionModel {
  const factory HomePredictionModel({
    @Default('') String date,
    @Default('') String sunSign,
    @Default('') String prediction,
    @Default('') String luckyNumber,
    @Default('') String luckyColor,
    @Default('') String mood,
  }) = _HomePredictionModel;

  factory HomePredictionModel.fromJson(Map<String, dynamic> json) =>
      _$HomePredictionModelFromJson(json);
}
