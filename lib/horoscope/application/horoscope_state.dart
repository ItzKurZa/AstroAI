import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/horoscope_news_model.dart';

part 'horoscope_state.freezed.dart';

@freezed
abstract class HoroscopeState with _$HoroscopeState {
  const factory HoroscopeState({
    @Default([]) List<HoroscopeNewsModel> news,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
  }) = _HoroscopeState;

  factory HoroscopeState.initial() => const HoroscopeState();
}
