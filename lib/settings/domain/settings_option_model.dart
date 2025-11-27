import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_option_model.freezed.dart';
part 'settings_option_model.g.dart';

@freezed
abstract class SettingsOptionModel with _$SettingsOptionModel {
  const factory SettingsOptionModel({
    @Default('') String id,
    @Default('') String title,
    @Default('') String subtitle,
    @Default('') String iconPath,
    @Default(false) bool isDestructive,
  }) = _SettingsOptionModel;

  factory SettingsOptionModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsOptionModelFromJson(json);
}
