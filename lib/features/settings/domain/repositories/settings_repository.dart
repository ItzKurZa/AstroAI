abstract class SettingsRepository {
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> changePhoneNumber(String newPhoneNumber);
  Future<void> wipeAccount();
  Future<void> logOut();
  Future<void> contactSupport({
    required String subject,
    required String message,
  });
}

