// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horoscope_news_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HoroscopeNewsDto {

 String get id; String get title; String get summary; String get imageUrl; String get publishedAt; String get source; String get url;
/// Create a copy of HoroscopeNewsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoroscopeNewsDtoCopyWith<HoroscopeNewsDto> get copyWith => _$HoroscopeNewsDtoCopyWithImpl<HoroscopeNewsDto>(this as HoroscopeNewsDto, _$identity);

  /// Serializes this HoroscopeNewsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoroscopeNewsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,summary,imageUrl,publishedAt,source,url);

@override
String toString() {
  return 'HoroscopeNewsDto(id: $id, title: $title, summary: $summary, imageUrl: $imageUrl, publishedAt: $publishedAt, source: $source, url: $url)';
}


}

/// @nodoc
abstract mixin class $HoroscopeNewsDtoCopyWith<$Res>  {
  factory $HoroscopeNewsDtoCopyWith(HoroscopeNewsDto value, $Res Function(HoroscopeNewsDto) _then) = _$HoroscopeNewsDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String summary, String imageUrl, String publishedAt, String source, String url
});




}
/// @nodoc
class _$HoroscopeNewsDtoCopyWithImpl<$Res>
    implements $HoroscopeNewsDtoCopyWith<$Res> {
  _$HoroscopeNewsDtoCopyWithImpl(this._self, this._then);

  final HoroscopeNewsDto _self;
  final $Res Function(HoroscopeNewsDto) _then;

/// Create a copy of HoroscopeNewsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? summary = null,Object? imageUrl = null,Object? publishedAt = null,Object? source = null,Object? url = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HoroscopeNewsDto].
extension HoroscopeNewsDtoPatterns on HoroscopeNewsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoroscopeNewsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoroscopeNewsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoroscopeNewsDto value)  $default,){
final _that = this;
switch (_that) {
case _HoroscopeNewsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoroscopeNewsDto value)?  $default,){
final _that = this;
switch (_that) {
case _HoroscopeNewsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String summary,  String imageUrl,  String publishedAt,  String source,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoroscopeNewsDto() when $default != null:
return $default(_that.id,_that.title,_that.summary,_that.imageUrl,_that.publishedAt,_that.source,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String summary,  String imageUrl,  String publishedAt,  String source,  String url)  $default,) {final _that = this;
switch (_that) {
case _HoroscopeNewsDto():
return $default(_that.id,_that.title,_that.summary,_that.imageUrl,_that.publishedAt,_that.source,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String summary,  String imageUrl,  String publishedAt,  String source,  String url)?  $default,) {final _that = this;
switch (_that) {
case _HoroscopeNewsDto() when $default != null:
return $default(_that.id,_that.title,_that.summary,_that.imageUrl,_that.publishedAt,_that.source,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HoroscopeNewsDto implements HoroscopeNewsDto {
  const _HoroscopeNewsDto({this.id = '', this.title = '', this.summary = '', this.imageUrl = '', this.publishedAt = '', this.source = '', this.url = ''});
  factory _HoroscopeNewsDto.fromJson(Map<String, dynamic> json) => _$HoroscopeNewsDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String summary;
@override@JsonKey() final  String imageUrl;
@override@JsonKey() final  String publishedAt;
@override@JsonKey() final  String source;
@override@JsonKey() final  String url;

/// Create a copy of HoroscopeNewsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoroscopeNewsDtoCopyWith<_HoroscopeNewsDto> get copyWith => __$HoroscopeNewsDtoCopyWithImpl<_HoroscopeNewsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HoroscopeNewsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoroscopeNewsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,summary,imageUrl,publishedAt,source,url);

@override
String toString() {
  return 'HoroscopeNewsDto(id: $id, title: $title, summary: $summary, imageUrl: $imageUrl, publishedAt: $publishedAt, source: $source, url: $url)';
}


}

/// @nodoc
abstract mixin class _$HoroscopeNewsDtoCopyWith<$Res> implements $HoroscopeNewsDtoCopyWith<$Res> {
  factory _$HoroscopeNewsDtoCopyWith(_HoroscopeNewsDto value, $Res Function(_HoroscopeNewsDto) _then) = __$HoroscopeNewsDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String summary, String imageUrl, String publishedAt, String source, String url
});




}
/// @nodoc
class __$HoroscopeNewsDtoCopyWithImpl<$Res>
    implements _$HoroscopeNewsDtoCopyWith<$Res> {
  __$HoroscopeNewsDtoCopyWithImpl(this._self, this._then);

  final _HoroscopeNewsDto _self;
  final $Res Function(_HoroscopeNewsDto) _then;

/// Create a copy of HoroscopeNewsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? summary = null,Object? imageUrl = null,Object? publishedAt = null,Object? source = null,Object? url = null,}) {
  return _then(_HoroscopeNewsDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
