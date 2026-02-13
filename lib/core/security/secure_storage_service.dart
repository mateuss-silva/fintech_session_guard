import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token and credential storage using platform Keychain/Keystore.
///
/// **OWASP M9 — Insecure Data Storage:**
/// Tokens are NEVER stored in SharedPreferences. We use
/// `flutter_secure_storage` which leverages iOS Keychain and
/// Android EncryptedSharedPreferences (backed by Android Keystore).
///
/// **NIST SP 800-63B:**
/// Authentication secrets are stored with hardware-backed
/// cryptographic protection where available.
class SecureStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _deviceIdKey = 'device_id';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _privacyVisibleKey = 'privacy_visible';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
            webOptions: WebOptions(
              dbName: 'SessionGuardDB',
              publicKey: 'SessionGuardKey',
            ),
          );

  // ─── Access Token ──────────────────────────────────────────────
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> deleteAccessToken() => _storage.delete(key: _accessTokenKey);

  // ─── Refresh Token ─────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> deleteRefreshToken() => _storage.delete(key: _refreshTokenKey);

  // ─── User Info ─────────────────────────────────────────────────
  Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _userEmailKey, value: email);

  Future<String?> getUserEmail() => _storage.read(key: _userEmailKey);

  Future<void> saveUserName(String name) =>
      _storage.write(key: _userNameKey, value: name);

  Future<String?> getUserName() => _storage.read(key: _userNameKey);

  // ─── Device ID ─────────────────────────────────────────────────
  Future<void> saveDeviceId(String id) =>
      _storage.write(key: _deviceIdKey, value: id);

  Future<String?> getDeviceId() => _storage.read(key: _deviceIdKey);

  // ─── Privacy Setting ───────────────────────────────────────────
  Future<void> savePrivacyVisible(bool visible) =>
      _storage.write(key: _privacyVisibleKey, value: visible.toString());

  Future<bool?> getPrivacyVisible() async {
    final val = await _storage.read(key: _privacyVisibleKey);
    if (val == null) return null;
    return val == 'true';
  }

  // ─── Bulk Operations ──────────────────────────────────────────
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
  }) async {
    await saveUserId(userId);
    await saveUserEmail(email);
    await saveUserName(name);
  }

  /// Clear ALL stored data on logout.
  /// Removes tokens, user info, and device associations.
  Future<void> clearAll() => _storage.deleteAll();

  /// Check if the user has stored authentication tokens.
  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return access != null && refresh != null;
  }
}
