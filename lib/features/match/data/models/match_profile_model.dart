import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/match_profile.dart';

class MatchProfileModel extends MatchProfile {
  MatchProfileModel({
    required super.id,
    required super.name,
    required super.pronouns,
    required super.location,
    required super.sunSign,
    required super.moonSign,
    required super.tags,
    required super.category,
    required super.bio,
    required super.avatarUrl,
    super.ascendantSign,
    super.userId,
    super.distance,
  });

  factory MatchProfileModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    double? distance,
  }) {
    final data = doc.data() ?? {};
    return MatchProfileModel(
      id: doc.id,
      name: data['displayName'] as String? ?? data['name'] as String? ?? 'User',
      pronouns: data['pronouns'] as String? ?? 'They/Them',
      location: data['birthPlace'] as String? ?? 
                data['location'] as String? ?? 
                'Unknown',
      sunSign: data['sunSign'] as String? ?? 'Unknown',
      moonSign: data['moonSign'] as String? ?? 'Unknown',
      ascendantSign: data['ascendantSign'] as String?,
      tags: (data['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      category: 'friendship', // All nearby users are friendship
      bio: data['bio'] as String? ?? 
           'Astrology enthusiast • ${data['sunSign'] ?? 'Unknown'} Sun, ${data['moonSign'] ?? 'Unknown'} Moon',
      avatarUrl: data['avatarUrl'] as String? ?? 'assets/images/app/logo.png',
      userId: doc.id, // Use Firebase user ID
      distance: distance,
    );
  }

  /// Create from user data map (for nearby users)
  factory MatchProfileModel.fromUserData({
    required String userId,
    required Map<String, dynamic> data,
    double? distance,
  }) {
    return MatchProfileModel(
      id: userId,
      name: data['displayName'] as String? ?? data['name'] as String? ?? 'User',
      pronouns: data['pronouns'] as String? ?? 'They/Them',
      location: data['birthPlace'] as String? ?? 
                data['location'] as String? ?? 
                'Unknown',
      sunSign: data['sunSign'] as String? ?? 'Unknown',
      moonSign: data['moonSign'] as String? ?? 'Unknown',
      ascendantSign: data['ascendantSign'] as String?,
      tags: (data['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      category: 'friendship',
      bio: data['bio'] as String? ?? 
           'Astrology enthusiast • ${data['sunSign'] ?? 'Unknown'} Sun, ${data['moonSign'] ?? 'Unknown'} Moon',
      avatarUrl: data['avatarUrl'] as String? ?? 'assets/images/app/logo.png',
      userId: userId,
      distance: distance,
    );
  }
}

