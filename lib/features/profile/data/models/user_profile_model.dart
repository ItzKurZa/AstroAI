import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/bio_metric.dart';
import '../../domain/entities/friend_entry.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.displayName,
    required super.avatarUrl,
    required super.birthDate,
    required super.birthTime,
    required super.birthPlace,
    required super.sunSign,
    required super.moonSign,
    required super.ascendantSign,
    required super.planType,
    required super.phoneNumber,
    required super.email,
    required super.location,
    required super.bioMetrics,
    required super.friends,
  });

  factory UserProfileModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfileModel(
      id: doc.id,
      displayName: data['displayName'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      birthDate: data['birthDate'] as String? ?? '',
      birthTime: data['birthTime'] as String? ?? '',
      birthPlace: data['birthPlace'] as String? ?? '',
      sunSign: data['sunSign'] as String? ?? '',
      moonSign: data['moonSign'] as String? ?? '',
      ascendantSign: data['ascendantSign'] as String? ?? '',
      planType: data['planType'] as String? ?? 'Free',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      location: data['location'] as String? ?? data['birthPlace'] as String? ?? '',
      bioMetrics: (data['bioTable'] as List<dynamic>? ?? [])
          .map(
            (entry) => BioMetric(
              label: (entry as Map)['label'] as String? ?? '',
              value: entry['value'] as String? ?? '',
            ),
          )
          .toList(),
      friends: (data['friends'] as List<dynamic>? ?? [])
          .map(
            (entry) => FriendEntry(
              name: (entry as Map)['name'] as String? ?? '',
              compatibility: entry['compatibility'] as String? ?? '',
              signs: (entry['signs'] as List<dynamic>? ?? [])
                  .map((e) => e.toString())
                  .toList(),
              avatarUrl: entry['avatarUrl'] as String? ?? '',
            ),
          )
          .toList(),
    );
  }
}

