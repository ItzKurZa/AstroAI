import '../../domain/entities/characteristic.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> fetchProfile(String userId) {
    return _remoteDataSource.fetchProfile(userId);
  }

  @override
  Future<List<Characteristic>> fetchCharacteristics({String? userId}) {
    return _remoteDataSource.fetchCharacteristics(userId: userId);
  }

  @override
  Future<void> updateProfile(String userId, {
    String? displayName,
    String? avatarUrl,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    String? location,
  }) {
    return _remoteDataSource.updateProfile(
      userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
      location: location,
    );
  }

  @override
  Future<void> updateAstrologicalSigns(String userId) {
    return _remoteDataSource.updateAstrologicalSigns(userId);
  }

  @override
  Future<Map<String, dynamic>> shareChart(String userId) {
    return _remoteDataSource.shareChart(userId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAspects(String userId) {
    return _remoteDataSource.fetchAspects(userId);
  }
}

