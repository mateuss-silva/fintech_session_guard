import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/session_model.dart';

/// Remote data source for authentication API calls.
///
/// **NIST SP 800-63B — Authentication:**
/// All credentials are transmitted over HTTPS (enforced in production).
/// Passwords are never stored client-side — only tokens.
/// **OWASP M4 — Insecure Authentication:**
/// Validates input client-side AND server-side.
/// Tokens are stored in secure storage, never in logs.
class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AuthRemoteDataSource(this._apiClient);

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          ...?deviceId != null ? {'deviceId': deviceId} : null,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /api/auth/register
  Future<String> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {'email': email, 'password': password, 'name': name},
      );
      return response.data['userId'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /api/auth/logout
  Future<void> logout(String? refreshToken) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.logout,
        data: {
          ...?refreshToken != null ? {'refreshToken': refreshToken} : null,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /api/auth/sessions
  Future<List<SessionModel>> getSessions() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.sessions);
      final sessions = (response.data['sessions'] as List)
          .map((s) => SessionModel.fromJson(s as Map<String, dynamic>))
          .toList();
      return sessions;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE /api/auth/sessions/:sessionId
  Future<void> revokeSession(String sessionId) async {
    try {
      await _apiClient.dio.delete(ApiConstants.revokeSession(sessionId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /api/auth/verify-pin
  Future<String> verifyPin(String pin) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.verifyPin,
        data: {'pin': pin},
      );
      return response.data['challengeToken'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /api/auth/pin-status
  Future<bool> getPinStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.pinStatus);
      return response.data['hasPinConfigured'] as bool;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /api/auth/set-pin
  Future<void> setPin(String pin) async {
    try {
      await _apiClient.dio.post(ApiConstants.setPin, data: {'pin': pin});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /api/auth/bio/challenge
  Future<String> getBiometricChallenge() async {
    try {
      _logger.i(
        '🌐 Biometric Flow: Step 1 - Requesting challenge from server...',
      );
      final response = await _apiClient.dio.get(ApiConstants.bioChallenge);
      final challenge = response.data['challenge'] as String;
      _logger.d(
        '📥 Biometric Flow: Received challenge from server: $challenge',
      );
      return challenge;
    } on DioException catch (e) {
      _logger.e('❌ Biometric Flow: Failed to get challenge from server.');
      throw _handleDioError(e);
    }
  }

  /// POST /api/auth/bio/verify
  Future<String> verifyBiometric({
    required String challenge,
    required String signature,
  }) async {
    try {
      _logger.i(
        '🌐 Biometric Flow: Step 2 - Sending verification signature to server...',
      );
      final response = await _apiClient.dio.post(
        ApiConstants.bioVerify,
        data: {'challenge': challenge, 'signature': signature},
      );
      final token = response.data['biometricToken'] as String;
      _logger.i(
        '✅ Biometric Flow: Server verified signature and returned biometric token.',
      );
      return token;
    } on DioException catch (e) {
      _logger.e(
        '❌ Biometric Flow: Server failed to verify biometric signature.',
      );
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }

    final data = e.response?.data;
    final message = data is Map
        ? (data['message'] as String?) ?? 'Unknown error'
        : 'Unknown error';
    final code = data is Map ? data['error'] as String? : null;

    if (e.response?.statusCode == 401) {
      if (code == 'SESSION_EXPIRED') return const SessionExpiredException();
      if (code == 'TOKEN_REUSE_DETECTED') return const TokenReuseException();
      return UnauthorizedException(message: message, code: code);
    }

    return ServerException(
      message: message,
      code: code,
      statusCode: e.response?.statusCode,
    );
  }
}
