import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firestore_paths.dart';

/// Service to generate and update Tip of Day
/// 
/// Tip of Day is generated from daily horoscope data from FreeAstrologyAPI
/// Falls back to planetary-based wisdom if horoscope not available
class TipOfDayService {
  static TipOfDayService? _instance;
  static TipOfDayService get instance {
    _instance ??= TipOfDayService._();
    return _instance!;
  }

  TipOfDayService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get or generate tip of day for a specific date
  /// 
  /// This will:
  /// 1. Check Firebase first - if exists and fresh, return it
  /// 2. Try to get from daily horoscope (FreeAstrologyAPI)
  /// 3. Generate fallback tip based on date and planetary positions
  Future<String> getTipOfDay({
    DateTime? date,
    String? sunSign,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateId = FirestorePaths.dateId(targetDate);

    // Check Firebase first
    try {
      final tipDoc = await _firestore.doc(FirestorePaths.tipOfDayDoc(targetDate)).get();
      if (tipDoc.exists) {
        final data = tipDoc.data();
        final text = data?['text'] as String?;
        if (text != null && text.isNotEmpty) {
          // Check if it's from today (fresh)
          final updatedAt = data?['updatedAt'] as Timestamp?;
          if (updatedAt != null) {
            final tipDate = updatedAt.toDate();
            final now = DateTime.now();
            if (tipDate.year == now.year && 
                tipDate.month == now.month && 
                tipDate.day == now.day) {
              return text;
            }
          } else {
            // If no timestamp but has text, use it
            return text;
          }
        }
      }
    } catch (e) {
      print('⚠️ Error checking tip of day cache: $e');
    }

    // Generate new tip
    String tip;
    
    // Try to get from daily horoscope if sun sign available
    if (sunSign != null && sunSign.isNotEmpty) {
      try {
        final dateStr = FirestorePaths.dateId(targetDate);
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
            // Extract tip from horoscope content
            final tipText = content['tip'] as String? ?? 
                          content['advice'] as String? ?? 
                          content['overview'] as String? ?? '';
            
            if (tipText.isNotEmpty) {
              tip = tipText;
              // Save to Firebase
              await _firestore.doc(FirestorePaths.tipOfDayDoc(targetDate)).set({
                'dateId': dateId,
                'text': tip,
                'updatedAt': FieldValue.serverTimestamp(),
                'source': 'freeastrologyapi',
              }, SetOptions(merge: true));
              
              print('✅ Generated tip of day from FreeAstrologyAPI horoscope');
              return tip;
            }
          }
        }
      } catch (e) {
        print('⚠️ Error getting tip from horoscope: $e');
      }
    }

    // Fallback: Generate tip based on date and zodiac signs
    tip = _generateFallbackTip(targetDate, sunSign);

    // Save to Firebase
    await _firestore.doc(FirestorePaths.tipOfDayDoc(targetDate)).set({
      'dateId': dateId,
      'text': tip,
      'updatedAt': FieldValue.serverTimestamp(),
      'source': 'generated',
    }, SetOptions(merge: true));

    print('✅ Generated fallback tip of day for $dateId');
    return tip;
  }

  /// Generate fallback tip based on date and zodiac sign
  String _generateFallbackTip(DateTime date, String? sunSign) {
    final month = date.month;
    final day = date.day;
    
    // Generate unique tip based on date
    final dateHash = (date.year * 10000 + month * 100 + day).hashCode;
    
    // Wisdom quotes based on zodiac signs and date
    final wisdomQuotes = [
      'Trust the journey, even when the path is unclear.',
      'The stars align when you align with your true purpose.',
      'Every moment is a new beginning in the cosmic dance of life.',
      'Patience and persistence reveal the hidden patterns of the universe.',
      'Balance is found not in stillness, but in harmonious movement.',
      'The cosmos speaks to those who listen with an open heart.',
      'Your inner light shines brightest when you honor your authentic self.',
      'Change is the only constant in the celestial symphony.',
      'Wisdom comes from understanding the cycles that govern all things.',
      'The stars guide, but you choose your path.',
    ];
    
    // Select quote based on date hash
    final selectedQuote = wisdomQuotes[dateHash.abs() % wisdomQuotes.length];
    
    // Add zodiac-specific wisdom if available
    if (sunSign != null && sunSign.isNotEmpty) {
      final zodiacWisdom = _getZodiacWisdom(sunSign);
      return '$selectedQuote $zodiacWisdom';
    }
    
    return selectedQuote;
  }

  /// Get zodiac-specific wisdom
  String _getZodiacWisdom(String sign) {
    const wisdom = {
      'Aries': 'Channel your fiery energy into focused action today.',
      'Taurus': 'Ground yourself in stability and appreciate the beauty around you.',
      'Gemini': 'Let curiosity guide your conversations and learning.',
      'Cancer': 'Nurture your emotional well-being and those you care about.',
      'Leo': 'Express your creativity and share your unique light.',
      'Virgo': 'Pay attention to details and serve others with precision.',
      'Libra': 'Seek harmony and balance in all your interactions.',
      'Scorpio': 'Embrace transformation and trust your deep intuition.',
      'Sagittarius': 'Explore new horizons and expand your philosophical understanding.',
      'Capricorn': 'Build structure and work steadily toward your goals.',
      'Aquarius': 'Innovate and connect with your community in meaningful ways.',
      'Pisces': 'Dive into your dreams and connect with your spiritual essence.',
    };
    
    return wisdom[sign] ?? 'Trust in the cosmic flow and your inner wisdom.';
  }

  /// Update tip of day for a specific date (force regenerate)
  Future<void> updateTipOfDay({
    DateTime? date,
    String? sunSign,
  }) async {
    final targetDate = date ?? DateTime.now();
    await getTipOfDay(date: targetDate, sunSign: sunSign);
  }
}

