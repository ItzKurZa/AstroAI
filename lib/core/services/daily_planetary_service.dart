import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore_paths.dart';
import 'astrology_calculator.dart';

/// Service to calculate and store daily planetary positions in Firebase
class DailyPlanetaryService {
  static final DailyPlanetaryService _instance = DailyPlanetaryService._();
  static DailyPlanetaryService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AstrologyCalculator _calculator = AstrologyCalculator.instance;

  DailyPlanetaryService._();

  /// Calculate and save planetary positions for a specific date
  /// 
  /// [date] - The date to calculate for (defaults to today)
  /// [forceRecalculate] - If true, recalculates even if data exists
  Future<void> calculateAndSaveDailyPlanets({
    DateTime? date,
    bool forceRecalculate = false,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateId = FirestorePaths.dateId(targetDate);
    
    // Check if data already exists
    if (!forceRecalculate) {
      final doc = _firestore.doc(FirestorePaths.planetsTodayDoc(targetDate));
      final snapshot = await doc.get();
      if (snapshot.exists) {
        // Data already exists, skip calculation
        return;
      }
    }

    // Calculate planetary positions for noon UTC (standard practice)
    final calculationTime = DateTime.utc(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      12, // Noon UTC
    );

    // Use a default location (can be improved to use user's location)
    // For daily planetary positions, location doesn't matter much
    final birthChart = await _calculator.calculateBirthChart(
      birthDateTime: calculationTime,
      latitude: 0.0, // Equator
      longitude: 0.0, // Prime meridian
    );

    // Convert to Firestore format
    // Note: _getPlanetImageName maps 'Pluto' to 'Pluton' to match asset file name
    final cards = birthChart.planets.map((planet) {
      final imageName = _getPlanetImageName(planet.planetName);
      return {
        'name': planet.planetName,
        'zodiac': planet.zodiacSign,
        'degrees': planet.formattedDegrees,
        'description': _getPlanetDescription(planet.planetName, planet.zodiacSign),
        'imageUrl': 'assets/images/app/planets/$imageName.png',
        'accentColor': _getPlanetColor(planet.planetName),
      };
    }).toList();

    // Save to Firestore
    final doc = _firestore.doc(FirestorePaths.planetsTodayDoc(targetDate));
    await doc.set({
      'dateId': dateId,
      'cards': cards,
      'calculatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Calculate and save for multiple dates (useful for pre-calculating)
  /// 
  /// IMPORTANT: This method checks Firebase cache first to avoid spam API requests.
  /// Only calls API for dates that don't exist in Firebase.
  Future<void> calculateAndSaveDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final dates = <DateTime>[];
    var current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    // First, check which dates already exist in Firebase (batch check)
    final existingDates = <DateTime>[];
    final missingDates = <DateTime>[];

    for (final date in dates) {
      final doc = _firestore.doc(FirestorePaths.planetsTodayDoc(date));
      final snapshot = await doc.get();
      if (snapshot.exists) {
        existingDates.add(date);
      } else {
        missingDates.add(date);
      }
    }
    
    if (existingDates.isNotEmpty) {
      print('✅ ${existingDates.length} dates already cached in Firebase, skipping API calls');
    }
    
    if (missingDates.isEmpty) {
      print('✅ All dates already cached, no API calls needed');
      return;
    }
    
    print('📡 Calculating ${missingDates.length} missing dates (will cache to Firebase)...');
    
    // Process missing dates with a small delay between each to avoid rate limiting
    for (int i = 0; i < missingDates.length; i++) {
      final date = missingDates[i];
      await calculateAndSaveDailyPlanets(date: date);
      
      // Add small delay between API calls to avoid rate limiting (except for last one)
      if (i < missingDates.length - 1) {
        await Future.delayed(const Duration(milliseconds: 200));
    }
    }
    
    print('✅ Successfully cached ${missingDates.length} dates to Firebase');
  }

  /// Get planetary data for a date (calculates if not exists)
  /// 
  /// IMPORTANT: Always checks Firebase cache first to avoid unnecessary API calls.
  /// Only calls API if data doesn't exist in Firebase.
  /// Also fixes old data that might have Pluto.png instead of Pluton.png
  Future<Map<String, dynamic>> getPlanetaryData(DateTime date) async {
    final doc = _firestore.doc(FirestorePaths.planetsTodayDoc(date));
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      // Data doesn't exist in Firebase - calculate and save (will cache to Firebase)
      print('📡 Planetary data not found in Firebase for ${FirestorePaths.dateId(date)}, calculating and caching...');
      await calculateAndSaveDailyPlanets(date: date);
      // Get again after calculation
      final newSnapshot = await doc.get();
      return newSnapshot.data() ?? {};
    }

    final data = snapshot.data() ?? {};
    
    // Fix old data that might have Pluto.png instead of Pluton.png
    final cards = data['cards'] as List<dynamic>?;
    if (cards != null) {
      bool needsFix = false;
      final fixedCards = cards.map((card) {
        if (card is Map<String, dynamic>) {
          final imageUrl = card['imageUrl'] as String?;
          if (imageUrl != null && imageUrl.contains('Pluto.png')) {
            needsFix = true;
            return {
              ...card,
              'imageUrl': imageUrl.replaceAll('Pluto.png', 'Pluton.png'),
            };
          }
        }
        return card;
      }).toList();
      
      if (needsFix) {
        // Update the document with fixed image URLs
        await doc.update({
          'cards': fixedCards,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return {
          ...data,
          'cards': fixedCards,
        };
      }
    }

    return data;
  }

  /// Get planet description based on planet and sign
  String _getPlanetDescription(String planetName, String zodiacSign) {
    // This is a placeholder - in production, you might want to use
    // AI or a database of descriptions
    const descriptions = {
      'Sun': 'The Sun represents your core identity, ego, and life force.',
      'Moon': 'The Moon reflects your emotions, instincts, and inner self.',
      'Mercury': 'Mercury governs communication, thinking, and learning.',
      'Venus': 'Venus rules love, beauty, and relationships.',
      'Mars': 'Mars represents energy, action, and desire.',
      'Jupiter': 'Jupiter brings expansion, growth, and opportunity.',
      'Saturn': 'Saturn teaches discipline, responsibility, and structure.',
      'Uranus': 'Uranus brings innovation, change, and revolution.',
      'Neptune': 'Neptune inspires dreams, intuition, and spirituality.',
      'Pluto': 'Pluto transforms through deep change and regeneration.',
    };

    final baseDescription = descriptions[planetName] ?? 
        '$planetName influences your chart with its unique energy.';
    
    return '$baseDescription In $zodiacSign, this energy takes on the qualities of ${_getSignQuality(zodiacSign)}.';
  }

  String _getSignQuality(String sign) {
    const qualities = {
      'Aries': 'boldness and initiative',
      'Taurus': 'stability and sensuality',
      'Gemini': 'curiosity and communication',
      'Cancer': 'nurturing and emotional depth',
      'Leo': 'creativity and self-expression',
      'Virgo': 'precision and service',
      'Libra': 'harmony and partnership',
      'Scorpio': 'intensity and transformation',
      'Sagittarius': 'adventure and philosophy',
      'Capricorn': 'ambition and structure',
      'Aquarius': 'innovation and independence',
      'Pisces': 'intuition and compassion',
    };
    return qualities[sign] ?? 'unique characteristics';
  }

  /// Get planet accent color
  String _getPlanetColor(String planetName) {
    const colors = {
      'Sun': '#F19550',
      'Moon': '#D9DBDB',
      'Mercury': '#BCA8F4',
      'Venus': '#EC9E41',
      'Mars': '#E74C3C',
      'Jupiter': '#F39C12',
      'Saturn': '#95A5A6',
      'Uranus': '#3498DB',
      'Neptune': '#5DADE2',
      'Pluto': '#8E44AD',
    };
    return colors[planetName] ?? '#BCA8F4';
  }

  /// Map planet name to image file name
  /// Some planets have different names in the asset files
  String _getPlanetImageName(String planetName) {
    const imageNameMap = {
      'Mercury': 'Mercury',
      'Sun': 'Sun',
      'Moon': 'Moon',
      'Venus': 'Venus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturn',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluton', // Note: file is Pluton.png, not Pluto.png
      'Ascendant': 'AC', // AC not in planets/, will need to handle separately
    };
    return imageNameMap[planetName] ?? planetName;
  }
}

