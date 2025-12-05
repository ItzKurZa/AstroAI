/// Represents a house cusp position in the birth chart
class HousePosition {
  const HousePosition({
    required this.houseNumber,
    required this.longitude,
    required this.zodiacSign,
    required this.degreesInSign,
    required this.minutesInSign,
    required this.secondsInSign,
  });

  final int houseNumber; // House number (1-12)
  final double longitude; // Ecliptic longitude of the house cusp (0-360)
  final String zodiacSign; // Zodiac sign name (e.g., "Aries", "Taurus")
  final double degreesInSign; // Degrees within the sign (0-30)
  final int minutesInSign; // Arc minutes within the sign
  final int secondsInSign; // Arc seconds within the sign

  /// Format as "XX°XX'XX""
  String get formattedDegrees {
    return '${degreesInSign.toStringAsFixed(0)}°${minutesInSign.toString().padLeft(2, '0')}\'${secondsInSign.toString().padLeft(2, '0')}"';
  }

  /// Format as "House X in Sign (XX°XX'XX"")"
  String get displayString {
    return 'House $houseNumber in $zodiacSign ($formattedDegrees)';
  }

  @override
  String toString() => displayString;
}

