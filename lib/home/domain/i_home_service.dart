import 'package:result_type/result_type.dart';
import 'home_prediction_model.dart';

enum HomeError { network, api, unknown }

class HomeException implements Exception {
  final HomeError error;
  final String? message;
  HomeException(this.error, [this.message]);

  @override
  String toString() => message ?? error.toString();
}

abstract class IHomeService {
  /// Fetches daily astrology prediction for the user.
  ///
  /// Returns [Result.failure] with [HomeException] if the API call fails.
  Future<Result<HomePredictionModel, HomeException>> getDailyPrediction({
    required String sunSign,
    required String date,
  });
}
