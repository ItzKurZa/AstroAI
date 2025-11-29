import 'planetary_position.dart';
import 'house_position.dart';

/// Represents a complete birth chart with planetary positions and house cusps
class BirthChart {
  const BirthChart({
    required this.birthDateTime,
    required this.latitude,
    required this.longitude,
    required this.planets,
    required this.houses,
    required this.ascendant,
    required this.midheaven,
  });

  final DateTime birthDateTime;
  final double latitude; // Birth location latitude
  final double longitude; // Birth location longitude
  final List<PlanetaryPosition> planets; // All planetary positions
  final List<HousePosition> houses; // All house cusps (1-12)
  final PlanetaryPosition ascendant; // 1st house cusp (Ascendant)
  final PlanetaryPosition midheaven; // 10th house cusp (Midheaven)

  /// Get a planet by name
  PlanetaryPosition? getPlanet(String planetName) {
    try {
      return planets.firstWhere(
        (p) => p.planetName.toLowerCase() == planetName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get a house by number (1-12)
  HousePosition? getHouse(int houseNumber) {
    try {
      return houses.firstWhere(
        (h) => h.houseNumber == houseNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get sun sign from Sun planet position
  String? get sunSign => getPlanet('Sun')?.zodiacSign;

  /// Get moon sign from Moon planet position
  String? get moonSign => getPlanet('Moon')?.zodiacSign;

  /// Get ascendant sign
  String get ascendantSign => ascendant.zodiacSign;

  @override
  String toString() {
    return 'BirthChart(${birthDateTime.toIso8601String()}, ${planets.length} planets, ${houses.length} houses)';
  }
}

