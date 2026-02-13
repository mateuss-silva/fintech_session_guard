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
        err.requestOptions.path.contains(ApiConstants.register);

    if (err.response?.statusCode == 401 && !isAuthEndpoint && !_isRefreshing) {
      final errorCode = err.response?.data?['error'];

      if (errorCode == 'TOKEN_REUSE_DETECTED' ||
          errorCode == 'SESSION_EXPIRED') {
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

      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        try {
          final token = await _secureStorage.getAccessToken();
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $token';

          final response = await _dio.fetch(opts);
          handler.resolve(response);
          return;
        } catch (e) {
          handler.reject(err);
          return;
        }
      } else {
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
        _logger.i('♻️ Token refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
