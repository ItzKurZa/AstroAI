import 'package:result_type/result_type.dart';
import 'user_profile_model.dart';

enum ProfileError { notFound, network, unknown }

class ProfileException implements Exception {
  final ProfileError error;
  final String? message;
  ProfileException(this.error, [this.message]);

  @override
  String toString() => message ?? error.toString();
}

abstract class IProfileService {
  /// Fetches the user profile.
  Future<Result<UserProfileModel, ProfileException>> getProfile(String userId);

  /// Updates the user profile.
  Future<Result<UserProfileModel, ProfileException>> updateProfile(
    UserProfileModel profile,
  );
}
