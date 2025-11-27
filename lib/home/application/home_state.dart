import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/home_prediction_model.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(null) HomePredictionModel? prediction,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
  }) = _HomeState;

  factory HomeState.initial() => const HomeState();
}
