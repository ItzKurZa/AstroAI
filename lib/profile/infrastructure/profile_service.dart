import 'package:dio/dio.dart';
import 'package:result_type/result_type.dart';

import '../../core/api/http_client.dart';
import '../domain/i_profile_service.dart';
import '../domain/user_profile_model.dart';
import 'dtos/user_profile_dto.dart';
import 'constants/profile_api_keys.dart';

class ProfileService implements IProfileService {
  final Dio _dio;

  ProfileService({Dio? dio})
    : _dio = dio ?? HttpClient.createDio(baseUrl: ProfileApiKeys.baseUrl);

  @override
  Future<Result<UserProfileModel, ProfileException>> getProfile(
    String userId,
  ) async {
    try {
      final response = await _dio.get(
        '${ProfileApiKeys.profileEndpoint}/$userId',
      );
      final dto = UserProfileDto.fromJson(response.data);
      return Success(dto.toDomain());
    } on DioException catch (_) {
      return Failure(ProfileException(ProfileError.network));
    } catch (_) {
      return Failure(ProfileException(ProfileError.unknown));
    }
  }

  @override
  Future<Result<UserProfileModel, ProfileException>> updateProfile(
    UserProfileModel profile,
  ) async {
    try {
      final response = await _dio.put(
        '${ProfileApiKeys.profileEndpoint}/${profile.id}',
        data: UserProfileDto.fromJson(profile.toJson()).toJson(),
      );
      final dto = UserProfileDto.fromJson(response.data);
      return Success(dto.toDomain());
    } on DioException catch (_) {
      return Failure(ProfileException(ProfileError.network));
    } catch (_) {
      return Failure(ProfileException(ProfileError.unknown));
    }
  }
}
