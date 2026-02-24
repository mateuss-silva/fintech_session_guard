import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

/// Service responsible for handling local biometric authentication.
///
/// **NIST SP 800-63B — Authenticator Types:**
/// This implements Multi-Factor Authentication (MFA) via a multi-factor physical
/// authenticator (the device itself) combined with biometrics.
class BiometricService {
  final LocalAuthentication _auth;
  final Logger _logger = Logger();

  BiometricService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  /// Checks if the device has biometric hardware and if the user has enrolled
  /// at least one biometric (fingerprint, face, etc.).
  Future<bool> isBiometricAvailable() async {
    try {
      print('DEBUG: checking bio availability...');
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final List<BiometricType> available = await _auth
          .getAvailableBiometrics();
      print('DEBUG: canCheckBiometrics: $canCheckBiometrics');
      print('DEBUG: isDeviceSupported: $isDeviceSupported');
      print('DEBUG: availableBiometrics: $available');

      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      _logger.e('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get the list of available biometric types (fingerprint, face, iris).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      _logger.e('Error getting available biometrics: $e');
      return <BiometricType>[];
    }
  }

  /// Authenticates the user using local biometrics.
  ///
  /// Returns `true` if authentication was successful, `false` otherwise.
  Future<bool> authenticate({
    required String reason,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      print('DEBUG: Calling _auth.authenticate...');
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );
      print('DEBUG: Authentication result: $didAuthenticate');
      return didAuthenticate;
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return false;
    }
  }
}
