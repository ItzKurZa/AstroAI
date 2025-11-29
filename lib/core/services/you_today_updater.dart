import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firestore_paths.dart';
import 'daily_planetary_service.dart';

/// Service to automatically update you_today collection
/// 
/// This service generates personalized "You Today" sections based on:
/// - Daily horoscope from FreeAstrologyAPI (already synced to Firebase)
/// - Current planetary positions (from FreeAstrologyAPI)
/// - User's birth chart (from FreeAstrologyAPI)
/// 
/// Note: All astrology data comes from FreeAstrologyAPI, not Gemini.
/// Gemini is only used for chat consultation.
class YouTodayUpdater {
  static YouTodayUpdater? _instance;
  static YouTodayUpdater get instance {
    _instance ??= YouTodayUpdater._();
    return _instance!;
  }

  YouTodayUpdater._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DailyPlanetaryService _planetaryService = DailyPlanetaryService.instance;

  /// Update you_today for a specific date
  /// 
  /// This will:
  /// 1. Get current planetary positions
  /// 2. Generate personalized sections (Health, Finance, Relationship, Career)
  /// 3. Save to Firebase
  Future<void> updateYouToday({
    DateTime? date,
    String? userId,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateId = FirestorePaths.dateId(targetDate);

      // Get planetary data for today
      final planetaryData = await _planetaryService.getPlanetaryData(targetDate);
      
      if (planetaryData.isEmpty) {
        print('⚠️ No planetary data available for $dateId');
        return;
      }

      // Extract planets from planetary data
      // DailyPlanetaryService stores planets as 'cards', not 'planets'
      final cards = (planetaryData['cards'] as List<dynamic>?) ?? [];
      
      if (cards.isEmpty) {
        print('⚠️ No planets found in planetary data');
        return;
      }
      
      // Convert cards to planets format for compatibility
      final planets = cards.map((card) {
        // Extract zodiac sign from card data
        final zodiac = card['zodiac'] as String? ?? 'Unknown';
        final degreesStr = card['degrees'] as String? ?? '0°, 0\' 0"';
        
        // Parse degrees string to extract components
        final degreesMatch = RegExp(r'(\d+)°').firstMatch(degreesStr);
        final minutesMatch = RegExp(r"(\d+)'").firstMatch(degreesStr);
        final secondsMatch = RegExp(r'(\d+)"').firstMatch(degreesStr);
        
        final degrees = double.tryParse(degreesMatch?.group(1) ?? '0') ?? 0.0;
        final minutes = int.tryParse(minutesMatch?.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(secondsMatch?.group(1) ?? '0') ?? 0;
        
        return {
          'name': card['name'] as String? ?? '',
          'zodiacSign': zodiac,
          'degreesInSign': degrees,
          'minutesInSign': minutes,
          'secondsInSign': seconds,
        };
      }).toList();

      // Generate sections based on planetary positions
      final sections = await _generateSections(planets, targetDate, userId);

      // Save to Firebase
      await _firestore.doc(FirestorePaths.youTodayDoc(targetDate)).set({
        'dateId': dateId,
        'sections': sections,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Updated you_today for $dateId');
    } catch (e) {
      print('❌ Error updating you_today: $e');
      rethrow;
    }
  }

  /// Generate personalized sections based on FreeAstrologyAPI data
  /// Gets daily horoscope from Firebase (synced by FreeAstrologyAPI)
  /// Falls back to planetary-based descriptions if horoscope not available
  Future<List<Map<String, dynamic>>> _generateSections(
    List<dynamic> planets,
    DateTime date,
    String? userId,
  ) async {
    // Map planets by name for easy lookup
    final planetMap = <String, Map<String, dynamic>>{};
    for (final planet in planets) {
      final name = planet['name'] as String? ?? '';
      if (name.isNotEmpty) {
        planetMap[name] = planet;
      }
    }

    // Try to get daily horoscope from FreeAstrologyAPI (synced to Firebase)
    Map<String, String>? horoscopeDescriptions = {};
    
    if (userId != null) {
      try {
        // Get user's sun sign
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();
        final sunSign = userData?['sunSign'] as String?;
        
        if (sunSign != null && sunSign.isNotEmpty) {
          // Try to get daily horoscope from Firebase (synced by FreeAstrologyAPI)
          final dateStr = FirestorePaths.dateId(date);
          final horoscopeDoc = await _firestore
              .collection('horoscopes')
              .doc(dateStr)
              .collection('signs')
              .doc(sunSign.toLowerCase())
              .get();
          
          if (horoscopeDoc.exists) {
            final horoscopeData = horoscopeDoc.data();
            final content = horoscopeData?['content'] as Map<String, dynamic>?;
            
            if (content != null) {
              // Parse horoscope content from FreeAstrologyAPI
              // Format may vary, try common fields
              horoscopeDescriptions = {
                'health': content['health'] as String? ?? 
                          content['healthAdvice'] as String? ?? 
                          content['overview'] as String? ?? '',
                'finance': content['finance'] as String? ?? 
                          content['financeAdvice'] as String? ?? 
                          content['money'] as String? ?? '',
                'relationship': content['relationship'] as String? ?? 
                              content['love'] as String? ?? 
                              content['relationships'] as String? ?? '',
                'career': content['career'] as String? ?? 
                         content['work'] as String? ?? 
                         content['professional'] as String? ?? '',
              };
              
              // If we got at least one description, use it
              if (horoscopeDescriptions.values.any((v) => v.isNotEmpty)) {
                print('✅ Using daily horoscope from FreeAstrologyAPI for $sunSign');
              }
            }
          }
        }
      } catch (e) {
        print('⚠️ Error getting daily horoscope from FreeAstrologyAPI: $e');
        // Continue with fallback
      }
    }

    // Generate sections (use horoscope descriptions from FreeAstrologyAPI if available, otherwise use fallbacks)
    return [
      await _generateHealthSection(planetMap, date, userId, horoscopeDescriptions?['health']),
      await _generateFinanceSection(planetMap, date, userId, horoscopeDescriptions?['finance']),
      await _generateRelationshipSection(planetMap, date, userId, horoscopeDescriptions?['relationship']),
      await _generateCareerSection(planetMap, date, userId, horoscopeDescriptions?['career']),
    ];
  }

  /// Generate Health section
  Future<Map<String, dynamic>> _generateHealthSection(
    Map<String, dynamic> planetMap,
    DateTime date,
    String? userId, [
    String? aiDescription,
  ]) async {
    // Health-related planets: Sun, Moon, Mars, Venus
    final healthPlanets = <Map<String, dynamic>>[];
    
    for (final planetName in ['Sun', 'Moon', 'Mars', 'Venus']) {
      final planet = planetMap[planetName];
      if (planet != null) {
        healthPlanets.add({
          'planet': planetName,
          'zodiac': planet['zodiacSign'] ?? 'Unknown',
          'degrees': _formatDegrees(
            planet['degreesInSign'] ?? 0.0,
            planet['minutesInSign'] ?? 0,
            planet['secondsInSign'] ?? 0,
          ),
        });
      }
    }

    // Use AI description if provided, otherwise generate fallback
    final description = aiDescription?.isNotEmpty == true
        ? aiDescription!
        : await _generateHealthDescription(healthPlanets, date);

    return {
      'title': 'Health',
      'planets': healthPlanets,
      'description': description,
    };
  }

  /// Generate Finance section
  Future<Map<String, dynamic>> _generateFinanceSection(
    Map<String, dynamic> planetMap,
    DateTime date,
    String? userId, [
    String? aiDescription,
  ]) async {
    // Finance-related planets: Mercury, Mars, Jupiter
    final financePlanets = <Map<String, dynamic>>[];
    
    for (final planetName in ['Mercury', 'Mars', 'Jupiter']) {
      final planet = planetMap[planetName];
      if (planet != null) {
        financePlanets.add({
          'planet': planetName,
          'zodiac': planet['zodiacSign'] ?? 'Unknown',
          'degrees': _formatDegrees(
            planet['degreesInSign'] ?? 0.0,
            planet['minutesInSign'] ?? 0,
            planet['secondsInSign'] ?? 0,
          ),
        });
      }
    }

    final description = aiDescription?.isNotEmpty == true
        ? aiDescription!
        : await _generateFinanceDescription(financePlanets, date);

    return {
      'title': 'Finance',
      'planets': financePlanets,
      'description': description,
    };
  }

  /// Generate Relationship section
  Future<Map<String, dynamic>> _generateRelationshipSection(
    Map<String, dynamic> planetMap,
    DateTime date,
    String? userId, [
    String? aiDescription,
  ]) async {
    // Relationship-related planets: Venus, Mars, Moon
    final relationshipPlanets = <Map<String, dynamic>>[];
    
    for (final planetName in ['Venus', 'Mars', 'Moon']) {
      final planet = planetMap[planetName];
      if (planet != null) {
        relationshipPlanets.add({
          'planet': planetName,
          'zodiac': planet['zodiacSign'] ?? 'Unknown',
          'degrees': _formatDegrees(
            planet['degreesInSign'] ?? 0.0,
            planet['minutesInSign'] ?? 0,
            planet['secondsInSign'] ?? 0,
          ),
        });
      }
    }

    final description = aiDescription?.isNotEmpty == true
        ? aiDescription!
        : await _generateRelationshipDescription(relationshipPlanets, date);

    return {
      'title': 'Relationship',
      'planets': relationshipPlanets,
      'description': description,
    };
  }

  /// Generate Career section
  Future<Map<String, dynamic>> _generateCareerSection(
    Map<String, dynamic> planetMap,
    DateTime date,
    String? userId, [
    String? aiDescription,
  ]) async {
    // Career-related planets: Saturn, Jupiter, Sun
    final careerPlanets = <Map<String, dynamic>>[];
    
    for (final planetName in ['Saturn', 'Jupiter', 'Sun']) {
      final planet = planetMap[planetName];
      if (planet != null) {
        careerPlanets.add({
          'planet': planetName,
          'zodiac': planet['zodiacSign'] ?? 'Unknown',
          'degrees': _formatDegrees(
            planet['degreesInSign'] ?? 0.0,
            planet['minutesInSign'] ?? 0,
            planet['secondsInSign'] ?? 0,
          ),
        });
      }
    }

    final description = aiDescription?.isNotEmpty == true
        ? aiDescription!
        : await _generateCareerDescription(careerPlanets, date);

    return {
      'title': 'Career',
      'planets': careerPlanets,
      'description': description,
    };
  }

  /// Format degrees as "XX°, XX' XX\""
  String _formatDegrees(double degrees, int minutes, int seconds) {
    final deg = degrees.floor();
    return "$deg°, ${minutes.toString().padLeft(2, '0')}' ${seconds.toString().padLeft(2, '0')}\"";
  }

  /// Generate health description based on actual planetary positions
  /// Uses fallback descriptions based on planetary positions (no Gemini)
  Future<String> _generateHealthDescription(
    List<Map<String, dynamic>> planets,
    DateTime date,
  ) async {
    if (planets.isEmpty) {
      return 'Take time to rest and recharge today. Listen to your body and give it what it needs.';
    }
    
    // Build detailed planetary information
    final planetDetails = planets.map((p) {
      final planet = p['planet'] as String;
      final zodiac = p['zodiac'] as String? ?? 'Unknown';
      final degrees = p['degrees'] as String? ?? '0°';
      return '$planet in $zodiac at $degrees';
    }).join(', ');
    
    // Create unique description based on actual positions and date
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final baseHash = (dateStr.hashCode + planetDetails.hashCode).abs();
    
    // Generate description based on zodiac signs and date (no Gemini)
    final zodiacSigns = planets.map((p) => p['zodiac'] as String? ?? 'Unknown').toSet().toList();
    final uniqueZodiacs = zodiacSigns.join(' and ');
    
    // Create variations based on date and zodiac combinations
    final variations = [
      'The alignment of $uniqueZodiacs brings focus to your physical well-being today. Pay attention to your body\'s signals and maintain balance through proper rest, nutrition, and gentle movement.',
      'With $uniqueZodiacs influencing your health sector, this is an ideal time to establish healthy routines. Listen to your body and give it the care it deserves.',
      'The cosmic energies of $uniqueZodiacs suggest a day for healing and restoration. Take time to recharge and nurture your physical health.',
      'Today\'s planetary positions in $uniqueZodiacs emphasize the importance of self-care. Balance activity with rest, and honor your body\'s needs.',
    ];
    
    return variations[baseHash % variations.length];
  }

  /// Generate finance description based on actual planetary positions
  Future<String> _generateFinanceDescription(
    List<Map<String, dynamic>> planets,
    DateTime date,
  ) async {
    if (planets.isEmpty) {
      return 'Be mindful of your spending today. Focus on long-term financial stability.';
    }
    
    final planetDetails = planets.map((p) {
      final planet = p['planet'] as String;
      final zodiac = p['zodiac'] as String? ?? 'Unknown';
      final degrees = p['degrees'] as String? ?? '0°';
      return '$planet in $zodiac at $degrees';
    }).join(', ');
    
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final baseHash = (dateStr.hashCode + planetDetails.hashCode).abs();
    
    // Generate description based on zodiac signs and date (no Gemini)
    final zodiacSigns = planets.map((p) => p['zodiac'] as String? ?? 'Unknown').toSet().toList();
    final uniqueZodiacs = zodiacSigns.join(' and ');
    
    final variations = [
      'The planetary positions in $uniqueZodiacs suggest a time for careful financial planning. Consider your investments and expenses wisely, and avoid impulsive decisions.',
      'With $uniqueZodiacs influencing your financial sector, this is an ideal moment to review your budget and make strategic choices for long-term stability.',
      'Today\'s cosmic alignment in $uniqueZodiacs brings opportunities for financial growth. Stay disciplined and make informed decisions about your resources.',
      'The energies of $uniqueZodiacs encourage patience in financial matters. Focus on building stability rather than seeking quick gains.',
    ];
    
    return variations[baseHash % variations.length];
  }

  /// Generate relationship description based on actual planetary positions
  Future<String> _generateRelationshipDescription(
    List<Map<String, dynamic>> planets,
    DateTime date,
  ) async {
    if (planets.isEmpty) {
      return 'Open communication is key in your relationships today. Express your feelings honestly.';
    }
    
    final planetDetails = planets.map((p) {
      final planet = p['planet'] as String;
      final zodiac = p['zodiac'] as String? ?? 'Unknown';
      final degrees = p['degrees'] as String? ?? '0°';
      return '$planet in $zodiac at $degrees';
    }).join(', ');
    
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final baseHash = (dateStr.hashCode + planetDetails.hashCode).abs();
    
    // Generate description based on zodiac signs and date (no Gemini)
    final zodiacSigns = planets.map((p) => p['zodiac'] as String? ?? 'Unknown').toSet().toList();
    final uniqueZodiacs = zodiacSigns.join(' and ');
    
    final variations = [
      'The influence of $uniqueZodiacs brings harmony to your relationships. This is a good time for meaningful conversations and deepening connections with loved ones.',
      'With $uniqueZodiacs guiding your relationship sector, open communication and emotional honesty will strengthen your bonds today.',
      'Today\'s planetary alignment in $uniqueZodiacs creates a favorable atmosphere for love and connection. Express your feelings and nurture your relationships.',
      'The cosmic energies of $uniqueZodiacs encourage you to be present with those you care about. Quality time and genuine communication will deepen your connections.',
    ];
    
    return variations[baseHash % variations.length];
  }

  /// Generate career description based on actual planetary positions
  Future<String> _generateCareerDescription(
    List<Map<String, dynamic>> planets,
    DateTime date,
  ) async {
    if (planets.isEmpty) {
      return 'Focus on your goals and maintain discipline in your professional endeavors.';
    }
    
    final planetDetails = planets.map((p) {
      final planet = p['planet'] as String;
      final zodiac = p['zodiac'] as String? ?? 'Unknown';
      final degrees = p['degrees'] as String? ?? '0°';
      return '$planet in $zodiac at $degrees';
    }).join(', ');
    
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final baseHash = (dateStr.hashCode + planetDetails.hashCode).abs();
    
    // Generate description based on zodiac signs and date (no Gemini)
    final zodiacSigns = planets.map((p) => p['zodiac'] as String? ?? 'Unknown').toSet().toList();
    final uniqueZodiacs = zodiacSigns.join(' and ');
    
    final variations = [
      'The alignment of $uniqueZodiacs indicates potential for progress in your career. Stay focused, be patient, and take advantage of opportunities that arise.',
      'With $uniqueZodiacs influencing your professional sector, this is an ideal time to pursue your goals with determination and strategic planning.',
      'Today\'s planetary positions in $uniqueZodiacs bring opportunities for professional growth. Maintain discipline and be open to new possibilities.',
      'The cosmic energies of $uniqueZodiacs support your career ambitions. Focus on your long-term goals and take steady, purposeful steps forward.',
    ];
    
    return variations[baseHash % variations.length];
  }
}

