import '../../domain/entities/notification_prefs.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_prefs_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<NotificationPrefs> fetchPrefs(String userId) {
    return _remoteDataSource.fetchPrefs(userId);
  }

  @override
  Future<void> updatePrefs(String userId, NotificationPrefs prefs) {
    final model = NotificationPrefsModel(
      dailyDigest: prefs.dailyDigest,
      friendAdded: prefs.friendAdded,
      friendAccepted: prefs.friendAccepted,
    );
    return _remoteDataSource.updatePrefs(userId, model);
  }
}

