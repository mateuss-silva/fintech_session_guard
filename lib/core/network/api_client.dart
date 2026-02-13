import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../security/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Configured Dio HTTP client with security interceptors.
class ApiClient {
  late final Dio dio;
  final SecureStorageService _secureStorage;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ApiClient({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Auth Interceptor ──────────────────────────────────────────
    dio.interceptors.add(
      AuthInterceptor(secureStorage: _secureStorage, dio: dio, logger: _logger),
    );

    // ── Certificate Pinning (Production) ──────────────────────────
    // In production, configure certificate pinning as needed.
  }

  /// REST methods...
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      dio.put(path, data: data);

  Future<Response> delete(String path, {dynamic data}) =>
      dio.delete(path, data: data);
}
