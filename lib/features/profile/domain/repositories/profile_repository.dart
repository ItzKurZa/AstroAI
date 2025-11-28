import '../entities/characteristic.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile(String userId);
  Future<List<Characteristic>> fetchCharacteristics();
}

