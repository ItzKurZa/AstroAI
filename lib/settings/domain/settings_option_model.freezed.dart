// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsOptionModel {

 String get id; String get title; String get subtitle; String get iconPath; bool get isDestructive;
/// Create a copy of SettingsOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsOptionModelCopyWith<SettingsOptionModel> get copyWith => _$SettingsOptionModelCopyWithImpl<SettingsOptionModel>(this as SettingsOptionModel, _$identity);

  /// Serializes this SettingsOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.isDestructive, isDestructive) || other.isDestructive == isDestructive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,iconPath,isDestructive);

@override
String toString() {
  return 'SettingsOptionModel(id: $id, title: $title, subtitle: $subtitle, iconPath: $iconPath, isDestructive: $isDestructive)';
}


}

/// @nodoc
abstract mixin class $SettingsOptionModelCopyWith<$Res>  {
  factory $SettingsOptionModelCopyWith(SettingsOptionModel value, $Res Function(SettingsOptionModel) _then) = _$SettingsOptionModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String subtitle, String iconPath, bool isDestructive
});




}
/// @nodoc
class _$SettingsOptionModelCopyWithImpl<$Res>
    implements $SettingsOptionModelCopyWith<$Res> {
  _$SettingsOptionModelCopyWithImpl(this._self, this._then);

  final SettingsOptionModel _self;
  final $Res Function(SettingsOptionModel) _then;

/// Create a copy of SettingsOptionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? iconPath = null,Object? isDestructive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,iconPath: null == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String,isDestructive: null == isDestructive ? _self.isDestructive : isDestructive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsOptionModel].
extension SettingsOptionModelPatterns on SettingsOptionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsOptionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _SettingsOptionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsOptionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String iconPath,  bool isDestructive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsOptionModel() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.iconPath,_that.isDestructive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String iconPath,  bool isDestructive)  $default,) {final _that = this;
switch (_that) {
case _SettingsOptionModel():
return $default(_that.id,_that.title,_that.subtitle,_that.iconPath,_that.isDestructive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String subtitle,  String iconPath,  bool isDestructive)?  $default,) {final _that = this;
switch (_that) {
case _SettingsOptionModel() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.iconPath,_that.isDestructive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SettingsOptionModel implements SettingsOptionModel {
  const _SettingsOptionModel({this.id = '', this.title = '', this.subtitle = '', this.iconPath = '', this.isDestructive = false});
  factory _SettingsOptionModel.fromJson(Map<String, dynamic> json) => _$SettingsOptionModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;
@override@JsonKey() final  String iconPath;
@override@JsonKey() final  bool isDestructive;

/// Create a copy of SettingsOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsOptionModelCopyWith<_SettingsOptionModel> get copyWith => __$SettingsOptionModelCopyWithImpl<_SettingsOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.isDestructive, isDestructive) || other.isDestructive == isDestructive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,iconPath,isDestructive);

@override
String toString() {
  return 'SettingsOptionModel(id: $id, title: $title, subtitle: $subtitle, iconPath: $iconPath, isDestructive: $isDestructive)';
}


}

/// @nodoc
abstract mixin class _$SettingsOptionModelCopyWith<$Res> implements $SettingsOptionModelCopyWith<$Res> {
  factory _$SettingsOptionModelCopyWith(_SettingsOptionModel value, $Res Function(_SettingsOptionModel) _then) = __$SettingsOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String subtitle, String iconPath, bool isDestructive
});




}
/// @nodoc
class __$SettingsOptionModelCopyWithImpl<$Res>
    implements _$SettingsOptionModelCopyWith<$Res> {
  __$SettingsOptionModelCopyWithImpl(this._self, this._then);

  final _SettingsOptionModel _self;
  final $Res Function(_SettingsOptionModel) _then;

/// Create a copy of SettingsOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? iconPath = null,Object? isDestructive = null,}) {
  return _then(_SettingsOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,iconPath: null == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String,isDestructive: null == isDestructive ? _self.isDestructive : isDestructive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
