import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);

  final SettingsRemoteDataSource _dataSource;

  @override
  Future<void> changePassword(String currentPassword, String newPassword) {
    return _dataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> changePhoneNumber(String newPhoneNumber) {
    return _dataSource.changePhoneNumber(newPhoneNumber);
  }

  @override
  Future<void> wipeAccount() {
    return _dataSource.wipeAccount();
  }

  @override
  Future<void> logOut() {
    return _dataSource.logOut();
  }

  @override
  Future<void> contactSupport({
    required String subject,
    required String message,
  }) {
    return _dataSource.contactSupport(subject: subject, message: message);
  }
}

