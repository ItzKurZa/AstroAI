import '../entities/match_profile.dart';

abstract class MatchRepository {
  Future<Map<String, List<MatchProfile>>> fetchMatchSections();
  Future<List<MatchProfile>> fetchNearbyUsers({double maxDistanceKm = 50.0});
}

