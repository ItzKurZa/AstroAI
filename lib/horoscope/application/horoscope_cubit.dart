import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/i_horoscope_service.dart';
import 'horoscope_state.dart';
import '../infrastructure/horoscope_service.dart';

class HoroscopeCubit extends Cubit<HoroscopeState> {
  final IHoroscopeService _service;

  HoroscopeCubit({IHoroscopeService? service})
    : _service = service ?? HoroscopeService(),
      super(HoroscopeState.initial());

  Future<void> fetchNews() async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final result = await _service.getNews();
    if (result.isSuccess) {
      emit(
        state.copyWith(news: result.success, isLoading: false, hasError: false),
      );
    } else {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
