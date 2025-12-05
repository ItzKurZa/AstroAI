abstract class HomeApiKeys {
  static const baseUrl = String.fromEnvironment(
    'ASTROLOGY_API_BASE_URL',
    defaultValue: '',
  ); // TODO: Set in .env
  static const dailyPredictionEndpoint = '/daily';
}
