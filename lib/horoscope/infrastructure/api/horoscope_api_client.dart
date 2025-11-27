import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../dtos/horoscope_news_dto.dart';

part 'horoscope_api_client.g.dart';

@RestApi()
abstract class HoroscopeApiClient {
  factory HoroscopeApiClient(Dio dio, {String baseUrl}) = _HoroscopeApiClient;

  @GET('/news')
  Future<List<HoroscopeNewsDto>> getNews();
}
