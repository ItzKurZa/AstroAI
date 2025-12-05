import '../../domain/entities/notification_prefs.dart';

class NotificationPrefsModel extends NotificationPrefs {
  NotificationPrefsModel({
    required super.dailyDigest,
    required super.friendAdded,
    required super.friendAccepted,
  });

  factory NotificationPrefsModel.fromMap(Map<String, dynamic> data) {
    return NotificationPrefsModel(
      dailyDigest: data['dailyDigest'] as bool? ?? true,
      friendAdded: data['friendAdded'] as bool? ?? true,
      friendAccepted: data['friendAccepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyDigest': dailyDigest,
      'friendAdded': friendAdded,
      'friendAccepted': friendAccepted,
    };
  }
}

