/// Represents a planetary position in the birth chart
class PlanetaryPosition {
  const PlanetaryPosition({
    required this.planetName,
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.speed,
    required this.zodiacSign,
    required this.degreesInSign,
    required this.minutesInSign,
    required this.secondsInSign,
  });

  final String planetName;
  final double longitude; // Ecliptic longitude in degrees (0-360)
  final double latitude; // Ecliptic latitude in degrees
  final double distance; // Distance from Earth (AU)
  final double speed; // Daily motion in degrees
  final String zodiacSign; // Zodiac sign name (e.g., "Aries", "Taurus")
  final double degreesInSign; // Degrees within the sign (0-30)
  final int minutesInSign; // Arc minutes within the sign
  final int secondsInSign; // Arc seconds within the sign

  /// Format as "XX°XX'XX""
  String get formattedDegrees {
    return '${degreesInSign.toStringAsFixed(0)}°${minutesInSign.toString().padLeft(2, '0')}\'${secondsInSign.toString().padLeft(2, '0')}"';
  }

  /// Format as "Planet in Sign (XX°XX'XX"")"
  String get displayString {
    return '$planetName in $zodiacSign ($formattedDegrees)';
  }

  @override
  String toString() => displayString;
}

