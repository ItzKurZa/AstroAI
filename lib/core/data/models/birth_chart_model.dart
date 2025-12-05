import '../../domain/entities/birth_chart.dart';
import '../../domain/entities/house_position.dart';
import '../../domain/entities/planetary_position.dart';

/// Model for BirthChart (can be extended for Firestore serialization)
class BirthChartModel extends BirthChart {
  BirthChartModel({
    required super.birthDateTime,
    required super.latitude,
    required super.longitude,
    required super.planets,
    required super.houses,
    required super.ascendant,
    required super.midheaven,
  });

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'birthDateTime': birthDateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'planets': planets.map((p) => {
            'planetName': p.planetName,
            'longitude': p.longitude,
            'latitude': p.latitude,
            'distance': p.distance,
            'speed': p.speed,
            'zodiacSign': p.zodiacSign,
            'degreesInSign': p.degreesInSign,
            'minutesInSign': p.minutesInSign,
            'secondsInSign': p.secondsInSign,
          }).toList(),
      'houses': houses.map((h) => {
            'houseNumber': h.houseNumber,
            'longitude': h.longitude,
            'zodiacSign': h.zodiacSign,
            'degreesInSign': h.degreesInSign,
            'minutesInSign': h.minutesInSign,
            'secondsInSign': h.secondsInSign,
          }).toList(),
      'ascendant': {
        'planetName': ascendant.planetName,
        'longitude': ascendant.longitude,
        'zodiacSign': ascendant.zodiacSign,
        'degreesInSign': ascendant.degreesInSign,
        'minutesInSign': ascendant.minutesInSign,
        'secondsInSign': ascendant.secondsInSign,
      },
      'midheaven': {
        'planetName': midheaven.planetName,
        'longitude': midheaven.longitude,
        'zodiacSign': midheaven.zodiacSign,
        'degreesInSign': midheaven.degreesInSign,
        'minutesInSign': midheaven.minutesInSign,
        'secondsInSign': midheaven.secondsInSign,
      },
    };
  }

  /// Create from BirthChart entity
  factory BirthChartModel.fromBirthChart(BirthChart birthChart) {
    return BirthChartModel(
      birthDateTime: birthChart.birthDateTime,
      latitude: birthChart.latitude,
      longitude: birthChart.longitude,
      planets: birthChart.planets,
      houses: birthChart.houses,
      ascendant: birthChart.ascendant,
      midheaven: birthChart.midheaven,
    );
  }

  /// Create from Map
  factory BirthChartModel.fromMap(Map<String, dynamic> map) {
    final planets = (map['planets'] as List<dynamic>)
        .map((p) => PlanetaryPosition(
              planetName: p['planetName'] as String,
              longitude: (p['longitude'] as num).toDouble(),
              latitude: (p['latitude'] as num).toDouble(),
              distance: (p['distance'] as num).toDouble(),
              speed: (p['speed'] as num).toDouble(),
              zodiacSign: p['zodiacSign'] as String,
              degreesInSign: (p['degreesInSign'] as num).toDouble(),
              minutesInSign: p['minutesInSign'] as int,
              secondsInSign: p['secondsInSign'] as int,
            ))
        .toList();

    final houses = (map['houses'] as List<dynamic>)
        .map((h) => HousePosition(
              houseNumber: h['houseNumber'] as int,
              longitude: (h['longitude'] as num).toDouble(),
              zodiacSign: h['zodiacSign'] as String,
              degreesInSign: (h['degreesInSign'] as num).toDouble(),
              minutesInSign: h['minutesInSign'] as int,
              secondsInSign: h['secondsInSign'] as int,
            ))
        .toList();

    final ascMap = map['ascendant'] as Map<String, dynamic>;
    final ascendant = PlanetaryPosition(
      planetName: ascMap['planetName'] as String,
      longitude: (ascMap['longitude'] as num).toDouble(),
      latitude: 0,
      distance: 0,
      speed: 0,
      zodiacSign: ascMap['zodiacSign'] as String,
      degreesInSign: (ascMap['degreesInSign'] as num).toDouble(),
      minutesInSign: ascMap['minutesInSign'] as int,
      secondsInSign: ascMap['secondsInSign'] as int,
    );

    final mcMap = map['midheaven'] as Map<String, dynamic>;
    final midheaven = PlanetaryPosition(
      planetName: mcMap['planetName'] as String,
      longitude: (mcMap['longitude'] as num).toDouble(),
      latitude: 0,
      distance: 0,
      speed: 0,
      zodiacSign: mcMap['zodiacSign'] as String,
      degreesInSign: (mcMap['degreesInSign'] as num).toDouble(),
      minutesInSign: mcMap['minutesInSign'] as int,
      secondsInSign: mcMap['secondsInSign'] as int,
    );

    return BirthChartModel(
      birthDateTime: DateTime.parse(map['birthDateTime'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      planets: planets,
      houses: houses,
      ascendant: ascendant,
      midheaven: midheaven,
    );
  }
}

