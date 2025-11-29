import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/astrological_event_model.dart';
import '../../domain/entities/astrological_event.dart';

class AstrologicalEventRemoteDataSource {
  AstrologicalEventRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Fetch current and upcoming astrological events
  /// Returns events that are happening now (started but not ended) or in the next 30 days
  Future<List<AstrologicalEvent>> fetchCurrentEvents() async {
    try {
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      // Fetch events that:
      // 1. Have started (startDate <= now) and not ended yet (endDate >= now or null)
      // 2. Or will start in the next 30 days
      final snapshot = await _firestore
          .collection('astrological_events')
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(thirtyDaysLater))
          .orderBy('startDate')
          .limit(20)
          .get();

      final allEvents = snapshot.docs
          .map((doc) => AstrologicalEventModel.fromDoc(doc))
          .toList();

      // Filter to get only current and upcoming events
      final currentEvents = allEvents.where((event) {
        // Event is current if it has started and not ended
        final hasStarted = event.startDate.isBefore(now) || 
                          event.startDate.isAtSameMomentAs(now);
        final hasEnded = event.endDate != null && 
                        event.endDate!.isBefore(now);
        
        // Event is upcoming if it starts in the future (within 30 days)
        final isUpcoming = event.startDate.isAfter(now) && 
                          event.startDate.isBefore(thirtyDaysLater);
        
        return (hasStarted && !hasEnded) || isUpcoming;
      }).toList();

      // Sort by start date (current events first, then upcoming)
      currentEvents.sort((a, b) {
        // Current events (started) come first
        final aIsCurrent = a.startDate.isBefore(now) || a.startDate.isAtSameMomentAs(now);
        final bIsCurrent = b.startDate.isBefore(now) || b.startDate.isAtSameMomentAs(now);
        
        if (aIsCurrent && !bIsCurrent) return -1;
        if (!aIsCurrent && bIsCurrent) return 1;
        
        // Within same category, sort by start date
        return a.startDate.compareTo(b.startDate);
      });
      
      // Return top 10 most relevant events
      return currentEvents.take(10).toList();
    } catch (e) {
      print('Error fetching astrological events: $e');
      // Return empty list instead of sample data
      // Events should be generated from real astronomical data
      return [];
    }
  }

  // Note: Sample events have been removed
  // Astrological events should be generated from real astronomical data
  // or fetched from external APIs, not from hardcoded sample data
}



