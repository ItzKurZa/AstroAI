import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/horoscope/domain/entities/astrological_event.dart';
import 'local_cache_service.dart';

/// Service to automatically generate astrological events
/// 
/// Generates events like:
/// - New Moon / Full Moon (every ~29.5 days)
/// - Mercury Retrograde (3-4 times per year)
/// - Zodiac season changes (every ~30 days)
/// - Major planetary alignments
class AstrologicalEventGenerator {
  static AstrologicalEventGenerator? _instance;
  static AstrologicalEventGenerator get instance {
    _instance ??= AstrologicalEventGenerator._();
    return _instance!;
  }

  AstrologicalEventGenerator._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate and save astrological events for the next 90 days
  /// 
  /// IMPORTANT: Checks Firebase metadata first to avoid regenerating existing events.
  /// Only generates events if:
  /// 1. No metadata exists (first time)
  /// 2. Last generation was more than 30 days ago (needs update for next 90 days)
  /// Automatically caches to local storage for fast access.
  Future<void> generateEventsForNext90Days({bool forceRegenerate = false}) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 90));
      
      // Check metadata in Firebase to see when events were last generated
      if (!forceRegenerate) {
        final metadataDoc = await _firestore
            .collection('astrological_events')
            .doc('_metadata')
            .get();
        
        if (metadataDoc.exists) {
          final metadata = metadataDoc.data();
          final lastGenerated = (metadata?['lastGenerated'] as Timestamp?)?.toDate();
          final generatedUntil = (metadata?['generatedUntil'] as Timestamp?)?.toDate();
          
          // Check if events are still fresh
          if (lastGenerated != null && generatedUntil != null) {
            final daysSinceGeneration = now.difference(lastGenerated).inDays;
            final daysUntilExpiry = generatedUntil.difference(now).inDays;
            
            // If generated less than 30 days ago and still have events for next 60+ days, skip
            if (daysSinceGeneration < 30 && daysUntilExpiry > 60) {
              print('✅ Astrological events are fresh (generated ${daysSinceGeneration} days ago, valid until ${daysUntilExpiry} days) - skipping regeneration');
              return;
            }
            
            // If events are about to expire (less than 30 days left), regenerate
            if (daysUntilExpiry < 30) {
              print('🔄 Astrological events expiring soon (${daysUntilExpiry} days left) - regenerating...');
            } else if (daysSinceGeneration >= 30) {
              print('🔄 Astrological events outdated (${daysSinceGeneration} days old) - regenerating...');
            }
          } else {
            print('⚠️ Metadata exists but incomplete - regenerating events...');
          }
        } else {
          print('📡 No metadata found - generating events for first time...');
        }
      } else {
        print('🔄 Force regenerate requested...');
      }
      
      print('🌙 Generating astrological events for next 90 days...');
      
      final events = <Map<String, dynamic>>[];
      
      // Generate New Moon and Full Moon events
      events.addAll(_generateMoonPhases(now, endDate));
      
      // Generate Mercury Retrograde periods (if any in next 90 days)
      events.addAll(_generateMercuryRetrograde(now, endDate));
      
      // Generate Zodiac season changes
      events.addAll(_generateZodiacSeasonChanges(now, endDate));
      
      if (events.isEmpty) {
        print('⚠️ No events generated');
        return;
      }
      
      // Save to Firestore (only new events, merge to avoid duplicates)
      final batch = _firestore.batch();
      for (final event in events) {
        final eventId = _generateEventId(event);
        final docRef = _firestore.collection('astrological_events').doc(eventId);
        batch.set(docRef, event, SetOptions(merge: true));
      }
      
      // Save metadata to Firebase for tracking and auto-update
      final metadataRef = _firestore.collection('astrological_events').doc('_metadata');
      batch.set(metadataRef, {
        'lastGenerated': FieldValue.serverTimestamp(),
        'generatedUntil': Timestamp.fromDate(endDate),
        'eventCount': events.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      await batch.commit();
      
      // Cache to local storage
      await LocalCacheService.instance.saveAstrologicalEvents(events);
      
      print('✅ Generated and saved ${events.length} astrological events (valid until ${endDate.toString().split(' ')[0]})');
    } catch (e) {
      print('❌ Error generating astrological events: $e');
    }
  }

  /// Generate New Moon and Full Moon events
  /// Uses approximate lunar cycle calculation (29.53059 days)
  List<Map<String, dynamic>> _generateMoonPhases(DateTime start, DateTime end) {
    final events = <Map<String, dynamic>>[];
    
    // Known New Moon reference date: January 6, 2000 (approximate)
    final referenceNewMoon = DateTime(2000, 1, 6, 18, 14); // UTC
    final lunarCycleDays = 29.53059;
    
    // Calculate first New Moon after start date
    final daysSinceReference = start.difference(referenceNewMoon).inDays;
    final cyclesSinceReference = daysSinceReference / lunarCycleDays;
    final nextNewMoonCycle = cyclesSinceReference.ceil();
    final firstNewMoon = referenceNewMoon.add(
      Duration(days: (nextNewMoonCycle * lunarCycleDays).round()),
    );
    
    // Generate New Moons and Full Moons
    var currentNewMoon = firstNewMoon;
    while (currentNewMoon.isBefore(end)) {
      // New Moon
      if (currentNewMoon.isAfter(start.subtract(const Duration(days: 1)))) {
        events.add(_createMoonEvent(
          'New Moon',
          DateTime(currentNewMoon.year, currentNewMoon.month, currentNewMoon.day),
          AstrologicalEventType.newMoon,
        ));
      }
      
      // Full Moon (approximately 14.765 days after New Moon)
      final fullMoon = currentNewMoon.add(Duration(days: (lunarCycleDays / 2).round()));
      if (fullMoon.isAfter(start.subtract(const Duration(days: 1))) && 
          fullMoon.isBefore(end)) {
        events.add(_createMoonEvent(
          'Full Moon',
          DateTime(fullMoon.year, fullMoon.month, fullMoon.day),
          AstrologicalEventType.fullMoon,
        ));
      }
      
      // Next New Moon
      currentNewMoon = currentNewMoon.add(Duration(days: lunarCycleDays.round()));
    }
    
    return events;
  }

  /// Generate Mercury Retrograde periods
  List<Map<String, dynamic>> _generateMercuryRetrograde(DateTime start, DateTime end) {
    final events = <Map<String, dynamic>>[];
    
    // Mercury Retrograde happens 3-4 times per year
    // Approximate dates for 2025-2026:
    final retrogradePeriods = [
      {'start': DateTime(2025, 12, 13), 'end': DateTime(2026, 1, 2)},
      {'start': DateTime(2026, 4, 1), 'end': DateTime(2026, 4, 25)},
      {'start': DateTime(2026, 8, 4), 'end': DateTime(2026, 8, 28)},
      {'start': DateTime(2026, 11, 25), 'end': DateTime(2026, 12, 15)},
    ];
    
    for (final period in retrogradePeriods) {
      final startDate = period['start'] as DateTime;
      final endDate = period['end'] as DateTime;
      
      if (startDate.isBefore(end) && endDate.isAfter(start)) {
        events.add({
          'title': 'Mercury Retrograde',
          'type': 'mercury_retrograde',
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'description': 'Mercury Retrograde is a period when Mercury appears to move backward in the sky. This astrological phenomenon is often associated with communication delays, technology glitches, and the need to review and revise plans.',
          'impact': 'During Mercury Retrograde, it\'s wise to double-check communications, back up important data, and avoid signing major contracts. Use this time for reflection, review, and revisiting past projects rather than starting new ones.',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    
    return events;
  }

  /// Generate Zodiac season changes
  List<Map<String, dynamic>> _generateZodiacSeasonChanges(DateTime start, DateTime end) {
    final events = <Map<String, dynamic>>[];
    
    // Zodiac sign dates (approximate)
    final zodiacDates = [
      {'sign': 'Aries', 'start': DateTime(start.year, 3, 21)},
      {'sign': 'Taurus', 'start': DateTime(start.year, 4, 20)},
      {'sign': 'Gemini', 'start': DateTime(start.year, 5, 21)},
      {'sign': 'Cancer', 'start': DateTime(start.year, 6, 21)},
      {'sign': 'Leo', 'start': DateTime(start.year, 7, 23)},
      {'sign': 'Virgo', 'start': DateTime(start.year, 8, 23)},
      {'sign': 'Libra', 'start': DateTime(start.year, 9, 23)},
      {'sign': 'Scorpio', 'start': DateTime(start.year, 10, 23)},
      {'sign': 'Sagittarius', 'start': DateTime(start.year, 11, 22)},
      {'sign': 'Capricorn', 'start': DateTime(start.year, 12, 22)},
      {'sign': 'Aquarius', 'start': DateTime(start.year + 1, 1, 20)},
      {'sign': 'Pisces', 'start': DateTime(start.year + 1, 2, 19)},
    ];
    
    for (final zodiac in zodiacDates) {
      final startDate = zodiac['start'] as DateTime;
      if (startDate.isAfter(start.subtract(const Duration(days: 1))) && 
          startDate.isBefore(end)) {
        events.add({
          'title': '${zodiac['sign']} Season Begins',
          'type': 'zodiac_season_change',
          'startDate': Timestamp.fromDate(startDate),
          'endDate': null,
          'description': 'The ${zodiac['sign']} season marks a shift in cosmic energy. Each zodiac sign brings its unique qualities and themes, influencing our collective and personal experiences.',
          'impact': 'This is a time to embrace the energy of ${zodiac['sign']} and align your intentions with the qualities associated with this sign.',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    
    return events;
  }

  Map<String, dynamic> _createMoonEvent(
    String title,
    DateTime date,
    AstrologicalEventType type,
  ) {
    final isNewMoon = type == AstrologicalEventType.newMoon;
    return {
      'title': title,
      'type': isNewMoon ? 'new_moon' : 'full_moon',
      'startDate': Timestamp.fromDate(date),
      'endDate': null,
      'description': isNewMoon
          ? 'The New Moon marks the beginning of a new lunar cycle. This is a powerful time for setting intentions, starting fresh, and planting seeds for future growth. The dark sky invites us to turn inward and connect with our deepest desires.'
          : 'The Full Moon represents the peak of the lunar cycle, a time of culmination, release, and illumination. Emotions may run high, and what was hidden may come to light. This is an ideal time for letting go of what no longer serves you.',
      'impact': isNewMoon
          ? 'New Moons are ideal for setting new intentions. Use this time to reflect on what you want to manifest and write down your goals. The energy is supportive of new beginnings and fresh starts.'
          : 'Full Moons are powerful times for release and completion. Reflect on what you\'ve accomplished and what you need to let go of. This is a time for gratitude and clearing space for new opportunities.',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String _generateEventId(Map<String, dynamic> event) {
    final title = (event['title'] as String).toLowerCase().replaceAll(' ', '_');
    final startDate = (event['startDate'] as Timestamp).toDate();
    final dateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    return '${title}_$dateStr';
  }
}

