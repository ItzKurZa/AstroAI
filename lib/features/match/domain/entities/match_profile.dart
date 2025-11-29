class MatchProfile {
  const MatchProfile({
    required this.id,
    required this.name,
    required this.pronouns,
    required this.location,
    required this.sunSign,
    required this.moonSign,
    required this.tags,
    required this.category,
    required this.bio,
    required this.avatarUrl,
    this.ascendantSign,
    this.userId,
    this.distance,
  });

  final String id;
  final String name;
  final String pronouns;
  final String location;
  final String sunSign;
  final String moonSign;
  final String? ascendantSign;
  final List<String> tags;
  final String category;
  final String bio;
  final String avatarUrl;
  final String? userId; // Firebase user ID for chat
  final double? distance; // Distance in km
}

