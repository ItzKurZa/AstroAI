import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/settings_option_model.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default([]) List<SettingsOptionModel> options,
  }) = _SettingsState;

  factory SettingsState.initial() => const SettingsState();
}
