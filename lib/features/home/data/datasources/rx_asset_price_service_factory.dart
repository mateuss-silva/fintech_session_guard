import 'package:fintech_session_guard/features/home/data/datasources/asset_price_service.dart';

import 'package:fintech_session_guard/core/network/api_client.dart';
import 'rx_asset_price_service_stub.dart'
    if (dart.library.html) 'rx_asset_price_service_web.dart'
    if (dart.library.io) 'rx_asset_price_service_mobile.dart';

abstract class RxAssetPriceServiceFactory {
  static AssetPriceService create(ApiClient client) {
    return getRxAssetPriceService(client);
  }
}
