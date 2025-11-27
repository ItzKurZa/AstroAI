// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horoscope_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HoroscopeState {

 List<HoroscopeNewsModel> get news; bool get isLoading; bool get hasError;
/// Create a copy of HoroscopeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoroscopeStateCopyWith<HoroscopeState> get copyWith => _$HoroscopeStateCopyWithImpl<HoroscopeState>(this as HoroscopeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoroscopeState&&const DeepCollectionEquality().equals(other.news, news)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(news),isLoading,hasError);

@override
String toString() {
  return 'HoroscopeState(news: $news, isLoading: $isLoading, hasError: $hasError)';
}


}

/// @nodoc
abstract mixin class $HoroscopeStateCopyWith<$Res>  {
  factory $HoroscopeStateCopyWith(HoroscopeState value, $Res Function(HoroscopeState) _then) = _$HoroscopeStateCopyWithImpl;
@useResult
$Res call({
 List<HoroscopeNewsModel> news, bool isLoading, bool hasError
});




}
/// @nodoc
class _$HoroscopeStateCopyWithImpl<$Res>
    implements $HoroscopeStateCopyWith<$Res> {
  _$HoroscopeStateCopyWithImpl(this._self, this._then);

  final HoroscopeState _self;
  final $Res Function(HoroscopeState) _then;

/// Create a copy of HoroscopeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? news = null,Object? isLoading = null,Object? hasError = null,}) {
  return _then(_self.copyWith(
news: null == news ? _self.news : news // ignore: cast_nullable_to_non_nullable
as List<HoroscopeNewsModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HoroscopeState].
extension HoroscopeStatePatterns on HoroscopeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoroscopeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoroscopeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoroscopeState value)  $default,){
final _that = this;
switch (_that) {
case _HoroscopeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoroscopeState value)?  $default,){
final _that = this;
switch (_that) {
case _HoroscopeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HoroscopeNewsModel> news,  bool isLoading,  bool hasError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoroscopeState() when $default != null:
return $default(_that.news,_that.isLoading,_that.hasError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HoroscopeNewsModel> news,  bool isLoading,  bool hasError)  $default,) {final _that = this;
switch (_that) {
case _HoroscopeState():
return $default(_that.news,_that.isLoading,_that.hasError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HoroscopeNewsModel> news,  bool isLoading,  bool hasError)?  $default,) {final _that = this;
switch (_that) {
case _HoroscopeState() when $default != null:
return $default(_that.news,_that.isLoading,_that.hasError);case _:
  return null;

}
}

}

/// @nodoc


class _HoroscopeState implements HoroscopeState {
  const _HoroscopeState({final  List<HoroscopeNewsModel> news = const [], this.isLoading = false, this.hasError = false}): _news = news;
  

 final  List<HoroscopeNewsModel> _news;
@override@JsonKey() List<HoroscopeNewsModel> get news {
  if (_news is EqualUnmodifiableListView) return _news;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_news);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool hasError;

/// Create a copy of HoroscopeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoroscopeStateCopyWith<_HoroscopeState> get copyWith => __$HoroscopeStateCopyWithImpl<_HoroscopeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoroscopeState&&const DeepCollectionEquality().equals(other._news, _news)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_news),isLoading,hasError);

@override
String toString() {
  return 'HoroscopeState(news: $news, isLoading: $isLoading, hasError: $hasError)';
}


}

/// @nodoc
abstract mixin class _$HoroscopeStateCopyWith<$Res> implements $HoroscopeStateCopyWith<$Res> {
  factory _$HoroscopeStateCopyWith(_HoroscopeState value, $Res Function(_HoroscopeState) _then) = __$HoroscopeStateCopyWithImpl;
@override @useResult
$Res call({
 List<HoroscopeNewsModel> news, bool isLoading, bool hasError
});




}
/// @nodoc
class __$HoroscopeStateCopyWithImpl<$Res>
    implements _$HoroscopeStateCopyWith<$Res> {
  __$HoroscopeStateCopyWithImpl(this._self, this._then);

  final _HoroscopeState _self;
  final $Res Function(_HoroscopeState) _then;

/// Create a copy of HoroscopeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? news = null,Object? isLoading = null,Object? hasError = null,}) {
  return _then(_HoroscopeState(
news: null == news ? _self._news : news // ignore: cast_nullable_to_non_nullable
as List<HoroscopeNewsModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
