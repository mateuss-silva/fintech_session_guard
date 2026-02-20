import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/features/home/data/datasources/asset_price_service.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';
import 'package:rxdart/rxdart.dart';

AssetPriceService getRxAssetPriceService(ApiClient client) =>
    RxAssetPriceServiceMobile(client);

class RxAssetPriceServiceMobile implements AssetPriceService {
  final ApiClient _client;

  RxAssetPriceServiceMobile(this._client);

  @override
  Stream<AssetPriceUpdate> getPriceStream(String ticker) {
    // Retry logic with Rx
    return Rx.retry(
      () => _getStream(ticker),
    ).asBroadcastStream(onCancel: (subscription) => subscription.cancel());
  }

  Stream<AssetPriceUpdate> _getStream(String ticker) async* {
    try {
      final response = await _client.dio.get<ResponseBody>(
        '/market/instruments/$ticker/stream',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(days: 1), // Practically infinite
          headers: {'Connection': 'keep-alive'},
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) throw Exception('Stream not available');

      yield* stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) {
            if (line.trim().isEmpty) return null;
            // Handle SSE "data: " prefix if present
            var jsonLine = line;
            if (line.startsWith('data:')) {
              jsonLine = line.substring(5).trim();
            }
            try {
              final json = jsonDecode(jsonLine);
              return AssetPriceUpdate(
                ticker: json['ticker'] ?? ticker,
                price: (json['currentPrice'] as num).toDouble(),
                variationPct: (json['changePercent'] as num).toDouble(),
              );
            } catch (_) {
              return null;
            }
          })
          .where((event) => event != null)
          .cast<AssetPriceUpdate>();
    } catch (e) {
      debugPrint('[DEBUG] Stream error for $ticker: $e');
      // Re-throw to trigger retry
      rethrow;
    }
  }
}
