import '../entities/notification_prefs.dart';

abstract class NotificationRepository {
  Future<NotificationPrefs> fetchPrefs(String userId);
  Future<void> updatePrefs(String userId, NotificationPrefs prefs);
}

