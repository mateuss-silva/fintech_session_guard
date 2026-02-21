import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/features/home/data/datasources/portfolio_stream_service.dart';

import 'rx_portfolio_service_stub.dart'
    if (dart.library.html) 'rx_portfolio_service_web.dart'
    if (dart.library.io) 'rx_portfolio_service_mobile.dart';

import 'package:fintech_session_guard/core/security/secure_storage_service.dart';

abstract class RxPortfolioServiceFactory {
  static PortfolioStreamService create(
    ApiClient client,
    SecureStorageService secureStorage,
  ) {
    return getRxPortfolioService(client, secureStorage);
  }
}
