import 'package:equatable/equatable.dart';

/// Base failure class following Clean Architecture error handling.
///
/// All domain-layer errors are represented as [Failure] subclasses,
/// never as raw exceptions — ensuring a clear boundary between
/// data and domain layers.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Generic server error (5xx or unexpected response).
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Authentication failure (invalid credentials, expired token).
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Network connectivity failure.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Session expired due to inactivity or server-side invalidation.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({
    super.message = 'Your session has expired. Please login again.',
    super.code = 'SESSION_EXPIRED',
  });
}

/// Token reuse detected — potential session hijacking.
/// All sessions are invalidated server-side.
class TokenReuseFailure extends Failure {
  const TokenReuseFailure({
    super.message =
        'Security alert: suspicious activity detected. All sessions have been invalidated.',
    super.code = 'TOKEN_REUSE_DETECTED',
  });
}

/// Biometric verification failed or not available.
class BiometricFailure extends Failure {
  const BiometricFailure({required super.message, super.code});
}

/// Device integrity compromised (root/jailbreak detected).
class DeviceCompromisedFailure extends Failure {
  const DeviceCompromisedFailure({
    super.message =
        'This device has been flagged as compromised. Sensitive operations are blocked.',
    super.code = 'DEVICE_COMPROMISED',
  });
}

/// Validation error (client-side input validation).
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}
