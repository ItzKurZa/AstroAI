import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/astrological_event_model.dart';
import '../../domain/entities/astrological_event.dart';
import '../../../../core/services/local_cache_service.dart';
import '../../../../core/services/astrological_event_generator.dart';

class AstrologicalEventRemoteDataSource {
  AstrologicalEventRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Fetch current and upcoming astrological events
  /// 
  /// IMPORTANT: Follows same pattern as Home page:
  /// 1. Check local cache first (fast access, valid for 7 days)
  /// 2. Check Firebase (persistent storage)
  /// 3. If missing or outdated, auto-generate events (from ASTROLOGY_API_KEY calculations)
  /// 4. Cache results for next time
  /// 
  /// Returns events that are happening now (started but not ended) or in the next 90 days
  Future<List<AstrologicalEvent>> fetchCurrentEvents() async {
    try {
      final now = DateTime.now();
      final ninetyDaysLater = now.add(const Duration(days: 90));

      // Step 1: Check local cache first (fast access)
      final cachedEvents = await LocalCacheService.instance.getAstrologicalEvents();
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        // Convert cached data to AstrologicalEvent entities and filter
        final cached = cachedEvents.map((e) {
          try {
            final startDate = (e['startDate'] as Map<String, dynamic>?)?['seconds'] as int?;
            if (startDate == null) return null;
            
            final start = DateTime.fromMillisecondsSinceEpoch(startDate * 1000);
            final endDate = (e['endDate'] as Map<String, dynamic>?)?['seconds'] as int?;
            final end = endDate != null 
                ? DateTime.fromMillisecondsSinceEpoch(endDate * 1000)
                : null;
            
            final hasStarted = start.isBefore(now) || start.isAtSameMomentAs(now);
            final hasEnded = end != null && end.isBefore(now);
            final isUpcoming = start.isAfter(now) && start.isBefore(ninetyDaysLater);
            
            if ((hasStarted && !hasEnded) || isUpcoming) {
              return AstrologicalEvent(
                id: e['id'] as String? ?? '',
                title: e['title'] as String? ?? '',
                type: _parseEventType(e['type'] as String? ?? 'other'),
                startDate: start,
                endDate: end,
                description: e['description'] as String? ?? '',
                impact: e['impact'] as String? ?? '',
                imageUrl: e['imageUrl'] as String?,
              );
            }
          } catch (e) {
            print('⚠️ Error parsing cached event: $e');
          }
          return null;
        }).where((e) => e != null).cast<AstrologicalEvent>().toList();
        
        if (cached.isNotEmpty) {
          // Sort cached events
          cached.sort((a, b) {
            final aIsCurrent = a.startDate.isBefore(now) || a.startDate.isAtSameMomentAs(now);
            final bIsCurrent = b.startDate.isBefore(now) || b.startDate.isAtSameMomentAs(now);
            if (aIsCurrent && !bIsCurrent) return -1;
            if (!aIsCurrent && bIsCurrent) return 1;
            return a.startDate.compareTo(b.startDate);
          });
          
          print('✅ Using cached astrological events (${cached.length} events)');
          return cached;
        }
      }

      // Step 2: Check Firebase
      final snapshot = await _firestore
          .collection('astrological_events')
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(ninetyDaysLater))
          .orderBy('startDate')
          .limit(200)
          .get();

      final allEvents = snapshot.docs
          .map((doc) => AstrologicalEventModel.fromDoc(doc))
          .toList();

      print('📊 Fetched ${allEvents.length} events from Firestore');

      // Filter to get only current and upcoming events
      final currentEvents = allEvents.where((event) {
        final hasStarted = event.startDate.isBefore(now) || 
                          event.startDate.isAtSameMomentAs(now);
        final hasEnded = event.endDate != null && 
                        event.endDate!.isBefore(now);
        final isUpcoming = event.startDate.isAfter(now) && 
                          event.startDate.isBefore(ninetyDaysLater);
        
        return (hasStarted && !hasEnded) || isUpcoming;
      }).toList();

      // Step 3: If no events or too few, auto-generate (from ASTROLOGY_API_KEY calculations)
      if (currentEvents.isEmpty || currentEvents.length < 5) {
        print('📡 Auto-generating astrological events (from ASTROLOGY_API_KEY calculations)...');
        final generator = AstrologicalEventGenerator.instance;
        await generator.generateEventsForNext90Days();
        
        // Re-fetch from Firebase after generation
        final newSnapshot = await _firestore
            .collection('astrological_events')
            .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(ninetyDaysLater))
            .orderBy('startDate')
            .limit(200)
            .get();
        
        final newEvents = newSnapshot.docs
            .map((doc) => AstrologicalEventModel.fromDoc(doc))
            .toList();
        
        final filteredNewEvents = newEvents.where((event) {
          final hasStarted = event.startDate.isBefore(now) || 
                            event.startDate.isAtSameMomentAs(now);
          final hasEnded = event.endDate != null && 
                          event.endDate!.isBefore(now);
          final isUpcoming = event.startDate.isAfter(now) && 
                            event.startDate.isBefore(ninetyDaysLater);
          
          return (hasStarted && !hasEnded) || isUpcoming;
        }).toList();
        
        // Sort
        filteredNewEvents.sort((a, b) {
          final aIsCurrent = a.startDate.isBefore(now) || a.startDate.isAtSameMomentAs(now);
          final bIsCurrent = b.startDate.isBefore(now) || b.startDate.isAtSameMomentAs(now);
          if (aIsCurrent && !bIsCurrent) return -1;
          if (!aIsCurrent && bIsCurrent) return 1;
          return a.startDate.compareTo(b.startDate);
        });
        
        // Cache the new events
        final eventsToCache = filteredNewEvents.map((e) => {
          'id': e.id,
          'title': e.title,
          'type': e.type.name,
          'startDate': {'seconds': e.startDate.millisecondsSinceEpoch ~/ 1000},
          'endDate': e.endDate != null 
              ? {'seconds': e.endDate!.millisecondsSinceEpoch ~/ 1000}
              : null,
          'description': e.description,
          'impact': e.impact,
          'imageUrl': e.imageUrl,
        }).toList();
        await LocalCacheService.instance.saveAstrologicalEvents(eventsToCache);
        
        print('📊 Found ${filteredNewEvents.length} astrological events (after auto-generation)');
        return filteredNewEvents;
      }

      // Sort by start date (current events first, then upcoming)
      currentEvents.sort((a, b) {
        final aIsCurrent = a.startDate.isBefore(now) || a.startDate.isAtSameMomentAs(now);
        final bIsCurrent = b.startDate.isBefore(now) || b.startDate.isAtSameMomentAs(now);
        
        if (aIsCurrent && !bIsCurrent) return -1;
        if (!aIsCurrent && bIsCurrent) return 1;
        
        return a.startDate.compareTo(b.startDate);
      });
      
      // Cache the events for next time
      final eventsToCache = currentEvents.map((e) => {
        'id': e.id,
        'title': e.title,
        'type': e.type.name,
        'startDate': {'seconds': e.startDate.millisecondsSinceEpoch ~/ 1000},
        'endDate': e.endDate != null 
            ? {'seconds': e.endDate!.millisecondsSinceEpoch ~/ 1000}
            : null,
        'description': e.description,
        'impact': e.impact,
        'imageUrl': e.imageUrl,
      }).toList();
      await LocalCacheService.instance.saveAstrologicalEvents(eventsToCache);
      
      print('📊 Found ${currentEvents.length} astrological events');
      return currentEvents;
    } catch (e) {
      print('Error fetching astrological events: $e');
      // Try to generate events as fallback
      try {
        final generator = AstrologicalEventGenerator.instance;
        await generator.generateEventsForNext90Days();
      } catch (genError) {
        print('⚠️ Error generating events as fallback: $genError');
      }
      return [];
    }
  }

  /// Helper to parse event type from string
  AstrologicalEventType _parseEventType(String type) {
    switch (type.toLowerCase()) {
      case 'mercury_retrograde':
      case 'mercuryretrograde':
        return AstrologicalEventType.mercuryRetrograde;
      case 'full_moon':
      case 'fullmoon':
        return AstrologicalEventType.fullMoon;
      case 'new_moon':
      case 'newmoon':
        return AstrologicalEventType.newMoon;
      case 'planet_alignment':
      case 'planetalignment':
        return AstrologicalEventType.planetAlignment;
      case 'zodiac_season_change':
      case 'zodiacseasonchange':
        return AstrologicalEventType.zodiacSeasonChange;
      case 'solar_eclipse':
      case 'solareclipse':
        return AstrologicalEventType.solarEclipse;
      case 'lunar_eclipse':
      case 'lunareclipse':
        return AstrologicalEventType.lunarEclipse;
      default:
        return AstrologicalEventType.other;
  }
  }
}
