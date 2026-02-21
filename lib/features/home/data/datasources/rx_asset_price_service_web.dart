import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/features/home/data/datasources/asset_price_service.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';
import 'package:rxdart/rxdart.dart';

AssetPriceService getRxAssetPriceService(ApiClient client) =>
    RxAssetPriceServiceWeb(client);

class RxAssetPriceServiceWeb implements AssetPriceService {
  final ApiClient _client;

  RxAssetPriceServiceWeb(this._client);

  @override
  Stream<AssetPriceUpdate> getPriceStream(String ticker) {
    return Rx.retry(
      () => _getStream(ticker),
    ).asBroadcastStream(onCancel: (subscription) => subscription.cancel());
  }

  Stream<AssetPriceUpdate> _getStream(String ticker) {
    final controller = StreamController<AssetPriceUpdate>();
    final url =
        '${_client.dio.options.baseUrl}/market/instruments/$ticker/stream';

    // Using native Browser EventSource for Server-Sent Events (SSE)
    final eventSource = web.EventSource(url);

    eventSource.onmessage = ((web.Event event) {
      final messageEvent = event as web.MessageEvent;
      try {
        if (messageEvent.data != null) {
          final String dataString = (messageEvent.data as JSAny)
              .dartify()
              .toString();
          if (dataString.trim().isEmpty) return;

          final json = jsonDecode(dataString);
          final update = AssetPriceUpdate(
            ticker: json['ticker'] ?? ticker,
            price: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
            variationPct: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
          );
          controller.add(update);
        }
      } catch (e) {
        controller.addError(e);
      }
    }).toJS;

    eventSource.onerror = ((web.Event event) {
      if (!controller.isClosed) {
        controller.addError(Exception('EventSource error for $ticker'));
      }
    }).toJS;

    controller.onCancel = () {
      eventSource.close();
    };

    return controller.stream;
  }
}
