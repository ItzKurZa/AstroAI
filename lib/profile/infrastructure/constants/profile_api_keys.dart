abstract class ProfileApiKeys {
  static const baseUrl = String.fromEnvironment(
    'FIREBASE_API_URL',
    defaultValue: '',
  ); // TODO: Set in .env
  static const profileEndpoint = '/profile';
}
