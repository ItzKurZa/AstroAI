import '../../domain/entities/horoscope_article.dart';
import '../../domain/repositories/horoscope_repository.dart';
import '../datasources/horoscope_remote_data_source.dart';

class HoroscopeRepositoryImpl implements HoroscopeRepository {
  HoroscopeRepositoryImpl(this._remoteDataSource);

  final HoroscopeRemoteDataSource _remoteDataSource;

  @override
  Future<List<HoroscopeArticle>> fetchArticles() {
    return _remoteDataSource.fetchArticles();
  }
}

