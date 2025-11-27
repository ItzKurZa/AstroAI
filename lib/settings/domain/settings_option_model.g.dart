// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettingsOptionModel _$SettingsOptionModelFromJson(Map<String, dynamic> json) =>
    _SettingsOptionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      iconPath: json['iconPath'] as String? ?? '',
      isDestructive: json['isDestructive'] as bool? ?? false,
    );

Map<String, dynamic> _$SettingsOptionModelToJson(
  _SettingsOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'iconPath': instance.iconPath,
  'isDestructive': instance.isDestructive,
};
