import '../domain/entities/birth_chart.dart';
import '../domain/entities/planetary_position.dart';
import '../domain/entities/house_position.dart';
import 'freeastrology_api_service.dart';

/// Calculator for astrological calculations
/// Uses FreeAstrologyAPI when available, falls back to simplified calculations
class AstrologyCalculator {
  AstrologyCalculator._();
  static final AstrologyCalculator _instance = AstrologyCalculator._();
  static AstrologyCalculator get instance => _instance;

  final FreeAstrologyApiService _apiService = FreeAstrologyApiService.instance;

  /// Calculate birth chart
  /// Uses FreeAstrologyAPI if available, otherwise uses simplified calculations
  Future<BirthChart> calculateBirthChart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Try to use API if available
      if (_apiService.isAvailable) {
        final timeStr = '${birthDateTime.hour.toString().padLeft(2, '0')}:${birthDateTime.minute.toString().padLeft(2, '0')}';
        final apiData = await _apiService.getBirthChart(
          birthDate: birthDateTime,
          birthTime: timeStr,
          latitude: latitude,
          longitude: longitude,
        );
        
        return _apiService.parseBirthChartResponse(
          apiData,
          birthDateTime: birthDateTime,
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (e) {
      // Don't log - error already logged in FreeAstrologyApiService
      // Fallback will be used automatically
    }

    // Fallback to simplified calculation
    return _calculateSimplifiedBirthChart(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Simplified birth chart calculation (fallback)
  BirthChart _calculateSimplifiedBirthChart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) {
    // Create simplified planetary positions
    final month = birthDateTime.month;
    final day = birthDateTime.day;
    final sunLongitude = _getSunLongitude(month, day);
    final sunSign = _longitudeToSign(sunLongitude);
    final sunDegrees = sunLongitude % 30;
    final sunMinutes = (sunDegrees % 1) * 60;
    final sunSeconds = (sunMinutes % 1) * 60;
    
    final planets = <PlanetaryPosition>[
      PlanetaryPosition(
        planetName: 'Sun',
        longitude: sunLongitude,
        latitude: 0.0,
        distance: 1.0,
        speed: 1.0,
        zodiacSign: sunSign,
        degreesInSign: sunDegrees,
        minutesInSign: sunMinutes.floor(),
        secondsInSign: sunSeconds.floor(),
      ),
    ];

    // Create simplified house positions
    final houses = <HousePosition>[
      HousePosition(
        houseNumber: 1,
        longitude: sunLongitude,
        zodiacSign: sunSign,
        degreesInSign: sunDegrees,
        minutesInSign: sunMinutes.floor(),
        secondsInSign: sunSeconds.floor(),
      ),
    ];

    // Create ascendant and midheaven
    final midheavenLongitude = (sunLongitude + 90) % 360;
    final midheavenSign = _longitudeToSign(midheavenLongitude);
    final midheavenDegrees = midheavenLongitude % 30;
    final midheavenMinutes = (midheavenDegrees % 1) * 60;
    final midheavenSeconds = (midheavenMinutes % 1) * 60;
    
    final ascendant = PlanetaryPosition(
      planetName: 'Ascendant',
      longitude: sunLongitude,
      latitude: 0.0,
      distance: 0.0,
      speed: 0.0,
      zodiacSign: sunSign,
      degreesInSign: sunDegrees,
      minutesInSign: sunMinutes.floor(),
      secondsInSign: sunSeconds.floor(),
    );
    
    final midheaven = PlanetaryPosition(
      planetName: 'Midheaven',
      longitude: midheavenLongitude,
      latitude: 0.0,
      distance: 0.0,
      speed: 0.0,
      zodiacSign: midheavenSign,
      degreesInSign: midheavenDegrees,
      minutesInSign: midheavenMinutes.floor(),
      secondsInSign: midheavenSeconds.floor(),
    );

    return BirthChart(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      planets: planets,
      houses: houses,
      ascendant: ascendant,
      midheaven: midheaven,
    );
  }

  double _getSunLongitude(int month, int day) {
    // Simplified: approximate sun position based on date
    final dayOfYear = DateTime(2024, month, day).difference(DateTime(2024, 1, 1)).inDays;
    // Sun moves ~1 degree per day, starting at ~280 degrees (Capricorn) on Jan 1
    return (280 + dayOfYear) % 360;
  }

  String _longitudeToSign(double longitude) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final normalized = longitude % 360;
    final signIndex = (normalized / 30).floor();
    return signs[signIndex.clamp(0, signs.length - 1)];
  }
}
