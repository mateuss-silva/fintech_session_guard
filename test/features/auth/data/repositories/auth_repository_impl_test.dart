import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/core/security/secure_storage_service.dart';
import 'package:fintech_session_guard/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fintech_session_guard/features/auth/data/repositories/auth_repository_impl.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockSecureStorage = MockSecureStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      secureStorage: mockSecureStorage,
    );
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tDeviceId = 'device-123';
    final tLoginResponse = {
      'accessToken': 'access_token',
      'refreshToken': 'refresh_token',
      'user': {'id': '1', 'email': tEmail, 'name': 'Test'},
    };

    test(
      'should return AuthTokensEntity and save tokens when successful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenAnswer((_) async => tLoginResponse);
        when(
          () => mockSecureStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockSecureStorage.saveUserData(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
          deviceId: tDeviceId,
        );

        // assert
        expect(result.isRight(), true);
        final tokens = result.getOrElse(() => throw Exception());
        expect(tokens.accessToken, 'access_token');
        expect(tokens.user.id, '1');

        verify(
          () => mockSecureStorage.saveTokens(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          ),
        ).called(1);
      },
    );

    test(
      'should return AuthFailure when UnauthorizedException is thrown',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenThrow(const UnauthorizedException(message: 'Invalid'));

        // act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, const Left(AuthFailure(message: 'Invalid')));
      },
    );

    test(
      'should return NetworkFailure when NetworkException is thrown',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenThrow(const NetworkException());

        // act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, const Left(NetworkFailure()));
      },
    );
  });

  group('register', () {
    test('should return Right(userId) when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => 'user-123');

      // act
      final result = await repository.register(
        email: 'a@b.com',
        password: 'p',
        name: 'n',
      );

      // assert
      expect(result, const Right('user-123'));
    });
  });
}
