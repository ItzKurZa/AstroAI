import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/i_home_service.dart';
import 'home_state.dart';
import '../infrastructure/home_service.dart';

class HomeCubit extends Cubit<HomeState> {
  final IHomeService _service;

  HomeCubit({IHomeService? service})
    : _service = service ?? HomeService(),
      super(HomeState.initial());

  Future<void> initialize() async {
    // Default values - in a real app, this would use user's actual zodiac sign and current date
    await fetchDailyPrediction(
      sunSign: 'Leo',
      date: DateTime.now().toString().split(' ')[0],
    );
  }

  Future<void> fetchDailyPrediction({
    required String sunSign,
    required String date,
  }) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final result = await _service.getDailyPrediction(
      sunSign: sunSign,
      date: date,
    );
    if (result.isSuccess) {
      emit(
        state.copyWith(
          prediction: result.success,
          isLoading: false,
          hasError: false,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
