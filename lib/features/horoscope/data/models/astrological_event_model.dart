import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/astrological_event.dart';

class AstrologicalEventModel {
  static AstrologicalEvent fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AstrologicalEvent(
      id: doc.id,
      title: data['title'] as String? ?? 'Astrological Event',
      type: _parseEventType(data['type'] as String? ?? 'other'),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      description: data['description'] as String? ?? '',
      impact: data['impact'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  static Map<String, dynamic> toMap(AstrologicalEvent event) {
    return {
      'title': event.title,
      'type': event.type.name,
      'startDate': Timestamp.fromDate(event.startDate),
      if (event.endDate != null) 'endDate': Timestamp.fromDate(event.endDate!),
      'description': event.description,
      'impact': event.impact,
      if (event.imageUrl != null) 'imageUrl': event.imageUrl,
    };
  }

  static AstrologicalEventType _parseEventType(String type) {
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

