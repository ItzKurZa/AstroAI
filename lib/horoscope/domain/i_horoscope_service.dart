import 'package:result_type/result_type.dart';
import 'horoscope_news_model.dart';

enum HoroscopeError { network, api, unknown }

class HoroscopeException implements Exception {
  final HoroscopeError error;
  final String? message;
  HoroscopeException(this.error, [this.message]);

  @override
  String toString() => message ?? error.toString();
}

abstract class IHoroscopeService {
  /// Fetches latest horoscope news articles.
  ///
  /// Returns [Result.failure] with [HoroscopeException] if the API call fails.
  Future<Result<List<HoroscopeNewsModel>, HoroscopeException>> getNews();
}
