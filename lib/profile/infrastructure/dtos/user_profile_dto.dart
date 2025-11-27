import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/user_profile_model.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    @Default('') String id,
    @Default('') String name,
    @Default('') String email,
    @Default('') String photoUrl,
    @Default('') String sunSign,
    @Default('') String dob,
    @Default('') String bio,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}

extension UserProfileDtoX on UserProfileDto {
  UserProfileModel toDomain() => UserProfileModel(
    id: id,
    name: name,
    email: email,
    photoUrl: photoUrl,
    sunSign: sunSign,
    dob: dob,
    bio: bio,
  );
}