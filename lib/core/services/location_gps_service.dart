import 'dart:math' as math;

// Note: geolocator package not available, using simplified implementation
// For production, add geolocator to pubspec.yaml

/// Service for GPS location tracking
/// Currently uses simplified distance calculation without GPS access
class LocationGpsService {
  static LocationGpsService? _instance;
  static LocationGpsService get instance {
    _instance ??= LocationGpsService._();
    return _instance!;
  }

  LocationGpsService._();

  /// Get current GPS position
  /// Note: Returns null as geolocator package is not available
  Future<Map<String, double>?> getCurrentPosition() async {
    // GPS functionality disabled - geolocator package not available
    // Return null to indicate GPS is not available
    return null;
  }

  /// Calculate distance between two coordinates in kilometers
  /// Uses Haversine formula for distance calculation
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula
    const double earthRadius = 6371; // Earth radius in kilometers
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  /// Calculate distance in meters
  double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return calculateDistance(lat1, lon1, lat2, lon2) * 1000;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  /// Format distance for display
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }
}

