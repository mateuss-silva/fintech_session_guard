import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/core/security/secure_storage_service.dart';
import 'package:fintech_session_guard/features/home/data/datasources/portfolio_stream_service.dart';

PortfolioStreamService getRxPortfolioService(
  ApiClient client,
  SecureStorageService secureStorage,
) => throw UnsupportedError(
  'Cannot create an PortfolioStreamService without dart:html or dart:io',
);
