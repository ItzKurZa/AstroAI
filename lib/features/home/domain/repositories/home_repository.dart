import '../../../profile/domain/entities/user_profile.dart';
import '../entities/home_content.dart';

abstract class HomeRepository {
  Future<HomeContent> fetchHomeContent(String userId, {DateTime? date});
  Future<UserProfile> fetchUser(String userId);
}

