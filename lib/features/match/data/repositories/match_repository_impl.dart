import '../../domain/entities/match_profile.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_remote_data_source.dart';

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl(this._remoteDataSource);

  final MatchRemoteDataSource _remoteDataSource;

  @override
  Future<Map<String, List<MatchProfile>>> fetchMatchSections() {
    // Legacy method - now returns empty as we use real users
    return Future.value(<String, List<MatchProfile>>{});
  }

  @override
  Future<List<MatchProfile>> fetchNearbyUsers({double maxDistanceKm = 50.0}) {
    return _remoteDataSource.fetchNearbyUsers(maxDistanceKm: maxDistanceKm);
  }
}

