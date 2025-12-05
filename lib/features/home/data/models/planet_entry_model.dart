import '../../domain/entities/planet_entry.dart';

class PlanetEntryModel extends PlanetEntry {
  PlanetEntryModel({
    required super.name,
    required super.zodiac,
    required super.degrees,
    required super.description,
    required super.imageUrl,
    required super.accentColor,
  });

  factory PlanetEntryModel.fromMap(Map<String, dynamic> data) {
    return PlanetEntryModel(
      name: data['name'] as String? ?? '',
      zodiac: data['zodiac'] as String? ?? '',
      degrees: data['degrees'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      accentColor: data['accentColor'] as String? ?? '#BCA8F4',
    );
  }
}

