import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/birth_chart.dart';
import '../data/models/birth_chart_model.dart';
import '../firebase/firestore_paths.dart';
import '../utils/time_converter.dart';
import 'freeastrology_api_service.dart';
import 'astrology_calculator.dart';
import 'local_cache_service.dart';

/// Service to sync FreeAstrologyAPI data with Firebase
class FreeAstrologyFirebaseSync {
  static FreeAstrologyFirebaseSync? _instance;
  static FreeAstrologyFirebaseSync get instance {
    _instance ??= FreeAstrologyFirebaseSync._();
    return _instance!;
  }

  FreeAstrologyFirebaseSync._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FreeAstrologyApiService _apiService = FreeAstrologyApiService.instance;
  final AstrologyCalculator _calculator = AstrologyCalculator.instance;

  /// Sync birth chart data from API to Firebase for a user
  /// 
  /// This will:
  /// 1. Check Firebase first - if exists and valid, skip API call
  /// 2. Only call API if data doesn't exist or user info changed
  /// 3. Store it in Firebase under users/{userId}/birthChart
  /// 4. Update user profile with astrological signs
  /// 
  /// Note: Birth Chart only changes when user updates personal info (birthDate, birthTime, birthPlace)
  /// So we check if user info matches cached data before calling API
  Future<void> syncUserBirthChart({
    required String userId,
    required DateTime birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    String? timezone,
    bool forceSync = false, // Only sync if user explicitly updates personal info
  }) async {
    // Check Firebase first - Birth Chart doesn't need daily refresh
    if (!forceSync) {
      try {
        final birthChartDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('astrology')
            .doc('birthChart')
            .get();

        if (birthChartDoc.exists) {
          final data = birthChartDoc.data();
          // Check if cached data matches current user info
          final cachedBirthDate = data?['birthDate'] as String?;
          final cachedBirthTime = data?['birthTime'] as String?;
          final cachedLat = (data?['latitude'] as num?)?.toDouble();
          final cachedLng = (data?['longitude'] as num?)?.toDouble();
          
          // Format current birth date for comparison
          final currentBirthDateStr = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
          final currentBirthTime24 = TimeConverter.convertTo24Hour(birthTime);
          
          // If user info matches, use cached data (no API call needed)
          if (cachedBirthDate == currentBirthDateStr &&
              cachedBirthTime == currentBirthTime24 &&
              (cachedLat == null || (cachedLat - latitude).abs() < 0.001) &&
              (cachedLng == null || (cachedLng - longitude).abs() < 0.001)) {
            print('✅ Birth chart already exists in Firebase and matches user info - skipping API call');
            return;
          }
        }
      } catch (e) {
        print('⚠️ Error checking cached birth chart: $e - will proceed with API call');
      }
    }

    // Check if API is available before trying
    if (!_apiService.isAvailable) {
      print('⚠️ FreeAstrologyAPI not available, using local calculation');
      await _syncWithLocalCalculation(
        userId: userId,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
      );
      return;
    }
    
    try {
      print('📡 Fetching birth chart from FreeAstrologyAPI...');
      // Fetch birth chart from API
      final apiData = await _apiService.getBirthChart(
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      // Parse time - convert from 12-hour to 24-hour format if needed
      final time24Hour = TimeConverter.convertTo24Hour(birthTime);
      final timeParts = time24Hour.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 12;
      final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
      final birthDateTime = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        hour,
        minute,
      );

      // Parse to BirthChart entity
      final birthChart = _apiService.parseBirthChartResponse(
        apiData,
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
      );

      // Convert to model for Firestore
      final birthChartModel = BirthChartModel.fromBirthChart(birthChart);
      final chartMap = birthChartModel.toMap();
      
      // Add user info for comparison on next sync
      chartMap['birthDate'] = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      chartMap['birthTime'] = time24Hour;
      chartMap['latitude'] = latitude;
      chartMap['longitude'] = longitude;
      chartMap['updatedAt'] = FieldValue.serverTimestamp();

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('astrology')
          .doc('birthChart')
          .set(chartMap, SetOptions(merge: true));

      // Cache locally for fast access
      await LocalCacheService.instance.saveBirthChart(userId, chartMap);

      // Update user profile with astrological signs
      await _updateUserAstrologicalSigns(userId, birthChart);

      print('✅ Successfully synced birth chart for user $userId');
    } catch (e) {
      print('❌ Error syncing birth chart: $e');
      // Fallback to local calculation if API fails
      await _syncWithLocalCalculation(
        userId: userId,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  /// Sync daily horoscope from API to Firebase
  /// 
  /// IMPORTANT: Always checks Firebase cache first to avoid spam API requests.
  /// Only calls API if:
  /// 1. Data doesn't exist in Firebase, OR
  /// 2. Data is older than 1 day (needs daily refresh)
  /// 
  /// After fetching from API, data is automatically saved to Firebase for future use.
  /// Auto-refreshes once per day
  Future<void> syncDailyHoroscope({
    required String sunSign,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = FirestorePaths.dateId(targetDate);
    
    // Check Firebase first - only call API if data doesn't exist or is older than 1 day
    try {
      final horoscopeDoc = await _firestore
          .collection('horoscopes')
          .doc(dateStr)
          .collection('signs')
          .doc(sunSign.toLowerCase())
          .get();

      if (horoscopeDoc.exists) {
        final data = horoscopeDoc.data();
        final updatedAt = data?['updatedAt'] as Timestamp?;
        
        if (updatedAt != null) {
          final now = DateTime.now();
          final dataDate = updatedAt.toDate();
          final difference = now.difference(dataDate);
          
          // If data is less than 1 day old, use cached data (no API call)
          if (difference.inDays < 1 && 
              dataDate.year == now.year && 
              dataDate.month == now.month && 
              dataDate.day == now.day) {
            print('✅ Daily horoscope for $sunSign on $dateStr already exists and is fresh - skipping API call');
            return;
          }
        } else {
          // If updatedAt is missing, check if content exists
          if (data?['content'] != null) {
            print('✅ Daily horoscope for $sunSign on $dateStr exists - skipping API call');
            return;
          }
        }
      }
    } catch (e) {
      print('⚠️ Error checking cached horoscope: $e - will proceed with API call');
    }

    // Only call API if data doesn't exist or is older than 1 day
    // Check if API is available first
    if (!_apiService.isAvailable) {
      print('⚠️ FreeAstrologyAPI not available (base URL or API key missing) - skipping daily horoscope sync');
      return;
    }
    
    try {
      print('📡 Fetching daily horoscope from FreeAstrologyAPI for $sunSign on $dateStr...');
      final horoscopeData = await _apiService.getDailyHoroscope(
        sunSign: sunSign,
        date: targetDate,
      );

      // Save to Firestore
      await _firestore
          .collection('horoscopes')
          .doc(dateStr)
          .collection('signs')
          .doc(sunSign.toLowerCase())
          .set({
        'sign': sunSign,
        'date': dateStr,
        'content': horoscopeData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Successfully synced daily horoscope for $sunSign on $dateStr');
    } catch (e) {
      // Horoscope can be generated locally, so this is non-critical
      print('⚠️ Error syncing daily horoscope (non-critical, can use local generation): $e');
      // Don't rethrow - horoscope is optional
    }
  }

  /// Sync planetary positions from API to Firebase
  /// Sync planetary positions from API to Firebase
  /// 
  /// IMPORTANT: Always checks Firebase cache first to avoid spam API requests.
  /// Only calls API if data doesn't exist in Firebase.
  /// After fetching from API, data is automatically saved to Firebase for future use.
  Future<void> syncPlanetaryPositions({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    final dateStr = FirestorePaths.dateId(date);
    
    // Check Firebase first - only call API if data doesn't exist
    try {
      final doc = await _firestore
          .collection('planets_today')
          .doc(dateStr)
          .get();
      
      if (doc.exists) {
        print('✅ Planetary positions for $dateStr already cached in Firebase - skipping API call');
        return;
      }
    } catch (e) {
      print('⚠️ Error checking cached planetary positions: $e - will proceed with API call');
    }
    
    // Check if API is available first
    if (!_apiService.isAvailable) {
      print('⚠️ FreeAstrologyAPI not available - skipping planetary positions sync');
      return;
    }
    
    try {
      final planets = await _apiService.getPlanetaryPositions(
        date: date,
        latitude: latitude,
        longitude: longitude,
      );

      final dateStr = FirestorePaths.dateId(date);

      // Convert to Firestore format
      final planetsData = planets.map((planet) => {
        'name': planet.planetName,
        'longitude': planet.longitude,
        'latitude': planet.latitude,
        'distance': planet.distance,
        'speed': planet.speed,
        'zodiacSign': planet.zodiacSign,
        'degreesInSign': planet.degreesInSign,
        'minutesInSign': planet.minutesInSign,
        'secondsInSign': planet.secondsInSign,
      }).toList();

      // Save to Firestore
      await _firestore
          .collection('planets_today')
          .doc(dateStr)
          .set({
        'date': dateStr,
        'planets': planetsData,
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'freeastrologyapi',
      }, SetOptions(merge: true));

      print('✅ Successfully synced planetary positions for $dateStr');
    } catch (e) {
      print('❌ Error syncing planetary positions: $e');
    }
  }

  /// Sync house cusps from API to Firebase
  /// 
  /// Note: House cusps are already included in birth chart, so this is optional
  Future<void> syncHouseCusps({
    required String userId,
    required DateTime date,
    required double latitude,
    required double longitude,
    String houseSystem = 'placidus',
  }) async {
    // Check if API is available first
    if (!_apiService.isAvailable) {
      print('⚠️ FreeAstrologyAPI not available - skipping house cusps sync (non-critical, already in birth chart)');
      return;
    }
    
    try {
      final houses = await _apiService.getHouseCusps(
        date: date,
        latitude: latitude,
        longitude: longitude,
        houseSystem: houseSystem,
      );

      final dateStr = FirestorePaths.dateId(date);

      // Convert to Firestore format
      final housesData = houses.map((house) => {
        'houseNumber': house.houseNumber,
        'longitude': house.longitude,
        'zodiacSign': house.zodiacSign,
        'degreesInSign': house.degreesInSign,
        'minutesInSign': house.minutesInSign,
        'secondsInSign': house.secondsInSign,
      }).toList();

      // Save to Firestore under user's astrology data
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('astrology')
          .doc('houses')
          .set({
        'date': dateStr,
        'houses': housesData,
        'houseSystem': houseSystem,
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'freeastrologyapi',
      }, SetOptions(merge: true));

      print('✅ Successfully synced house cusps for user $userId on $dateStr');
    } catch (e) {
      // House cusps are already in birth chart, so this is non-critical
      print('⚠️ Error syncing house cusps (non-critical, already in birth chart): $e');
      // Don't rethrow - house cusps are optional since they're in birth chart
    }
  }

  /// Update user profile with astrological signs from birth chart
  Future<void> _updateUserAstrologicalSigns(
    String userId,
    BirthChart birthChart,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'sunSign': birthChart.sunSign,
        'moonSign': birthChart.moonSign,
        'ascendantSign': birthChart.ascendantSign,
        'astrologyUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error updating astrological signs: $e');
    }
  }

  /// Fallback: sync with local calculation if API fails
  Future<void> _syncWithLocalCalculation({
    required String userId,
    required DateTime birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Parse time - convert from 12-hour to 24-hour format if needed
      final time24Hour = TimeConverter.convertTo24Hour(birthTime);
      final timeParts = time24Hour.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 12;
      final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
      final birthDateTime = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        hour,
        minute,
      );

      // Calculate using local calculator
      final birthChart = await _calculator.calculateBirthChart(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
      );

      // Convert to model
      final birthChartModel = BirthChartModel.fromBirthChart(birthChart);
      final chartMap = birthChartModel.toMap();
      
      // Add user info for comparison on next sync
      chartMap['birthDate'] = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      chartMap['birthTime'] = time24Hour;
      chartMap['latitude'] = latitude;
      chartMap['longitude'] = longitude;
      chartMap['updatedAt'] = FieldValue.serverTimestamp();

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('astrology')
          .doc('birthChart')
          .set(chartMap, SetOptions(merge: true));

      // Cache locally for fast access
      await LocalCacheService.instance.saveBirthChart(userId, chartMap);

      // Update user profile
      await _updateUserAstrologicalSigns(userId, birthChart);

      print('✅ Successfully synced birth chart using local calculation for user $userId');
    } catch (e) {
      print('❌ Error syncing with local calculation: $e');
      rethrow;
    }
  }

  /// Sync user characteristics (Sun, Moon, Ascendant) from birth chart
  /// 
  /// This will:
  /// 1. Get birth chart from Firebase (already synced)
  /// 2. Calculate house numbers for Sun, Moon, and Ascendant
  /// 3. Save to characteristics collection with user-specific data
  /// 4. Cache locally
  Future<void> syncUserCharacteristics({
    required String userId,
  }) async {
    try {
      // Get birth chart from Firebase
      final birthChartDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('astrology')
          .doc('birthChart')
          .get();

      if (!birthChartDoc.exists) {
        print('⚠️ Birth chart not found for user $userId, cannot sync characteristics');
        return;
      }

      final chartData = birthChartDoc.data()!;
      final planetsData = chartData['planets'] as List<dynamic>? ?? [];
      final housesData = chartData['houses'] as List<dynamic>? ?? [];
      final ascendantData = chartData['ascendant'] as Map<String, dynamic>?;

      if (planetsData.isEmpty || housesData.isEmpty) {
        print('⚠️ Birth chart data incomplete, cannot sync characteristics');
        return;
      }

      // Find Sun and Moon planets
      final sunPlanet = planetsData.firstWhere(
        (p) => (p['planetName'] as String).toLowerCase() == 'sun',
        orElse: () => null,
      );
      final moonPlanet = planetsData.firstWhere(
        (p) => (p['planetName'] as String).toLowerCase() == 'moon',
        orElse: () => null,
      );

      if (sunPlanet == null || moonPlanet == null || ascendantData == null) {
        print('⚠️ Missing Sun, Moon, or Ascendant data');
        return;
      }

      // Calculate house numbers
      final sunHouse = _calculateHouseNumber(
        planetLongitude: (sunPlanet['longitude'] as num).toDouble(),
        houses: housesData,
      );
      final moonHouse = _calculateHouseNumber(
        planetLongitude: (moonPlanet['longitude'] as num).toDouble(),
        houses: housesData,
      );
      final ascendantHouse = 1; // Ascendant is always 1st house

      // Get zodiac signs
      final sunSign = sunPlanet['zodiacSign'] as String? ?? 'Unknown';
      final moonSign = moonPlanet['zodiacSign'] as String? ?? 'Unknown';
      final ascendantSign = ascendantData['zodiacSign'] as String? ?? 'Unknown';

      // Helper to format house number
      String _formatHouseNumber(int houseNum) {
        if (houseNum == 1) return '1st House';
        if (houseNum == 2) return '2nd House';
        if (houseNum == 3) return '3rd House';
        return '${houseNum}th House';
      }

      // Create characteristics
      final characteristics = [
        {
          'id': '${userId}_sun',
          'title': 'Sun in $sunSign',
          'house': _formatHouseNumber(sunHouse),
          'description': _getPlanetDescription('Sun', sunSign),
          'imageUrl': 'assets/images/app/planets/Sun.png',
          'order': 0,
          'userId': userId, // User-specific
        },
        {
          'id': '${userId}_moon',
          'title': 'Moon in $moonSign',
          'house': _formatHouseNumber(moonHouse),
          'description': _getPlanetDescription('Moon', moonSign),
          'imageUrl': 'assets/images/app/planets/Moon.png',
          'order': 1,
          'userId': userId,
        },
        {
          'id': '${userId}_ac',
          'title': 'AC in $ascendantSign',
          'house': _formatHouseNumber(ascendantHouse),
          'description': _getPlanetDescription('Ascendant', ascendantSign),
          'imageUrl': 'assets/images/app/planets/Venus.png', // AC uses Venus symbol
          'order': 2,
          'userId': userId,
        },
      ];

      // Save to Firestore (user-specific characteristics)
      final batch = _firestore.batch();
      for (final char in characteristics) {
        final docRef = _firestore
            .collection('characteristics')
            .doc(char['id'] as String);
        batch.set(docRef, char, SetOptions(merge: true));
      }
      await batch.commit();

      // Cache locally
      await LocalCacheService.instance.saveCharacteristics(userId, characteristics);

      print('✅ Successfully synced characteristics for user $userId');
    } catch (e) {
      print('❌ Error syncing characteristics: $e');
      // Don't rethrow - characteristics are non-critical
    }
  }

  /// Calculate which house a planet is in based on its longitude
  int _calculateHouseNumber({
    required double planetLongitude,
    required List<dynamic> houses,
  }) {
    // Normalize longitude to 0-360
    double normalized = planetLongitude % 360;
    if (normalized < 0) normalized += 360;

    // Convert to list of maps with house numbers
    final housesList = houses.map((h) {
      final houseMap = h as Map<String, dynamic>;
      // Get house number from 'houseNumber' or 'house' field
      final houseNum = houseMap['houseNumber'] ?? houseMap['house'];
      return {
        'houseNumber': houseNum is int ? houseNum : (houseNum is num ? houseNum.toInt() : 1),
        'longitude': (houseMap['longitude'] as num).toDouble(),
      };
    }).toList();

    // Sort houses by longitude
    housesList.sort((a, b) {
      final aLon = (a['longitude'] as num).toDouble() % 360;
      final bLon = (b['longitude'] as num).toDouble() % 360;
      return aLon.compareTo(bLon);
    });

    // Find which house the planet is in
    // A planet is in a house if its longitude is between the house cusp and the next house cusp
    for (int i = 0; i < housesList.length; i++) {
      final currentHouse = housesList[i];
      final nextHouse = housesList[(i + 1) % housesList.length];
      
      final currentCusp = (currentHouse['longitude'] as num).toDouble() % 360;
      final nextCusp = (nextHouse['longitude'] as num).toDouble() % 360;
      
      // Handle wrap-around (when next cusp is before current cusp)
      if (nextCusp < currentCusp) {
        if (normalized >= currentCusp || normalized < nextCusp) {
          return currentHouse['houseNumber'] as int;
        }
      } else {
        if (normalized >= currentCusp && normalized < nextCusp) {
          return currentHouse['houseNumber'] as int;
        }
      }
    }

    // Fallback: return 1st house if calculation fails
    return 1;
  }

  /// Get planet description based on planet and sign
  String _getPlanetDescription(String planetName, String zodiacSign) {
    const descriptions = {
      'Sun': {
        'Leo': 'You are fundamentally bold and proud. You love attention and pay it back with charm.',
        'Aries': 'You are a natural leader with fiery energy and initiative.',
        'Taurus': 'You value stability, beauty, and material comfort.',
        'Gemini': 'You are curious, communicative, and adaptable.',
        'Cancer': 'You are nurturing, emotional, and deeply intuitive.',
        'Virgo': 'You are analytical, practical, and service-oriented.',
        'Libra': 'You seek harmony, balance, and partnership.',
        'Scorpio': 'You are intense, transformative, and deeply passionate.',
        'Sagittarius': 'You are adventurous, philosophical, and freedom-loving.',
        'Capricorn': 'You are ambitious, disciplined, and goal-oriented.',
        'Aquarius': 'You are innovative, independent, and humanitarian.',
        'Pisces': 'You are intuitive, compassionate, and spiritually connected.',
      },
      'Moon': {
        'Virgo': 'Sensitive and intuitive. You rarely express feelings openly, relying on reason.',
        'Aries': 'Your emotions are quick and fiery, expressing impulsively.',
        'Taurus': 'You seek emotional security and comfort through stability.',
        'Gemini': 'Your emotions are changeable and you process feelings through communication.',
        'Cancer': 'You are deeply emotional, nurturing, and protective.',
        'Leo': 'Your emotions are dramatic and you express them with warmth and creativity.',
        'Libra': 'You seek emotional harmony and balance in relationships.',
        'Scorpio': 'Your emotions are intense, deep, and transformative.',
        'Sagittarius': 'You process emotions through adventure and philosophical exploration.',
        'Capricorn': 'You control emotions and seek emotional security through achievement.',
        'Aquarius': 'You process emotions intellectually and value emotional freedom.',
        'Pisces': 'You are highly intuitive and emotionally connected to the collective.',
      },
      'Ascendant': {
        'Libra': 'Gives the ability to find a common language with almost any person.',
        'Aries': 'You present yourself as confident, assertive, and independent.',
        'Taurus': 'You appear stable, calm, and grounded to others.',
        'Gemini': 'You come across as curious, communicative, and adaptable.',
        'Cancer': 'You appear nurturing, sensitive, and protective.',
        'Leo': 'You present yourself as confident, creative, and charismatic.',
        'Virgo': 'You appear analytical, practical, and detail-oriented.',
        'Scorpio': 'You present yourself as intense, mysterious, and powerful.',
        'Sagittarius': 'You appear adventurous, optimistic, and freedom-loving.',
        'Capricorn': 'You present yourself as serious, ambitious, and responsible.',
        'Aquarius': 'You appear unique, independent, and forward-thinking.',
        'Pisces': 'You present yourself as dreamy, intuitive, and compassionate.',
      },
    };

    final planetDescs = descriptions[planetName];
    if (planetDescs != null && planetDescs.containsKey(zodiacSign)) {
      return planetDescs[zodiacSign]!;
    }

    // Fallback description
    return '$planetName in $zodiacSign influences your chart with unique energy.';
  }

  /// Sync all astrology data for a user
  /// 
  /// This is a convenience method that syncs:
  /// - Birth chart
  /// - House cusps
  /// - Characteristics (Sun, Moon, Ascendant)
  /// - Daily horoscope (if sun sign is available)
  Future<void> syncAllUserAstrologyData({
    required String userId,
    required DateTime birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    String? timezone,
    String? sunSign,
  }) async {
    try {
      // Sync birth chart
      await syncUserBirthChart(
        userId: userId,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      // Sync characteristics (Sun, Moon, Ascendant)
      try {
        await syncUserCharacteristics(userId: userId);
      } catch (e) {
        print('⚠️ Error syncing characteristics (non-critical): $e');
      }

      // Sync house cusps (skip if API fails, already have from birth chart)
      try {
        await syncHouseCusps(
          userId: userId,
          date: birthDate,
          latitude: latitude,
          longitude: longitude,
        );
      } catch (e) {
        print('⚠️ Error syncing house cusps (non-critical): $e');
        // House cusps are already included in birth chart, so this is non-critical
      }

      // Sync daily horoscope if sun sign is available (skip if API fails)
      if (sunSign != null && sunSign.isNotEmpty && sunSign != 'Unknown') {
        try {
          await syncDailyHoroscope(sunSign: sunSign);
        } catch (e) {
          print('⚠️ Error syncing daily horoscope (non-critical): $e');
          // Horoscope can be generated locally, so this is non-critical
        }
      }

      print('✅ Successfully synced all astrology data for user $userId');
    } catch (e) {
      print('❌ Error syncing all astrology data: $e');
      rethrow;
    }
  }
}

