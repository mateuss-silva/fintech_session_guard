import 'package:flutter/foundation.dart';

/// API endpoint constants for the Fintech Session Guard backend.
///
/// All endpoints are relative to [baseUrl].
/// Security headers (Authorization, X-Device-Id, X-Biometric-Token)
/// are injected by Dio interceptors — see [ApiClient].
class ApiConstants {
  ApiConstants._();

  /// Base URL for the backend API.
  /// Uses 10.0.2.2 for Android Emulator, localhost for others.
  static String get baseUrl {
    if (kIsWeb) return 'https://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://10.0.2.2:3000/api';
    }
    // Windows Desktop often fails to resolve localhost correctly in Flutter, use IPv4 loopback
    return 'https://127.0.0.1:3000/api';
  }

  // ─── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String verifyPin = '/auth/verify-pin';
  static const String sessions = '/auth/sessions';
  static String revokeSession(String id) => '/auth/sessions/$id';

  // ─── Device ────────────────────────────────────────────────────
  static const String deviceRegister = '/device/register';
  static const String deviceVerify = '/device/verify';
  static const String deviceList = '/device/list';
  static const String bioChallenge = '/device/bio/challenge';
  static const String bioVerify = '/device/bio/verify';

  // ─── Portfolio ─────────────────────────────────────────────────
  static const String portfolio = '/portfolio';
}
