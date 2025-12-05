import '../entities/characteristic.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile(String userId);
  Future<List<Characteristic>> fetchCharacteristics({String? userId});
  
  /// Update user profile
  Future<void> updateProfile(String userId, {
    String? displayName,
    String? avatarUrl,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    String? location,
  });
  
  /// Calculate and update astrological signs based on birth info
  Future<void> updateAstrologicalSigns(String userId);
  
  /// Share chart - generates shareable link/data
  Future<Map<String, dynamic>> shareChart(String userId);
  
  /// Fetch aspects for user's birth chart
  Future<List<Map<String, dynamic>>> fetchAspects(String userId);
}

