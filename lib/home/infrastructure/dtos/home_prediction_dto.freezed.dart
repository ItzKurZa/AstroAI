// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_prediction_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomePredictionDto {

 String get date; String get sunSign; String get prediction; String get luckyNumber; String get luckyColor; String get mood;
/// Create a copy of HomePredictionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomePredictionDtoCopyWith<HomePredictionDto> get copyWith => _$HomePredictionDtoCopyWithImpl<HomePredictionDto>(this as HomePredictionDto, _$identity);

  /// Serializes this HomePredictionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomePredictionDto&&(identical(other.date, date) || other.date == date)&&(identical(other.sunSign, sunSign) || other.sunSign == sunSign)&&(identical(other.prediction, prediction) || other.prediction == prediction)&&(identical(other.luckyNumber, luckyNumber) || other.luckyNumber == luckyNumber)&&(identical(other.luckyColor, luckyColor) || other.luckyColor == luckyColor)&&(identical(other.mood, mood) || other.mood == mood));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,sunSign,prediction,luckyNumber,luckyColor,mood);

@override
String toString() {
  return 'HomePredictionDto(date: $date, sunSign: $sunSign, prediction: $prediction, luckyNumber: $luckyNumber, luckyColor: $luckyColor, mood: $mood)';
}


}

/// @nodoc
abstract mixin class $HomePredictionDtoCopyWith<$Res>  {
  factory $HomePredictionDtoCopyWith(HomePredictionDto value, $Res Function(HomePredictionDto) _then) = _$HomePredictionDtoCopyWithImpl;
@useResult
$Res call({
 String date, String sunSign, String prediction, String luckyNumber, String luckyColor, String mood
});




}
/// @nodoc
class _$HomePredictionDtoCopyWithImpl<$Res>
    implements $HomePredictionDtoCopyWith<$Res> {
  _$HomePredictionDtoCopyWithImpl(this._self, this._then);

  final HomePredictionDto _self;
  final $Res Function(HomePredictionDto) _then;

/// Create a copy of HomePredictionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? sunSign = null,Object? prediction = null,Object? luckyNumber = null,Object? luckyColor = null,Object? mood = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,sunSign: null == sunSign ? _self.sunSign : sunSign // ignore: cast_nullable_to_non_nullable
as String,prediction: null == prediction ? _self.prediction : prediction // ignore: cast_nullable_to_non_nullable
as String,luckyNumber: null == luckyNumber ? _self.luckyNumber : luckyNumber // ignore: cast_nullable_to_non_nullable
as String,luckyColor: null == luckyColor ? _self.luckyColor : luckyColor // ignore: cast_nullable_to_non_nullable
as String,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HomePredictionDto].
extension HomePredictionDtoPatterns on HomePredictionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomePredictionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomePredictionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomePredictionDto value)  $default,){
final _that = this;
switch (_that) {
case _HomePredictionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomePredictionDto value)?  $default,){
final _that = this;
switch (_that) {
case _HomePredictionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String sunSign,  String prediction,  String luckyNumber,  String luckyColor,  String mood)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomePredictionDto() when $default != null:
return $default(_that.date,_that.sunSign,_that.prediction,_that.luckyNumber,_that.luckyColor,_that.mood);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String sunSign,  String prediction,  String luckyNumber,  String luckyColor,  String mood)  $default,) {final _that = this;
switch (_that) {
case _HomePredictionDto():
return $default(_that.date,_that.sunSign,_that.prediction,_that.luckyNumber,_that.luckyColor,_that.mood);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String sunSign,  String prediction,  String luckyNumber,  String luckyColor,  String mood)?  $default,) {final _that = this;
switch (_that) {
case _HomePredictionDto() when $default != null:
return $default(_that.date,_that.sunSign,_that.prediction,_that.luckyNumber,_that.luckyColor,_that.mood);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomePredictionDto implements HomePredictionDto {
  const _HomePredictionDto({this.date = '', this.sunSign = '', this.prediction = '', this.luckyNumber = '', this.luckyColor = '', this.mood = ''});
  factory _HomePredictionDto.fromJson(Map<String, dynamic> json) => _$HomePredictionDtoFromJson(json);

@override@JsonKey() final  String date;
@override@JsonKey() final  String sunSign;
@override@JsonKey() final  String prediction;
@override@JsonKey() final  String luckyNumber;
@override@JsonKey() final  String luckyColor;
@override@JsonKey() final  String mood;

/// Create a copy of HomePredictionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomePredictionDtoCopyWith<_HomePredictionDto> get copyWith => __$HomePredictionDtoCopyWithImpl<_HomePredictionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomePredictionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomePredictionDto&&(identical(other.date, date) || other.date == date)&&(identical(other.sunSign, sunSign) || other.sunSign == sunSign)&&(identical(other.prediction, prediction) || other.prediction == prediction)&&(identical(other.luckyNumber, luckyNumber) || other.luckyNumber == luckyNumber)&&(identical(other.luckyColor, luckyColor) || other.luckyColor == luckyColor)&&(identical(other.mood, mood) || other.mood == mood));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,sunSign,prediction,luckyNumber,luckyColor,mood);

@override
String toString() {
  return 'HomePredictionDto(date: $date, sunSign: $sunSign, prediction: $prediction, luckyNumber: $luckyNumber, luckyColor: $luckyColor, mood: $mood)';
}


}

/// @nodoc
abstract mixin class _$HomePredictionDtoCopyWith<$Res> implements $HomePredictionDtoCopyWith<$Res> {
  factory _$HomePredictionDtoCopyWith(_HomePredictionDto value, $Res Function(_HomePredictionDto) _then) = __$HomePredictionDtoCopyWithImpl;
@override @useResult
$Res call({
 String date, String sunSign, String prediction, String luckyNumber, String luckyColor, String mood
});




}
/// @nodoc
class __$HomePredictionDtoCopyWithImpl<$Res>
    implements _$HomePredictionDtoCopyWith<$Res> {
  __$HomePredictionDtoCopyWithImpl(this._self, this._then);

  final _HomePredictionDto _self;
  final $Res Function(_HomePredictionDto) _then;

/// Create a copy of HomePredictionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? sunSign = null,Object? prediction = null,Object? luckyNumber = null,Object? luckyColor = null,Object? mood = null,}) {
  return _then(_HomePredictionDto(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,sunSign: null == sunSign ? _self.sunSign : sunSign // ignore: cast_nullable_to_non_nullable
as String,prediction: null == prediction ? _self.prediction : prediction // ignore: cast_nullable_to_non_nullable
as String,luckyNumber: null == luckyNumber ? _self.luckyNumber : luckyNumber // ignore: cast_nullable_to_non_nullable
as String,luckyColor: null == luckyColor ? _self.luckyColor : luckyColor // ignore: cast_nullable_to_non_nullable
as String,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
