import 'package:dio/dio.dart';
import 'package:result_type/result_type.dart';
import '../domain/i_home_service.dart';
import '../domain/home_prediction_model.dart';
import 'dtos/home_prediction_dto.dart';
import 'constants/home_api_keys.dart';
import '../../core/api/http_client.dart';

class HomeService implements IHomeService {
  final Dio _dio;

  HomeService({Dio? dio})
    : _dio = dio ?? HttpClient.createDio(baseUrl: HomeApiKeys.baseUrl);

  @override
  Future<Result<HomePredictionModel, HomeException>> getDailyPrediction({
    required String sunSign,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        HomeApiKeys.dailyPredictionEndpoint,
        queryParameters: {'sign': sunSign, 'date': date},
      );
      final dto = HomePredictionDto.fromJson(response.data);
      return Success(dto.toDomain());
    } on DioException catch (_) {
      return Failure(HomeException(HomeError.network));
    } catch (_) {
      return Failure(HomeException(HomeError.unknown));
    }
  }
}
