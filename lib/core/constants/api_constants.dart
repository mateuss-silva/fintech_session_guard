import 'package:flutter/foundation.dart'
    show
        kIsWeb; // Actually kIsWeb is not needed anymore either if I remove it, but let's just remove the whole line.

/// API endpoint constants for the Guardian Invest backend.
///
/// All endpoints are relative to [baseUrl].
/// Security headers (Authorization, X-Device-Id, X-Biometric-Token)
/// are injected by Dio interceptors — see [ApiClient].
class ApiConstants {
  ApiConstants._();

  /// Base URL for the backend API.
  static String get baseUrl {
    return 'https://fintech-session-guard-api.onrender.com/api';
  }

  // ─── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String verifyPin = '/auth/verify-pin';
  static const String pinStatus = '/auth/pin-status';
  static const String setPin = '/auth/set-pin';
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

  // ─── Market ────────────────────────────────────────────────────
  static const String marketSearch = '/market/instruments';
  static String instrumentHistory(String id) => '/instruments/$id/history';

  // ─── Trade ────────────────────────────────────────────────────
  static const String tradeBuy = '/trade/buy';
  static const String tradeSell = '/trade/sell';

  // ─── Transactions ──────────────────────────────────────────────
  static const String transactionsHistory = '/transactions/history';
  static const String previewWithdraw = '/transactions/withdraw/preview';
}
