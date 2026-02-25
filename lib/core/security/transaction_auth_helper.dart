import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/core/security/biometric_service.dart';
import 'package:fintech_session_guard/features/auth/domain/repositories/auth_repository.dart';
import 'package:fintech_session_guard/core/presentation/widgets/pin_auth_dialog.dart';

/// Reusable helper that authenticates a user via biometrics with PIN fallback.
///
/// Flow:
/// 1. Check if biometrics are available
/// 2. If yes → challenge → local auth → backend verify
/// 3. If biometrics fail or unavailable → show PIN dialog
///
/// Returns `true` if the user was successfully authenticated.
class TransactionAuthHelper {
  TransactionAuthHelper._();

  static final _logger = Logger();

  /// Authenticates the user for a sensitive transaction.
  ///
  /// [reason] is displayed on the biometric prompt and PIN dialog.
  static Future<bool> authenticate(
    BuildContext context, {
    required String reason,
  }) async {
    final biometricService = sl<BiometricService>();
    final authRepository = sl<AuthRepository>();

    // 1. Try biometric authentication
    final isBioAvailable = await biometricService.isBiometricAvailable();

    if (isBioAvailable && context.mounted) {
      final biometricSuccess = await _tryBiometricAuth(
        context,
        reason: reason,
        authRepository: authRepository,
        biometricService: biometricService,
      );
      if (biometricSuccess) return true;
    }

    // 2. Fallback to PIN dialog
    if (context.mounted) {
      return _showPinFallback(context, reason: reason);
    }

    return false;
  }

  static Future<bool> _tryBiometricAuth(
    BuildContext context, {
    required String reason,
    required AuthRepository authRepository,
    required BiometricService biometricService,
  }) async {
    _logger.i('🔐 TransactionAuth: Attempting biometric authentication...');

    // Get challenge from backend
    final challengeResult = await authRepository.getBiometricChallenge();

    return await challengeResult.fold(
      (failure) {
        _logger.w('🔐 TransactionAuth: Challenge failed: ${failure.message}');
        return false;
      },
      (challenge) async {
        // Local biometric prompt
        final didAuthenticate = await biometricService.authenticate(
          reason: reason,
        );

        if (!didAuthenticate) {
          _logger.w('🔐 TransactionAuth: Local biometric declined.');
          return false;
        }

        // Verify on backend
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
            return false;
          },
          (_) {
            _logger.i('🔐 TransactionAuth: Biometric auth successful.');
            return true;
          },
        );
      },
    );
  }

  static Future<bool> _showPinFallback(
    BuildContext context, {
    required String reason,
  }) async {
    _logger.i('🔐 TransactionAuth: Falling back to PIN dialog.');
    final authRepository = sl<AuthRepository>();

    return PinAuthDialog.show(
      context,
      reason: reason,
      authRepository: authRepository,
    );
  }
}
