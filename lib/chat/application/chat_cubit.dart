import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/i_chat_service.dart';
import 'chat_state.dart';
import '../infrastructure/chat_service.dart';

class ChatCubit extends Cubit<ChatState> {
  final IChatService _service;

  ChatCubit({IChatService? service})
    : _service = service ?? ChatService(),
      super(ChatState.initial());

  Future<void> sendMessage(String message) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final result = await _service.sendMessage(
      message: message,
      history: state.messages,
    );
    if (result.isSuccess) {
      emit(
        state.copyWith(
          messages: result.success,
          isLoading: false,
          hasError: false,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
