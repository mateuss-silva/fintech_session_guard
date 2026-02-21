import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/core/security/secure_storage_service.dart';
import 'package:fintech_session_guard/features/home/data/datasources/portfolio_stream_service.dart';
import 'package:fintech_session_guard/features/home/data/models/portfolio_summary_model.dart';
import 'package:rxdart/rxdart.dart';

PortfolioStreamService getRxPortfolioService(
  ApiClient client,
  SecureStorageService secureStorage,
) => RxPortfolioServiceWeb(client, secureStorage);

class RxPortfolioServiceWeb implements PortfolioStreamService {
  final ApiClient _client;
  final SecureStorageService _secureStorage;

  RxPortfolioServiceWeb(this._client, this._secureStorage);

  @override
  Stream<PortfolioSummaryModel> getPortfolioStream() {
    return Rx.retry(
      () => _getStream(),
    ).asBroadcastStream(onCancel: (subscription) => subscription.cancel());
  }

  Stream<PortfolioSummaryModel> _getStream() async* {
    final controller = StreamController<PortfolioSummaryModel>();

    final token = await _secureStorage.getAccessToken();
    final baseUrl = _client.dio.options.baseUrl;
    final url = '$baseUrl/portfolio/stream?token=$token';

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
          final update = PortfolioSummaryModel.fromJson(
            json as Map<String, dynamic>,
          );
          controller.add(update);
        }
      } catch (e) {
        controller.addError(e);
      }
    }).toJS;

    eventSource.onerror = ((web.Event event) {
      if (!controller.isClosed) {
        controller.addError(
          Exception('EventSource error for Portfolio Stream'),
        );
      }
    }).toJS;

    controller.onCancel = () {
      eventSource.close();
    };

    yield* controller.stream;
  }
}
