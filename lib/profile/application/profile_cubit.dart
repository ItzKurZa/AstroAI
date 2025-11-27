import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/i_profile_service.dart';
import '../domain/user_profile_model.dart';
import '../infrastructure/profile_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final IProfileService _service;

  ProfileCubit({IProfileService? service})
    : _service = service ?? ProfileService(),
      super(ProfileState.initial());

  Future<void> fetchProfile(String userId) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final result = await _service.getProfile(userId);
    if (result.isSuccess) {
      emit(
        state.copyWith(
          profile: result.success,
          isLoading: false,
          hasError: false,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final result = await _service.updateProfile(profile);
    if (result.isSuccess) {
      emit(
        state.copyWith(
          profile: result.success,
          isLoading: false,
          hasError: false,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
