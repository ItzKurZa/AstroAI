import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../dtos/home_prediction_dto.dart';

part 'home_api_client.g.dart';

@RestApi()
abstract class HomeApiClient {
  factory HomeApiClient(Dio dio, {String baseUrl}) = _HomeApiClient;

  @GET('/daily')
  Future<HomePredictionDto> getDailyPrediction(
    @Query('sign') String sunSign,
    @Query('date') String date,
  );
}
