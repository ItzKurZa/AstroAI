import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/auth_user_model.dart';
import '../domain/i_auth_service.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AuthUserModel user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(AuthException error) = _Error;
}
