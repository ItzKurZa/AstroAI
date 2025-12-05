import 'package:result_type/result_type.dart';
import 'auth_user_model.dart';

enum AuthError {
  network,
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  unknown,
}

class AuthException implements Exception {
  final AuthError error;
  final String? message;
  AuthException(this.error, [this.message]);

  @override
  String toString() => message ?? error.toString();
}

abstract class IAuthService {
  /// Signs up a user with email and password.
  Future<Result<AuthUserModel, AuthException>> signUp({
    required String email,
    required String password,
    required String username,
  });

  /// Signs in a user with email and password.
  Future<Result<AuthUserModel, AuthException>> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<Result<void, AuthException>> signOut();

  /// Returns the currently signed-in user, or null if not signed in.
  Future<AuthUserModel?> getCurrentUser();
}
