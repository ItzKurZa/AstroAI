// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessageDto {

 String get id; String get text; String get sender; String get timestamp;
/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageDtoCopyWith<ChatMessageDto> get copyWith => _$ChatMessageDtoCopyWithImpl<ChatMessageDto>(this as ChatMessageDto, _$identity);

  /// Serializes this ChatMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,sender,timestamp);

@override
String toString() {
  return 'ChatMessageDto(id: $id, text: $text, sender: $sender, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $ChatMessageDtoCopyWith<$Res>  {
  factory $ChatMessageDtoCopyWith(ChatMessageDto value, $Res Function(ChatMessageDto) _then) = _$ChatMessageDtoCopyWithImpl;
@useResult
$Res call({
 String id, String text, String sender, String timestamp
});




}
/// @nodoc
class _$ChatMessageDtoCopyWithImpl<$Res>
    implements $ChatMessageDtoCopyWith<$Res> {
  _$ChatMessageDtoCopyWithImpl(this._self, this._then);

  final ChatMessageDto _self;
  final $Res Function(ChatMessageDto) _then;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? sender = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageDto].
extension ChatMessageDtoPatterns on ChatMessageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  String sender,  String timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
return $default(_that.id,_that.text,_that.sender,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  String sender,  String timestamp)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageDto():
return $default(_that.id,_that.text,_that.sender,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  String sender,  String timestamp)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
return $default(_that.id,_that.text,_that.sender,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageDto implements ChatMessageDto {
  const _ChatMessageDto({this.id = '', this.text = '', this.sender = 'user', this.timestamp = ''});
  factory _ChatMessageDto.fromJson(Map<String, dynamic> json) => _$ChatMessageDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String text;
@override@JsonKey() final  String sender;
@override@JsonKey() final  String timestamp;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageDtoCopyWith<_ChatMessageDto> get copyWith => __$ChatMessageDtoCopyWithImpl<_ChatMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,sender,timestamp);

@override
String toString() {
  return 'ChatMessageDto(id: $id, text: $text, sender: $sender, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageDtoCopyWith<$Res> implements $ChatMessageDtoCopyWith<$Res> {
  factory _$ChatMessageDtoCopyWith(_ChatMessageDto value, $Res Function(_ChatMessageDto) _then) = __$ChatMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, String sender, String timestamp
});




}
/// @nodoc
class __$ChatMessageDtoCopyWithImpl<$Res>
    implements _$ChatMessageDtoCopyWith<$Res> {
  __$ChatMessageDtoCopyWithImpl(this._self, this._then);

  final _ChatMessageDto _self;
  final $Res Function(_ChatMessageDto) _then;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? sender = null,Object? timestamp = null,}) {
  return _then(_ChatMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
