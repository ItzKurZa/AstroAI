import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_gps_service.dart';

/// Service to find nearby users based on GPS location
class NearbyUsersService {
  static NearbyUsersService? _instance;
  static NearbyUsersService get instance {
    _instance ??= NearbyUsersService._();
    return _instance!;
  }

  NearbyUsersService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationGpsService _gpsService = LocationGpsService.instance;

  /// Update current user's location
  /// Creates document if it doesn't exist
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'currentLatitude': latitude,
        'currentLongitude': longitude,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Error updating user location: $e');
      rethrow;
    }
  }

  /// Get nearby users sorted by distance
  /// 
  /// Returns list of user IDs with distance in km
  Future<List<Map<String, dynamic>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double maxDistanceKm = 50.0, // Default 50km radius
    int limit = 50,
    String? excludeUserId,
  }) async {
    try {
      // Get all users with location data
      final usersQuery = await _firestore
          .collection('users')
          .where('currentLatitude', isNotEqualTo: null)
          .where('currentLongitude', isNotEqualTo: null)
          .limit(limit * 2) // Get more to filter by distance
          .get();

      final nearbyUsers = <Map<String, dynamic>>[];

      for (final doc in usersQuery.docs) {
        final userId = doc.id;
        
        // Skip current user
        if (excludeUserId != null && userId == excludeUserId) {
          continue;
        }

        final data = doc.data();
        final userLat = data['currentLatitude'] as double?;
        final userLon = data['currentLongitude'] as double?;

        if (userLat == null || userLon == null) {
          continue;
        }

        // Calculate distance
        final distance = _gpsService.calculateDistance(
          latitude,
          longitude,
          userLat,
          userLon,
        );

        // Filter by max distance
        if (distance <= maxDistanceKm) {
          nearbyUsers.add({
            'userId': userId,
            'distance': distance,
            'latitude': userLat,
            'longitude': userLon,
            'userData': data,
          });
        }
      }

      // Sort by distance (closest first)
      nearbyUsers.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      // Limit results
      return nearbyUsers.take(limit).toList();
    } catch (e) {
      print('❌ Error getting nearby users: $e');
      return [];
    }
  }

  /// Get current user's location and update it
  Future<Map<String, double>?> getAndUpdateCurrentLocation(String userId) async {
    try {
      final position = await _gpsService.getCurrentPosition();
      if (position != null) {
        final lat = position['latitude'] ?? 0.0;
        final lng = position['longitude'] ?? 0.0;
        await updateUserLocation(
          userId: userId,
          latitude: lat,
          longitude: lng,
        );
        return {
          'latitude': lat,
          'longitude': lng,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }
}
