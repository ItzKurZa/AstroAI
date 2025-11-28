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
  Future<List<Characteristic>> fetchCharacteristics() {
    return _remoteDataSource.fetchCharacteristics();
  }
}

