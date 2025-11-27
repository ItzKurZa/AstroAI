import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/i_auth_service.dart';
import '../infrastructure/auth_service.dart';
// import '../domain/auth_user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthService _authService;

  AuthCubit({IAuthService? authService})
    : _authService = authService ?? AuthService(),
      super(const AuthState.initial());

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(const AuthState.loading());
    final result = await _authService.signUp(
      email: email,
      password: password,
      username: username,
    );
    result.isSuccess
        ? emit(AuthState.authenticated(result.success))
        : emit(AuthState.error(result.failure));
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthState.loading());
    final result = await _authService.signIn(email: email, password: password);
    result.isSuccess
        ? emit(AuthState.authenticated(result.success))
        : emit(AuthState.error(result.failure));
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    final result = await _authService.signOut();
    result.isSuccess
        ? emit(const AuthState.unauthenticated())
        : emit(AuthState.error(result.failure));
  }

  Future<void> checkAuth() async {
    emit(const AuthState.loading());
    final user = await _authService.getCurrentUser();
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }
}
