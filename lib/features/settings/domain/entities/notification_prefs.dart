class NotificationPrefs {
  const NotificationPrefs({
    required this.dailyDigest,
    required this.friendAdded,
    required this.friendAccepted,
  });

  final bool dailyDigest;
  final bool friendAdded;
  final bool friendAccepted;

  NotificationPrefs copyWith({
    bool? dailyDigest,
    bool? friendAdded,
    bool? friendAccepted,
  }) {
    return NotificationPrefs(
      dailyDigest: dailyDigest ?? this.dailyDigest,
      friendAdded: friendAdded ?? this.friendAdded,
      friendAccepted: friendAccepted ?? this.friendAccepted,
    );
  }
}

