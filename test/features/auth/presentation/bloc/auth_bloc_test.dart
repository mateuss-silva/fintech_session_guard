import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/core/security/secure_storage_service.dart';
import 'package:fintech_session_guard/core/security/session_monitor.dart';
import 'package:fintech_session_guard/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:fintech_session_guard/features/auth/domain/entities/user_entity.dart';
import 'package:fintech_session_guard/features/auth/domain/repositories/auth_repository.dart';
import 'package:fintech_session_guard/features/auth/domain/usecases/login_usecase.dart';
import 'package:fintech_session_guard/features/auth/domain/usecases/register_usecase.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_state.dart';

import 'package:fintech_session_guard/features/auth/domain/usecases/auth_usecases.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockGetPinStatusUseCase extends Mock implements GetPinStatusUseCase {}

class MockSetPinUseCase extends Mock implements SetPinUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorage extends Mock implements SecureStorageService {}

class MockSessionMonitor extends Mock implements SessionMonitor {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockGetPinStatusUseCase mockGetPinStatusUseCase;
  late MockSetPinUseCase mockSetPinUseCase;
  late MockAuthRepository mockAuthRepository;
  late MockSecureStorage mockSecureStorage;
  late MockSessionMonitor mockSessionMonitor;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockGetPinStatusUseCase = MockGetPinStatusUseCase();
    mockSetPinUseCase = MockSetPinUseCase();
    mockAuthRepository = MockAuthRepository();
    mockSecureStorage = MockSecureStorage();
    mockSessionMonitor = MockSessionMonitor();

    when(
      () => mockSessionMonitor.onSessionExpired,
    ).thenAnswer((_) => Stream.empty());

    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterParams(email: '', name: '', password: ''),
    );

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      getPinStatusUseCase: mockGetPinStatusUseCase,
      setPinUseCase: mockSetPinUseCase,
      authRepository: mockAuthRepository,
      secureStorage: mockSecureStorage,
      sessionMonitor: mockSessionMonitor,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(id: '1', email: tEmail, name: 'Test');
  final tTokens = AuthTokensEntity(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: tUser,
  );

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when successful',
      build: () {
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => Right(tTokens));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when fails',
      build: () {
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => const Left(AuthFailure(message: 'Error')));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [const AuthLoading(), const AuthError('Error')],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthInitial] when successful',
      build: () {
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
    );
  });
}
