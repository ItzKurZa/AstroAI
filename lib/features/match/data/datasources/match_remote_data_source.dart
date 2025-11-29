import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/nearby_users_service.dart';
import '../models/match_profile_model.dart';

class MatchRemoteDataSource {
  MatchRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  final NearbyUsersService _nearbyService = NearbyUsersService.instance;

  /// Fetch nearby users sorted by distance
  Future<List<MatchProfileModel>> fetchNearbyUsers({
    double maxDistanceKm = 50.0,
  }) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return [];
      }

      // Get current user's location
      final location = await _nearbyService.getAndUpdateCurrentLocation(currentUserId);
      if (location == null) {
        print('⚠️ Could not get current location');
        return [];
      }

      // Get nearby users
      final nearbyUsers = await _nearbyService.getNearbyUsers(
        latitude: location['latitude']!,
        longitude: location['longitude']!,
        maxDistanceKm: maxDistanceKm,
        excludeUserId: currentUserId,
      );

      // Convert to MatchProfileModel
      final profiles = <MatchProfileModel>[];
      for (final userData in nearbyUsers) {
        final userId = userData['userId'] as String;
        final distance = userData['distance'] as double;
        final userDoc = userData['userData'] as Map<String, dynamic>;

        // Create profile from user data
        final profile = MatchProfileModel.fromUserData(
          userId: userId,
          data: userDoc,
          distance: distance,
        );
        profiles.add(profile);
      }

      return profiles;
    } catch (e) {
      print('❌ Error fetching nearby users: $e');
      return [];
    }
  }

  /// Create a document snapshot-like object from user data
  /// Returns a simple map with id and data
  Map<String, dynamic> _createDocumentSnapshot(
    String id,
    Map<String, dynamic> data,
  ) {
    return {
      'id': id,
      'data': data,
    };
  }
}

