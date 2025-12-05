import 'package:flutter_test/flutter_test.dart';
import 'package:ai_astrologer/auth/application/auth_cubit.dart';
import 'package:ai_astrologer/auth/application/auth_state.dart';
import 'package:ai_astrologer/auth/domain/i_auth_service.dart';
import 'package:ai_astrologer/auth/domain/auth_user_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_type/result_type.dart';

class MockAuthService extends Mock implements IAuthService {}

void main() {
  setUpAll(() {
    registerFallbackValue(AuthUserModel());
    registerFallbackValue(AuthException(AuthError.unknown));
  });
  group('AuthCubit', () {
    late MockAuthService mockService;
    late AuthCubit cubit;

    setUp(() {
      mockService = MockAuthService();
      cubit = AuthCubit(authService: mockService);
    });

    test('initial state is AuthState.initial()', () {
      expect(cubit.state, const AuthState.initial());
    });

    test('emits [loading, authenticated] on successful signUp', () async {
      final user = AuthUserModel(
        uid: '1',
        email: 'test@test.com',
        username: 'test',
        photoUrl: '',
      );
      when(
        () => mockService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
        ),
      ).thenAnswer((_) async => Success(user));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthState.loading(),
          AuthState.authenticated(user),
        ]),
      );
      await cubit.signUp(
        email: 'test@test.com',
        password: 'pass',
        username: 'test',
      );
    });

    test('emits [loading, error] on failed signUp', () async {
      final error = AuthException(AuthError.unknown);
      when(
        () => mockService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
        ),
      ).thenAnswer((_) async => Failure(error));

      expectLater(
        cubit.stream,
        emitsInOrder([const AuthState.loading(), AuthState.error(error)]),
      );
      await cubit.signUp(
        email: 'fail@test.com',
        password: 'fail',
        username: 'fail',
      );
    });
  });
}
