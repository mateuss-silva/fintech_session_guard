/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Guardian Invest';
  static const String appVersion = '1.0.0';

  /// Session timeout in minutes — must match backend configuration.
  static const int sessionTimeoutMinutes = 15;

  /// Buffer before server timeout to trigger client-side refresh (in minutes).
  static const int sessionWarningMinutes = 12;

  /// Maximum login attempts before rate-limit UX lock.
  static const int maxLoginAttempts = 5;

  /// Sensitive operations that require biometric verification.
  static const List<String> biometricOperations = [
    'transfer',
    'settings',
    'password_change',
  ];
}
