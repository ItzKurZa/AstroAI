abstract class HoroscopeApiKeys {
  static const baseUrl = String.fromEnvironment(
    'HOROSCOPE_NEWS_API_BASE_URL',
    defaultValue: '',
  ); // TODO: Set in .env
  static const newsEndpoint = '/news';
}
