import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Auth repository implementation — maps data-layer exceptions to domain Failures.
///
/// This is the boundary between data and domain layers in Clean Architecture.
/// All exceptions are caught here and converted to typed [Failure]s using
/// [Either] for functional error handling.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorage;

  @override
  Future<Either<Failure, AuthTokensEntity>> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      final data = await _remoteDataSource.login(
        email: email,
        password: password,
        deviceId: deviceId,
      );

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = AuthTokensEntity(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        user: user,
      );

      // Persist tokens securely (Keychain/Keystore — never SharedPreferences)
      await _secureStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _secureStorage.saveUserData(
        userId: user.id,
        email: user.email,
        name: user.name,
      );

      return Right(tokens);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userId = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      return Right(userId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return const Left(
          AuthFailure(
            message: 'No refresh token available',
            code: 'NO_REFRESH_TOKEN',
          ),
        );
      }
      // The ApiClient interceptor handles the actual refresh
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      await _remoteDataSource.logout(refreshToken);
      await _secureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      // Even if logout API fails, clear local data
      await _secureStorage.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessions() async {
    try {
      final sessions = await _remoteDataSource.getSessions();
      return Right(sessions);
    } on SessionExpiredException {
      return const Left(SessionExpiredFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revokeSession(String sessionId) async {
    try {
      await _remoteDataSource.revokeSession(sessionId);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() => _secureStorage.hasTokens();

  @override
  Future<Either<Failure, String>> verifyPin(String pin) async {
    try {
      final token = await _remoteDataSource.verifyPin(pin);
      return Right(token);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> getPinStatus() async {
    try {
      final status = await _remoteDataSource.getPinStatus();
      return Right(status);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPin(String pin) async {
    try {
      await _remoteDataSource.setPin(pin);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
