import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/core/security/biometric_service.dart';
import 'package:fintech_session_guard/features/auth/domain/repositories/auth_repository.dart';
import 'package:fintech_session_guard/core/presentation/widgets/pin_auth_dialog.dart';

/// Result of a transaction authentication attempt.
///
/// Contains the credential type and value needed by the backend.
class AuthResult {
  /// `null` if authentication failed or was cancelled.
  final String? pin;
  final String? biometricToken;

  const AuthResult._({this.pin, this.biometricToken});

  /// Authentication was cancelled or failed.
  static const cancelled = AuthResult._();

  /// Authenticated via biometric verification.
  factory AuthResult.biometric(String token) =>
      AuthResult._(biometricToken: token);

  /// Authenticated via PIN.
  factory AuthResult.pinVerified(String pin) => AuthResult._(pin: pin);

  /// Whether authentication succeeded.
  bool get isAuthenticated => pin != null || biometricToken != null;
}

/// Reusable helper that authenticates a user via biometrics with PIN fallback.
///
/// Flow:
/// 1. Check if biometrics are available
/// 2. If yes → challenge → local auth → backend verify → return [AuthResult]
/// 3. If biometrics fail or unavailable → show PIN dialog → return [AuthResult]
class TransactionAuthHelper {
  TransactionAuthHelper._();

  static final _logger = Logger();

  /// Authenticates the user for a sensitive transaction.
  ///
  /// Returns an [AuthResult] containing the credential for the backend.
  static Future<AuthResult> authenticate(
    BuildContext context, {
    required String reason,
  }) async {
    final biometricService = sl<BiometricService>();
    final authRepository = sl<AuthRepository>();

    // 1. Try biometric authentication
    final isBioAvailable = await biometricService.isBiometricAvailable();

    if (isBioAvailable && context.mounted) {
      final result = await _tryBiometricAuth(
        context,
        reason: reason,
        authRepository: authRepository,
        biometricService: biometricService,
      );
      if (result.isAuthenticated) return result;
    }

    // 2. Fallback to PIN dialog
    if (context.mounted) {
      return _showPinFallback(context, reason: reason);
    }

    return AuthResult.cancelled;
  }

  static Future<AuthResult> _tryBiometricAuth(
    BuildContext context, {
    required String reason,
    required AuthRepository authRepository,
    required BiometricService biometricService,
  }) async {
    _logger.i('🔐 TransactionAuth: Attempting biometric authentication...');

    final challengeResult = await authRepository.getBiometricChallenge();

    return await challengeResult.fold(
      (failure) {
        _logger.w('🔐 TransactionAuth: Challenge failed: ${failure.message}');
        return AuthResult.cancelled;
      },
      (challenge) async {
        final didAuthenticate = await biometricService.authenticate(
          reason: reason,
        );

        if (!didAuthenticate) {
          _logger.w('🔐 TransactionAuth: Local biometric declined.');
          return AuthResult.cancelled;
        }

        final verifyResult = await authRepository.verifyBiometric(
          challenge: challenge,
          signature: 'local-auth-success-$challenge',
        );

        return verifyResult.fold(
          (failure) {
            _logger.w(
              '🔐 TransactionAuth: Backend verification failed: '
              '${failure.message}',
            );
            return AuthResult.cancelled;
          },
          (biometricToken) {
            _logger.i('🔐 TransactionAuth: Biometric auth successful.');
            return AuthResult.biometric(biometricToken);
          },
        );
      },
    );
  }

  static Future<AuthResult> _showPinFallback(
    BuildContext context, {
    required String reason,
  }) async {
    _logger.i('🔐 TransactionAuth: Falling back to PIN dialog.');
    final authRepository = sl<AuthRepository>();

    final pin = await PinAuthDialog.show(
      context,
      reason: reason,
      authRepository: authRepository,
    );

    if (pin != null) {
      return AuthResult.pinVerified(pin);
    }
    return AuthResult.cancelled;
  }
}
