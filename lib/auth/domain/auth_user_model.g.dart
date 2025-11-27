// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUserModel _$AuthUserModelFromJson(Map<String, dynamic> json) =>
    _AuthUserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
    );

Map<String, dynamic> _$AuthUserModelToJson(_AuthUserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
    };
