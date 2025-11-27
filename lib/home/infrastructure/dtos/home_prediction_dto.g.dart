// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_prediction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomePredictionDto _$HomePredictionDtoFromJson(Map<String, dynamic> json) =>
    _HomePredictionDto(
      date: json['date'] as String? ?? '',
      sunSign: json['sunSign'] as String? ?? '',
      prediction: json['prediction'] as String? ?? '',
      luckyNumber: json['luckyNumber'] as String? ?? '',
      luckyColor: json['luckyColor'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
    );

Map<String, dynamic> _$HomePredictionDtoToJson(_HomePredictionDto instance) =>
    <String, dynamic>{
      'date': instance.date,
      'sunSign': instance.sunSign,
      'prediction': instance.prediction,
      'luckyNumber': instance.luckyNumber,
      'luckyColor': instance.luckyColor,
      'mood': instance.mood,
    };
