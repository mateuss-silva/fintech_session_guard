import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../security/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final Logger _logger;
  bool _isRefreshing = false;
  Future<bool>? _refreshFuture;

  AuthInterceptor({
    required SecureStorageService secureStorage,
    required Dio dio,
    required Logger logger,
  }) : _secureStorage = secureStorage,
       _dio = dio,
       _logger = logger;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final deviceId = await _secureStorage.getDeviceId();
    if (deviceId != null) {
      options.headers['X-Device-Id'] = deviceId;
    }

    _logger.d('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthEndpoint =
        err.requestOptions.path.contains(ApiConstants.login) ||
        err.requestOptions.path.contains(ApiConstants.register) ||
        err.requestOptions.path.contains(ApiConstants.refresh);

    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final data = err.response?.data;
      final errorCode = (data is Map) ? data['error'] : null;

      // Critical errors that should trigger immediate logout
      if (errorCode == 'TOKEN_REUSE_DETECTED' ||
          errorCode == 'SESSION_EXPIRED' ||
          errorCode == 'SESSION_INVALID' ||
          errorCode == 'DEVICE_MISMATCH') {
        _logger.e('🔐 Security error detected: $errorCode. Clearing session.');
        await _secureStorage.clearAll();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: errorCode == 'TOKEN_REUSE_DETECTED'
                ? const TokenReuseException()
                : const SessionExpiredException(),
            type: DioExceptionType.unknown,
          ),
        );
        return;
      }

      // Try to refresh token or wait for an ongoing refresh
      final refreshed = await (_refreshFuture ??= _tryRefreshToken());

      // Cleanup future after completion if it matches
      if (_refreshFuture != null) {
        // We don't null it immediately to let other concurrent requests catch it
        // but we need to ensure the NEXT set of errors triggers a new one.
        // A simple way is to wait a tiny bit then null it, or use a sync mechanism.
        // For now, we'll keep it simple: if the future is done, the next error will reset it.
      }

      if (refreshed) {
        try {
          final token = await _secureStorage.getAccessToken();
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $token';

          final response = await _dio.fetch(opts);
          _refreshFuture = null; // Success! Next 401 can try again.
          handler.resolve(response);
          return;
        } catch (e) {
          _refreshFuture = null;
          handler.reject(err);
          return;
        }
      } else {
        _refreshFuture = null;
        _logger.w('⚠️ Token refresh failed. Redirecting to login.');
        await _secureStorage.clearAll();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const SessionExpiredException(),
            type: DioExceptionType.unknown,
          ),
        );
        return;
      }
    }

    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      final deviceId = await _secureStorage.getDeviceId();

      if (refreshToken == null) return false;

      _logger.i('♻️ Attempting to refresh token...');

      // Use a dedicated Dio instance for refresh to avoid interceptor loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken, 'deviceId': deviceId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        _logger.i('✅ Token refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('❌ Token refresh failed: $e');
      return false;
    } finally {
      _isRefreshing = false;
      // Note: we don't null _refreshFuture here to avoid race conditions
      // where requests wait for it. It's handled in onError.
    }
  }
}
