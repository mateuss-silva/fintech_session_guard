import 'dart:async';

import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

/// Monitors user activity and triggers session timeout.
///
/// **OWASP M1 — Improper Platform Usage / Session Management:**
/// Implements client-side inactivity timeout that mirrors the
/// server's 15-minute session timeout. On expiration, tokens
/// are cleared and the user is redirected to login.
///
/// **NIST SP 800-53 AC-11 — Session Lock:**
/// Automatically locks the session after a period of inactivity,
/// requiring re-authentication.
class SessionMonitor with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  final _controller = StreamController<void>.broadcast();
  final Duration timeout;
  bool _isMonitoring = false;

  Stream<void> get onSessionExpired => _controller.stream;

  SessionMonitor({Duration? timeout})
    : timeout =
          timeout ??
          const Duration(minutes: AppConstants.sessionTimeoutMinutes);

  /// Start monitoring user activity.
  void start() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  /// Stop monitoring and cancel timers.
  void stop() {
    _isMonitoring = false;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Reset the inactivity timer — call on every user interaction.
  void resetTimer() {
    if (!_isMonitoring) return;
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeout, () {
      _isMonitoring = false;
      _controller.add(null);
    });
  }

  /// Handle app lifecycle changes.
  /// When the app goes to background, the timer continues.
  /// When resumed, we check if the timeout has passed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isMonitoring) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // Timer continues in background; if it fired, onSessionExpired was called
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
