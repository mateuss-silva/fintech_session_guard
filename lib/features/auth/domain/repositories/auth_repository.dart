import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_tokens_entity.dart';
import '../entities/session_entity.dart';

/// Auth repository interface — domain layer contract.
///
/// Implementations in the data layer handle API calls,
/// error mapping, and secure token persistence.
abstract class AuthRepository {
  /// Login with email and password, optionally binding to a device.
  Future<Either<Failure, AuthTokensEntity>> login({
    required String email,
    required String password,
    String? deviceId,
  });

  /// Register a new user account.
  Future<Either<Failure, String>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Refresh access token using stored refresh token.
  Future<Either<Failure, void>> refreshToken();

  /// Logout and invalidate current session.
  Future<Either<Failure, void>> logout();

  /// Get all active sessions for the current user.
  Future<Either<Failure, List<SessionEntity>>> getSessions();

  /// Revoke a specific session by ID.
  Future<Either<Failure, void>> revokeSession(String sessionId);

  /// Check if user has valid stored tokens.
  Future<bool> isAuthenticated();

  /// Verify PIN and return challenge token.
  Future<Either<Failure, String>> verifyPin(String pin);

  /// Check if the user has a PIN configured.
  Future<Either<Failure, bool>> getPinStatus();

  /// Set or update the user's PIN.
  Future<Either<Failure, void>> setPin(String pin);

  /// Get a biometric challenge for verification.
  Future<Either<Failure, String>> getBiometricChallenge();

  /// Verify biometric verification and return a biometric token.
  Future<Either<Failure, String>> verifyBiometric({
    required String challenge,
    required String signature,
  });
}
