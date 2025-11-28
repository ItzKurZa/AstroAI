import '../../domain/entities/match_profile.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_remote_data_source.dart';

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl(this._remoteDataSource);

  final MatchRemoteDataSource _remoteDataSource;

  @override
  Future<Map<String, List<MatchProfile>>> fetchMatchSections() {
    return _remoteDataSource.fetchMatchSections();
  }
}

