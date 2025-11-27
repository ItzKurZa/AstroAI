import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/user_profile_model.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    UserProfileModel? profile,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
  }) = _ProfileState;

  factory ProfileState.initial() => const ProfileState();
}
