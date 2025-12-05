import 'bio_metric.dart';
import 'friend_entry.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.sunSign,
    required this.moonSign,
    required this.ascendantSign,
    required this.planType,
    required this.phoneNumber,
    required this.email,
    required this.location,
    required this.bioMetrics,
    required this.friends,
  });

  final String id;
  final String displayName;
  final String avatarUrl;
  final String birthDate;
  final String birthTime;
  final String birthPlace;
  final String sunSign;
  final String moonSign;
  final String ascendantSign;
  final String planType;
  final String phoneNumber;
  final String email;
  final String location;
  final List<BioMetric> bioMetrics;
  final List<FriendEntry> friends;
}

