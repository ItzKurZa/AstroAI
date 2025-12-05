import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../domain/entities/birth_chart.dart';
import '../domain/entities/planetary_position.dart';
import '../domain/entities/house_position.dart';
import '../utils/time_converter.dart';

/// FreeAstrologyAPI Service
/// 
/// Integrates with freeastrologyapi.com to fetch astrological data
/// and sync with Firebase.
class FreeAstrologyApiService {
  static FreeAstrologyApiService? _instance;
  static FreeAstrologyApiService get instance {
    _instance ??= FreeAstrologyApiService._();
    return _instance!;
  }

  // Track if we've already logged network errors to avoid spam
  bool _hasLoggedNetworkError = false;
  // Track if API has failed (network error) - if true, skip all future API calls
  bool _apiHasFailed = false;

  FreeAstrologyApiService._()
      : _baseUrl = _getBaseUrl(),
        _apiKey = dotenv.env['ASTROLOGY_API_KEY'] {
    // Log API configuration (without exposing key)
    final hasKey = _apiKey != null && _apiKey.isNotEmpty;
    final hasBaseUrl = _baseUrl.isNotEmpty;
    final envUrl = dotenv.env['ASTROLOGY_API_BASE_URL'];
    final usingDefault = envUrl == null || envUrl.trim().isEmpty;
    
    if (usingDefault) {
      print('🔧 FreeAstrologyAPI configured: baseUrl=$_baseUrl (using default), hasApiKey=$hasKey');
    } else {
      print('🔧 FreeAstrologyAPI configured: baseUrl=$_baseUrl (from .env), hasApiKey=$hasKey');
    }
    
    if (!hasBaseUrl) {
      print('⚠️ No base URL found. API calls will be skipped. Using local calculation as fallback.');
    } else if (!hasKey) {
      print('⚠️ No API key found. API calls will likely fail. Using local calculation as fallback.');
    } else {
      print('✅ FreeAstrologyAPI is ready to use.');
    }
  }

  /// Get base URL from environment or use default
  static String _getBaseUrl() {
    final envUrl = dotenv.env['ASTROLOGY_API_BASE_URL'];
    // Check if envUrl exists and is not empty after trimming
    if (envUrl != null && envUrl.trim().isNotEmpty) {
      return envUrl.trim();
    }
    // Default base URL if not configured or empty
    // This is the official FreeAstrologyAPI endpoint
    return 'https://api.freeastrologyapi.com';
  }
  
  /// Check if API is available (has base URL and key)
  bool get isAvailable {
    // If API has failed (network error), don't try again
    if (_apiHasFailed) return false;
    if (_baseUrl.isEmpty) return false;
    if (_apiKey == null) return false;
    return _apiKey.isNotEmpty;
  }

  final String _baseUrl;
  final String? _apiKey;

  /// Get birth chart data from API
  /// 
  /// Parameters:
  /// - birthDate: DateTime of birth
  /// - birthTime: Time of birth (HH:mm format)
  /// - latitude: Birth location latitude
  /// - longitude: Birth location longitude
  /// - timezone: Timezone offset (e.g., "+07:00")
  Future<Map<String, dynamic>> getBirthChart({
    required DateTime birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    String? timezone,
  }) async {
    // Skip API call if it has already failed (network error)
    if (_apiHasFailed) {
      throw Exception('FreeAstrologyAPI is unavailable (previous network error). Using fallback calculation.');
    }
    
    try {
      // Format date and time
      final dateStr = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      // Convert time to 24-hour format if needed
      final timeStr = TimeConverter.convertTo24Hour(birthTime); // Expected format: "HH:mm"
      
      // Build request URL
      final queryParams = {
        'date': dateStr,
        'time': timeStr,
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        if (timezone != null) 'timezone': timezone,
      };

      final uri = Uri.parse('$_baseUrl/birth-chart').replace(queryParameters: queryParams);
      
      http.Response response;
      try {
        response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (_apiKey != null) 'X-API-Key': _apiKey,
          if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
        },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('FreeAstrologyAPI request timeout. The API may be unavailable or network is slow.');
          },
        );
      } on http.ClientException catch (e) {
        // Network errors (DNS, connection refused, etc.)
        // Mark API as failed to skip future calls
        _apiHasFailed = true;
        // Only log once to avoid console spam
        if (!_hasLoggedNetworkError) {
          print('⚠️ FreeAstrologyAPI unavailable (network/DNS error). Using fallback calculation.');
          print('ℹ️ This error will not be shown again. App will continue using local calculations.');
          _hasLoggedNetworkError = true;
        }
        throw Exception('Network error connecting to FreeAstrologyAPI: ${e.message}. The API endpoint may be unavailable or incorrect. Using fallback calculation.');
      } catch (e) {
        // Other errors (timeout, etc.)
        if (e.toString().contains('timeout') || e.toString().contains('Timeout') || 
            e.toString().contains('ERR_NAME_NOT_RESOLVED') || 
            e.toString().contains('Failed to fetch')) {
          _apiHasFailed = true;
          if (!_hasLoggedNetworkError) {
            print('⚠️ FreeAstrologyAPI request timeout/network error. Using fallback calculation.');
            _hasLoggedNetworkError = true;
          }
          throw Exception('FreeAstrologyAPI request timeout. The API may be unavailable or network is slow. Using fallback calculation.');
        }
        if (!_hasLoggedNetworkError) {
          print('⚠️ FreeAstrologyAPI connection failed. Using fallback calculation.');
          _hasLoggedNetworkError = true;
        }
        throw Exception('Failed to connect to FreeAstrologyAPI: $e. Using fallback calculation.');
      }

      if (response.statusCode != 200) {
        throw Exception('FreeAstrologyAPI error: ${response.statusCode} - ${response.body}');
      }

      // Check if response is JSON (not HTML error page)
      final contentType = response.headers['content-type'] ?? '';
      final bodyTrimmed = response.body.trim();
      
      // Check if response is HTML
      if (bodyTrimmed.startsWith('<!DOCTYPE') || 
          bodyTrimmed.startsWith('<html') || 
          bodyTrimmed.startsWith('<HTML')) {
        throw Exception('FreeAstrologyAPI returned HTML instead of JSON. The API endpoint may not be available or incorrect. Please check the API base URL in .env file.');
      }
      
      if (!contentType.contains('application/json') && bodyTrimmed.isNotEmpty) {
        // Response is not JSON, likely an HTML error page
        throw Exception('FreeAstrologyAPI returned non-JSON response (content-type: $contentType). The API endpoint may not be available or incorrect.');
      }

      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } catch (e) {
        // If JSON decode fails, provide more context
        throw Exception('Failed to parse FreeAstrologyAPI response as JSON: $e. Response body: ${bodyTrimmed.length > 200 ? bodyTrimmed.substring(0, 200) + "..." : bodyTrimmed}');
      }
    } catch (e) {
      // Re-throw with more context if it's not already wrapped
      if (e.toString().contains('FreeAstrologyAPI') || e.toString().contains('Network error') || e.toString().contains('timeout')) {
        rethrow;
      }
      throw Exception('Failed to fetch birth chart from FreeAstrologyAPI: $e');
    }
  }

  /// Get daily horoscope from API
  Future<Map<String, dynamic>> getDailyHoroscope({
    required String sunSign,
    DateTime? date,
  }) async {
    // Skip API call if it has already failed (network error)
    if (_apiHasFailed) {
      throw Exception('FreeAstrologyAPI is unavailable (previous network error). Using fallback calculation.');
    }
    
    try {
      final dateStr = date != null
          ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          : null;

      final queryParams = {
        'sign': sunSign.toLowerCase(),
        if (dateStr != null) 'date': dateStr,
      };

      final uri = Uri.parse('$_baseUrl/horoscope/daily').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (_apiKey != null) 'X-API-Key': _apiKey,
          if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('FreeAstrologyAPI error: ${response.statusCode} - ${response.body}');
      }

      // Check if response is JSON (not HTML error page)
      final contentType = response.headers['content-type'] ?? '';
      final bodyTrimmed = response.body.trim();
      
      // Check if response is HTML
      if (bodyTrimmed.startsWith('<!DOCTYPE') || 
          bodyTrimmed.startsWith('<html') || 
          bodyTrimmed.startsWith('<HTML')) {
        throw Exception('FreeAstrologyAPI returned HTML instead of JSON. The API endpoint may not be available or incorrect. Please check the API base URL in .env file.');
      }
      
      if (!contentType.contains('application/json') && bodyTrimmed.isNotEmpty) {
        // Response is not JSON, likely an HTML error page
        throw Exception('FreeAstrologyAPI returned non-JSON response (content-type: $contentType). The API endpoint may not be available or incorrect.');
      }

      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } catch (e) {
        // If JSON decode fails, provide more context
        throw Exception('Failed to parse FreeAstrologyAPI response as JSON: $e. Response body: ${bodyTrimmed.length > 200 ? bodyTrimmed.substring(0, 200) + "..." : bodyTrimmed}');
      }
    } catch (e) {
      throw Exception('Failed to fetch horoscope from FreeAstrologyAPI: $e');
    }
  }

  /// Get planetary positions from API
  Future<List<PlanetaryPosition>> getPlanetaryPositions({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    // Skip API call if it has already failed (network error)
    if (_apiHasFailed) {
      throw Exception('FreeAstrologyAPI is unavailable (previous network error). Using fallback calculation.');
    }
    
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final queryParams = {
        'date': dateStr,
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      };

      final uri = Uri.parse('$_baseUrl/planetary-positions').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (_apiKey != null) 'X-API-Key': _apiKey,
          if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('FreeAstrologyAPI error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final planetsData = data['planets'] as List<dynamic>? ?? [];

      return planetsData.map((planet) {
        final name = planet['name'] as String;
        final longitude = (planet['longitude'] as num).toDouble();
        final latitude = (planet['latitude'] as num?)?.toDouble() ?? 0.0;
        final distance = (planet['distance'] as num?)?.toDouble() ?? 1.0;
        final speed = (planet['speed'] as num?)?.toDouble() ?? 0.0;

        final zodiacSign = _longitudeToSign(longitude);
        final degreesInSign = _getDegreesInSign(longitude);
        final (deg, min, sec) = _degreesToDMS(degreesInSign);

        return PlanetaryPosition(
          planetName: name,
          longitude: longitude,
          latitude: latitude,
          distance: distance,
          speed: speed,
          zodiacSign: zodiacSign,
          degreesInSign: degreesInSign,
          minutesInSign: min,
          secondsInSign: sec,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch planetary positions from FreeAstrologyAPI: $e');
    }
  }

  /// Get house cusps from API
  Future<List<HousePosition>> getHouseCusps({
    required DateTime date,
    required double latitude,
    required double longitude,
    String houseSystem = 'placidus',
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final queryParams = {
        'date': dateStr,
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'house_system': houseSystem,
      };

      final uri = Uri.parse('$_baseUrl/houses').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (_apiKey != null) 'X-API-Key': _apiKey,
          if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('FreeAstrologyAPI error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final housesData = data['houses'] as List<dynamic>? ?? [];

      return housesData.map((house) {
        final houseNumber = house['house'] as int;
        final cuspLongitude = (house['longitude'] as num).toDouble();
        final zodiacSign = _longitudeToSign(cuspLongitude);
        final degreesInSign = _getDegreesInSign(cuspLongitude);
        final (deg, min, sec) = _degreesToDMS(degreesInSign);

        return HousePosition(
          houseNumber: houseNumber,
          longitude: cuspLongitude,
          zodiacSign: zodiacSign,
          degreesInSign: degreesInSign,
          minutesInSign: min,
          secondsInSign: sec,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch house cusps from FreeAstrologyAPI: $e');
    }
  }

  /// Convert API response to BirthChart entity
  BirthChart parseBirthChartResponse(
    Map<String, dynamic> apiData, {
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) {
    try {
      final planetsData = apiData['planets'] as List<dynamic>? ?? [];
      final housesData = apiData['houses'] as List<dynamic>? ?? [];

      final planets = planetsData.map((planet) {
        final name = planet['name'] as String;
        final longitude = (planet['longitude'] as num).toDouble();
        final latitude = (planet['latitude'] as num?)?.toDouble() ?? 0.0;
        final distance = (planet['distance'] as num?)?.toDouble() ?? 1.0;
        final speed = (planet['speed'] as num?)?.toDouble() ?? 0.0;

        final zodiacSign = _longitudeToSign(longitude);
        final degreesInSign = _getDegreesInSign(longitude);
        final (deg, min, sec) = _degreesToDMS(degreesInSign);

        return PlanetaryPosition(
          planetName: name,
          longitude: longitude,
          latitude: latitude,
          distance: distance,
          speed: speed,
          zodiacSign: zodiacSign,
          degreesInSign: degreesInSign,
          minutesInSign: min,
          secondsInSign: sec,
        );
      }).toList();

      final houses = housesData.map((house) {
        final houseNumber = house['house'] as int;
        final cuspLongitude = (house['longitude'] as num).toDouble();
        final zodiacSign = _longitudeToSign(cuspLongitude);
        final degreesInSign = _getDegreesInSign(cuspLongitude);
        final (deg, min, sec) = _degreesToDMS(degreesInSign);

        return HousePosition(
          houseNumber: houseNumber,
          longitude: cuspLongitude,
          zodiacSign: zodiacSign,
          degreesInSign: degreesInSign,
          minutesInSign: min,
          secondsInSign: sec,
        );
      }).toList();

      // Extract ascendant and midheaven from houses
      final ascendantHouse = houses.firstWhere(
        (h) => h.houseNumber == 1,
        orElse: () => houses.first,
      );
      final midheavenHouse = houses.firstWhere(
        (h) => h.houseNumber == 10,
        orElse: () => houses.length > 9 ? houses[9] : houses.first,
      );

      // Create ascendant and midheaven as PlanetaryPosition
      final ascendant = PlanetaryPosition(
        planetName: 'Ascendant',
        longitude: ascendantHouse.longitude,
        latitude: 0.0,
        distance: 0.0,
        speed: 0.0,
        zodiacSign: ascendantHouse.zodiacSign,
        degreesInSign: ascendantHouse.degreesInSign,
        minutesInSign: ascendantHouse.minutesInSign,
        secondsInSign: ascendantHouse.secondsInSign,
      );

      final midheaven = PlanetaryPosition(
        planetName: 'Midheaven',
        longitude: midheavenHouse.longitude,
        latitude: 0.0,
        distance: 0.0,
        speed: 0.0,
        zodiacSign: midheavenHouse.zodiacSign,
        degreesInSign: midheavenHouse.degreesInSign,
        minutesInSign: midheavenHouse.minutesInSign,
        secondsInSign: midheavenHouse.secondsInSign,
      );

      // Note: We need birthDateTime, latitude, longitude from the original request
      // For now, we'll use defaults - these should be passed from the caller
      return BirthChart(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        planets: planets,
        houses: houses,
        ascendant: ascendant,
        midheaven: midheaven,
      );
    } catch (e) {
      throw Exception('Failed to parse birth chart response: $e');
    }
  }

  /// Helper: Convert longitude to zodiac sign
  String _longitudeToSign(double longitude) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final normalized = longitude % 360;
    if (normalized < 0) {
      return signs[0];
    }
    final signIndex = (normalized / 30).floor();
    return signs[signIndex.clamp(0, signs.length - 1)];
  }

  /// Helper: Get degrees within sign
  double _getDegreesInSign(double longitude) {
    final normalized = longitude % 360;
    if (normalized < 0) {
      return 0.0;
    }
    return normalized % 30;
  }

  /// Helper: Convert degrees to DMS
  (int, int, int) _degreesToDMS(double degrees) {
    final totalSeconds = (degrees * 3600).round();
    final d = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return (d, m, s);
  }
}

