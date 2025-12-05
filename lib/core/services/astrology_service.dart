import 'astrology_calculator.dart';

/// Service for astrological calculations
/// Calculates zodiac signs, planetary positions, and aspects
/// 
/// This service now uses AstrologyCalculator for accurate calculations
class AstrologyService {
  static final AstrologyService _instance = AstrologyService._();
  static AstrologyService get instance => _instance;
  
  final AstrologyCalculator _calculator = AstrologyCalculator.instance;
  
  AstrologyService._();

  /// Zodiac signs in order
  static const List<String> zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  /// Zodiac sign date ranges (month, day)
  static const List<Map<String, int>> zodiacDateRanges = [
    {'startMonth': 3, 'startDay': 21, 'endMonth': 4, 'endDay': 19},   // Aries
    {'startMonth': 4, 'startDay': 20, 'endMonth': 5, 'endDay': 20},   // Taurus
    {'startMonth': 5, 'startDay': 21, 'endMonth': 6, 'endDay': 20},   // Gemini
    {'startMonth': 6, 'startDay': 21, 'endMonth': 7, 'endDay': 22},   // Cancer
    {'startMonth': 7, 'startDay': 23, 'endMonth': 8, 'endDay': 22},   // Leo
    {'startMonth': 8, 'startDay': 23, 'endMonth': 9, 'endDay': 22},   // Virgo
    {'startMonth': 9, 'startDay': 23, 'endMonth': 10, 'endDay': 22},  // Libra
    {'startMonth': 10, 'startDay': 23, 'endMonth': 11, 'endDay': 21}, // Scorpio
    {'startMonth': 11, 'startDay': 22, 'endMonth': 12, 'endDay': 21}, // Sagittarius
    {'startMonth': 12, 'startDay': 22, 'endMonth': 1, 'endDay': 19},  // Capricorn
    {'startMonth': 1, 'startDay': 20, 'endMonth': 2, 'endDay': 18},   // Aquarius
    {'startMonth': 2, 'startDay': 19, 'endMonth': 3, 'endDay': 20},   // Pisces
  ];

  /// Planet symbols
  static const Map<String, String> planetSymbols = {
    'Sun': '☉',
    'Moon': '☽',
    'Mercury': '☿',
    'Venus': '♀',
    'Mars': '♂',
    'Jupiter': '♃',
    'Saturn': '♄',
    'Uranus': '♅',
    'Neptune': '♆',
    'Pluto': '♇',
  };

  /// Zodiac elements
  static const Map<String, String> zodiacElements = {
    'Aries': 'Fire', 'Leo': 'Fire', 'Sagittarius': 'Fire',
    'Taurus': 'Earth', 'Virgo': 'Earth', 'Capricorn': 'Earth',
    'Gemini': 'Air', 'Libra': 'Air', 'Aquarius': 'Air',
    'Cancer': 'Water', 'Scorpio': 'Water', 'Pisces': 'Water',
  };

  /// Zodiac modalities
  static const Map<String, String> zodiacModalities = {
    'Aries': 'Cardinal', 'Cancer': 'Cardinal', 'Libra': 'Cardinal', 'Capricorn': 'Cardinal',
    'Taurus': 'Fixed', 'Leo': 'Fixed', 'Scorpio': 'Fixed', 'Aquarius': 'Fixed',
    'Gemini': 'Mutable', 'Virgo': 'Mutable', 'Sagittarius': 'Mutable', 'Pisces': 'Mutable',
  };

  /// Ruling planets
  static const Map<String, String> rulingPlanets = {
    'Aries': 'Mars', 'Taurus': 'Venus', 'Gemini': 'Mercury',
    'Cancer': 'Moon', 'Leo': 'Sun', 'Virgo': 'Mercury',
    'Libra': 'Venus', 'Scorpio': 'Pluto', 'Sagittarius': 'Jupiter',
    'Capricorn': 'Saturn', 'Aquarius': 'Uranus', 'Pisces': 'Neptune',
  };

  /// Calculate Sun sign from birth date
  /// 
  /// Now uses AstrologyCalculator for accurate calculation based on exact planetary position
  Future<String> getSunSign(DateTime birthDate) async {
    try {
      // Use AstrologyCalculator for accurate calculation
      // Use noon as default time if not specified
      final birthDateTime = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        12, // Noon
      );
      
      // Use a default location (can be improved to use user's location)
      final birthChart = await _calculator.calculateBirthChart(
        birthDateTime: birthDateTime,
        latitude: 0.0, // Equator as default
        longitude: 0.0, // Prime meridian as default
      );
      
      return birthChart.sunSign ?? getSunSignFromDate(birthDate);
    } catch (e) {
      // Fallback to date-based calculation if error
      return getSunSignFromDate(birthDate);
    }
  }

  /// Calculate Sun sign from birth date (fallback method)
  String getSunSignFromDate(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    for (int i = 0; i < zodiacDateRanges.length; i++) {
      final range = zodiacDateRanges[i];
      final startMonth = range['startMonth']!;
      final startDay = range['startDay']!;
      final endMonth = range['endMonth']!;
      final endDay = range['endDay']!;

      // Handle Capricorn which spans year end
      if (startMonth > endMonth) {
        if ((month == startMonth && day >= startDay) ||
            (month == endMonth && day <= endDay)) {
          return zodiacSigns[i];
        }
      } else {
        if ((month == startMonth && day >= startDay) ||
            (month == endMonth && day <= endDay) ||
            (month > startMonth && month < endMonth)) {
          return zodiacSigns[i];
        }
      }
    }
    return 'Aries'; // Default
  }

  /// Calculate Moon sign using AstrologyCalculator
  /// 
  /// Now uses accurate astronomical calculations
  Future<String> getMoonSign(DateTime birthDate, String birthTime, {double? latitude, double? longitude}) async {
    try {
      // Parse birth time
      int hour = 12; // Default to noon
      int minute = 0;
      
      if (birthTime.isNotEmpty && birthTime != 'Unknown') {
        final parsed = _parseTime(birthTime);
        hour = parsed['hour'] ?? 12;
        minute = parsed['minute'] ?? 0;
      }
      
      final birthDateTime = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        hour,
        minute,
      );
      
      // Use provided location or default
      final lat = latitude ?? 0.0;
      final lon = longitude ?? 0.0;
      
      final birthChart = await _calculator.calculateBirthChart(
        birthDateTime: birthDateTime,
        latitude: lat,
        longitude: lon,
      );
      
      return birthChart.moonSign ?? getMoonSignFromDate(birthDate, birthTime);
    } catch (e) {
      // Fallback to simplified calculation
      return getMoonSignFromDate(birthDate, birthTime);
    }
  }

  /// Calculate Moon sign (simplified fallback)
  String getMoonSignFromDate(DateTime birthDate, String birthTime) {
    // Simplified calculation - Moon moves ~13 degrees per day
    // Full moon cycle is ~29.5 days through all 12 signs
    final dayOfYear = _getDayOfYear(birthDate);
    final moonCycle = (dayOfYear * 12 / 29.5).floor() % 12;
    
    // Adjust for birth time if known
    int hourAdjustment = 0;
    if (birthTime.isNotEmpty && birthTime != 'Unknown') {
      final hour = _parseHour(birthTime);
      hourAdjustment = (hour / 2).floor() % 12; // Rough adjustment
    }
    
    final signIndex = (moonCycle + hourAdjustment) % 12;
    return zodiacSigns[signIndex];
  }

  /// Calculate Ascendant/Rising sign using AstrologyCalculator
  /// 
  /// Now uses accurate house calculations
  Future<String> getAscendant(
    DateTime birthDate,
    String birthTime,
    double latitude,
    double longitude,
  ) async {
    if (birthTime == 'Unknown' || birthTime.isEmpty) {
      // If time unknown, estimate based on Sun sign
      return getSunSignFromDate(birthDate);
    }

    try {
      // Parse birth time
      final parsed = _parseTime(birthTime);
      final hour = parsed['hour'] ?? 12;
      final minute = parsed['minute'] ?? 0;
      
      final birthDateTime = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        hour,
        minute,
      );
      
      final birthChart = await _calculator.calculateBirthChart(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
      );
      
      return birthChart.ascendantSign;
    } catch (e) {
      // Fallback to simplified calculation
      return getAscendantFromTime(birthDate, birthTime, latitude);
    }
  }

  /// Calculate Ascendant (simplified fallback)
  String getAscendantFromTime(DateTime birthDate, String birthTime, double latitude) {
    final hour = _parseHour(birthTime);
    final sunSign = getSunSignFromDate(birthDate);
    final sunSignIndex = zodiacSigns.indexOf(sunSign);
    
    // Simplified calculation: Ascendant changes every ~2 hours
    // At sunrise, Ascendant = Sun sign
    // Each 2 hours adds 1 sign
    final hoursFromSunrise = (hour - 6 + 24) % 24;
    final signOffset = (hoursFromSunrise / 2).floor();
    
    // Adjust for latitude (northern vs southern hemisphere)
    final latitudeAdjustment = latitude > 0 ? 0 : 6;
    
    final ascIndex = (sunSignIndex + signOffset + latitudeAdjustment) % 12;
    return zodiacSigns[ascIndex];
  }

  /// Get element for a sign
  String getElement(String sign) {
    return zodiacElements[sign] ?? 'Unknown';
  }

  /// Get modality for a sign
  String getModality(String sign) {
    return zodiacModalities[sign] ?? 'Unknown';
  }

  /// Get ruling planet for a sign
  String getRulingPlanet(String sign) {
    return rulingPlanets[sign] ?? 'Unknown';
  }

  /// Calculate element percentages in a chart
  Map<String, int> getElementPercentages(String sunSign, String moonSign, String ascendant) {
    final elements = <String, int>{
      'Fire': 0, 'Earth': 0, 'Air': 0, 'Water': 0
    };

    // Weight: Sun 50%, Moon 30%, Ascendant 20%
    final sunElement = zodiacElements[sunSign];
    final moonElement = zodiacElements[moonSign];
    final ascElement = zodiacElements[ascendant];

    if (sunElement != null) elements[sunElement] = (elements[sunElement] ?? 0) + 50;
    if (moonElement != null) elements[moonElement] = (elements[moonElement] ?? 0) + 30;
    if (ascElement != null) elements[ascElement] = (elements[ascElement] ?? 0) + 20;

    return elements;
  }

  /// Calculate modality percentages in a chart
  Map<String, int> getModalityPercentages(String sunSign, String moonSign, String ascendant) {
    final modalities = <String, int>{
      'Cardinal': 0, 'Fixed': 0, 'Mutable': 0
    };

    final sunMod = zodiacModalities[sunSign];
    final moonMod = zodiacModalities[moonSign];
    final ascMod = zodiacModalities[ascendant];

    if (sunMod != null) modalities[sunMod] = (modalities[sunMod] ?? 0) + 50;
    if (moonMod != null) modalities[moonMod] = (modalities[moonMod] ?? 0) + 30;
    if (ascMod != null) modalities[ascMod] = (modalities[ascMod] ?? 0) + 20;

    return modalities;
  }

  /// Get polarity (Masculine/Feminine)
  String getPolarity(String sign) {
    final element = zodiacElements[sign];
    if (element == 'Fire' || element == 'Air') {
      return 'Masculine';
    }
    return 'Feminine';
  }

  /// Calculate compatibility between two signs
  int calculateCompatibility(String sign1, String sign2) {
    final element1 = zodiacElements[sign1];
    final element2 = zodiacElements[sign2];
    final modality1 = zodiacModalities[sign1];
    final modality2 = zodiacModalities[sign2];

    int score = 50; // Base score

    // Same element = +30
    if (element1 == element2) {
      score += 30;
    }
    // Complementary elements (Fire-Air, Earth-Water) = +20
    else if ((element1 == 'Fire' && element2 == 'Air') ||
             (element1 == 'Air' && element2 == 'Fire') ||
             (element1 == 'Earth' && element2 == 'Water') ||
             (element1 == 'Water' && element2 == 'Earth')) {
      score += 20;
    }
    // Challenging elements = -10
    else {
      score -= 10;
    }

    // Same modality can be challenging
    if (modality1 == modality2) {
      score -= 5;
    }

    return score.clamp(0, 100);
  }

  /// Get current planetary positions (simplified/approximate)
  List<Map<String, String>> getCurrentPlanetaryPositions() {
    final now = DateTime.now();
    final dayOfYear = _getDayOfYear(now);
    
    return [
      _getPlanetPosition('Sun', dayOfYear, 365.25, 0),
      _getPlanetPosition('Moon', dayOfYear, 27.3, 0),
      _getPlanetPosition('Mercury', dayOfYear, 88, 15),
      _getPlanetPosition('Venus', dayOfYear, 225, 47),
      _getPlanetPosition('Mars', dayOfYear, 687, 79),
      _getPlanetPosition('Jupiter', dayOfYear, 4333, 100),
      _getPlanetPosition('Saturn', dayOfYear, 10759, 113),
    ];
  }

  Map<String, String> _getPlanetPosition(String planet, int dayOfYear, double orbitalPeriod, int offset) {
    final position = ((dayOfYear + offset) / orbitalPeriod * 360) % 360;
    final signIndex = (position / 30).floor();
    final degrees = position % 30;
    final minutes = ((degrees % 1) * 60).floor();
    final seconds = (((degrees % 1) * 60) % 1 * 60).floor();

    return {
      'planet': planet,
      'sign': zodiacSigns[signIndex],
      'degrees': '${degrees.floor()}°${minutes.toString().padLeft(2, '0')}\'${seconds.toString().padLeft(2, '0')}"',
      'symbol': planetSymbols[planet] ?? '',
    };
  }

  int _getDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  int _parseHour(String timeStr) {
    try {
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      
      // Handle AM/PM
      if (timeStr.toUpperCase().contains('PM') && hour != 12) {
        hour += 12;
      } else if (timeStr.toUpperCase().contains('AM') && hour == 12) {
        hour = 0;
      }
      
      return hour;
    } catch (_) {
      return 12; // Default to noon
    }
  }

  /// Parse time string to hour and minute
  Map<String, int> _parseTime(String timeStr) {
    try {
      // Remove AM/PM and whitespace
      final cleanTime = timeStr.trim().toUpperCase();
      final isPM = cleanTime.contains('PM');
      final isAM = cleanTime.contains('AM');
      
      // Extract time part
      final timePart = cleanTime
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim();
      
      final parts = timePart.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      
      // Handle AM/PM
      if (isPM && hour != 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }
      
      return {'hour': hour, 'minute': minute};
    } catch (_) {
      return {'hour': 12, 'minute': 0}; // Default to noon
    }
  }

  /// Get zodiac sign description
  String getSignDescription(String sign) {
    const descriptions = {
      'Aries': 'Bold, ambitious, and energetic. Natural leaders who love a challenge.',
      'Taurus': 'Reliable, patient, and devoted. Enjoys comfort and the finer things in life.',
      'Gemini': 'Curious, adaptable, and communicative. Quick-witted and social.',
      'Cancer': 'Intuitive, sentimental, and protective. Deeply connected to home and family.',
      'Leo': 'Dramatic, confident, and generous. Natural performers who love the spotlight.',
      'Virgo': 'Analytical, practical, and hardworking. Detail-oriented perfectionists.',
      'Libra': 'Diplomatic, fair-minded, and social. Seeks harmony and balance.',
      'Scorpio': 'Passionate, resourceful, and brave. Intense and mysterious.',
      'Sagittarius': 'Optimistic, adventurous, and philosophical. Loves freedom and exploration.',
      'Capricorn': 'Disciplined, responsible, and ambitious. Master of self-control.',
      'Aquarius': 'Independent, original, and humanitarian. Progressive thinkers.',
      'Pisces': 'Compassionate, artistic, and intuitive. Deeply emotional and spiritual.',
    };
    return descriptions[sign] ?? 'A unique cosmic energy.';
  }
}
