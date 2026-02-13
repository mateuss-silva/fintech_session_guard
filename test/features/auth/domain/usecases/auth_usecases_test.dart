import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:fintech_session_guard/features/auth/domain/entities/user_entity.dart';
import 'package:fintech_session_guard/features/auth/domain/repositories/auth_repository.dart';
import 'package:fintech_session_guard/features/auth/domain/usecases/login_usecase.dart';
import 'package:fintech_session_guard/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
    registerUseCase = RegisterUseCase(mockAuthRepository);
  });

  group('LoginUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tTokens = AuthTokensEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      user: const UserEntity(id: '1', email: tEmail, name: 'Test'),
    );

    test('should call repository.login and return tokens', () async {
      // arrange
      when(
        () => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => Right(tTokens));

      // act
      final result = await loginUseCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // assert
      expect(result, Right(tTokens));
      verify(
        () => mockAuthRepository.login(email: tEmail, password: tPassword),
      ).called(1);
    });

    test('should return failure when repository.login fails', () async {
      // arrange
      when(
        () => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => const Left(AuthFailure(message: 'Error')));

      // act
      final result = await loginUseCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // assert
      expect(result, const Left(AuthFailure(message: 'Error')));
    });
  });

  group('RegisterUseCase', () {
    test('should call repository.register and return userId', () async {
      // arrange
      when(
        () => mockAuthRepository.register(
          email: any(named: 'email'),
          name: any(named: 'name'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right('user-123'));

      // act
      final result = await registerUseCase(
        const RegisterParams(email: 'a@b.com', name: 'Name', password: 'Pass'),
      );

      // assert
      expect(result, const Right('user-123'));
      verify(
        () => mockAuthRepository.register(
          email: 'a@b.com',
          name: 'Name',
          password: 'Pass',
        ),
      ).called(1);
    });
  });
}
