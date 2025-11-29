import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/home_content.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<HomeContent> fetchHomeContent(String userId, {DateTime? date}) {
    return _remoteDataSource.fetchContent(userId, date: date);
  }

  @override
  Future<UserProfile> fetchUser(String userId) {
    return _remoteDataSource.fetchUser(userId);
  }
}

