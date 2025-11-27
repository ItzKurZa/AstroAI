import 'package:dio/dio.dart';
import 'package:result_type/result_type.dart';
import '../domain/i_horoscope_service.dart';
import '../domain/horoscope_news_model.dart';
import 'dtos/horoscope_news_dto.dart';
import 'constants/horoscope_api_keys.dart';
import '../../core/api/http_client.dart';

class HoroscopeService implements IHoroscopeService {
  final Dio _dio;

  HoroscopeService({Dio? dio})
    : _dio = dio ?? HttpClient.createDio(baseUrl: HoroscopeApiKeys.baseUrl);

  @override
  Future<Result<List<HoroscopeNewsModel>, HoroscopeException>> getNews() async {
    try {
      final response = await _dio.get(HoroscopeApiKeys.newsEndpoint);
      final List<dynamic> data = response.data as List<dynamic>;
      final dtos = data
          .map(
            (json) => HoroscopeNewsDto.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Success(dtos.map((dto) => dto.toDomain()).toList());
    } on DioException catch (_) {
      return Failure(HoroscopeException(HoroscopeError.network));
    } catch (_) {
      return Failure(HoroscopeException(HoroscopeError.unknown));
    }
  }
}
