/// Entity representing an important astrological event
class AstrologicalEvent {
  const AstrologicalEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.impact,
    this.imageUrl,
  });

  final String id;
  final String title;
  final AstrologicalEventType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String description; // Long explanation text
  final String impact; // General impact on people
  final String? imageUrl;
}

enum AstrologicalEventType {
  mercuryRetrograde,
  fullMoon,
  newMoon,
  planetAlignment,
  zodiacSeasonChange,
  solarEclipse,
  lunarEclipse,
  other,
}

