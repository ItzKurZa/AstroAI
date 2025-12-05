import '../entities/horoscope_article.dart';

abstract class HoroscopeRepository {
  Future<List<HoroscopeArticle>> fetchArticles();
}

