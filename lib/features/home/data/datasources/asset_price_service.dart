import 'dart:async';
import 'dart:math';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';

abstract class AssetPriceService {
  Stream<AssetPriceUpdate> getPriceStream(String ticker);
}

class MockAssetPriceService implements AssetPriceService {
  final _random = Random();

  @override
  Stream<AssetPriceUpdate> getPriceStream(String ticker) {
    // Generate a new price every 1-3 seconds
    return Stream.periodic(const Duration(seconds: 2), (_) {
      // Simulate price movement
      final variation = (_random.nextDouble() * 2 - 1) * 0.5; // -0.5% to +0.5%
      final price =
          100.0 + (_random.nextDouble() * 100); // Base price simulation

      return AssetPriceUpdate(
        ticker: ticker,
        price: price, // In a real app, we'd base this on the last known price
        variationPct: variation,
      );
    }).asBroadcastStream();
  }
}
