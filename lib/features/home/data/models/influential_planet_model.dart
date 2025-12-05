import '../../domain/entities/influential_planet.dart';

class InfluentialPlanetModel extends InfluentialPlanet {
  InfluentialPlanetModel({
    required super.planet,
    required super.zodiac,
    required super.degrees,
  });

  factory InfluentialPlanetModel.fromMap(Map<String, dynamic> data) {
    return InfluentialPlanetModel(
      planet: data['planet'] as String? ?? '',
      zodiac: data['zodiac'] as String? ?? '',
      degrees: data['degrees'] as String? ?? '',
    );
  }
}

