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
  });

  factory MatchProfileModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return MatchProfileModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      pronouns: data['pronouns'] as String? ?? '',
      location: data['location'] as String? ?? '',
      sunSign: data['sunSign'] as String? ?? '',
      moonSign: data['moonSign'] as String? ?? '',
      tags: (data['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      category: data['category'] as String? ?? 'friendship',
      bio: data['bio'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
    );
  }
}

