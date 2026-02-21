import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

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
    final url = '$baseUrl/portfolio/stream';

    final headers =
        {
              'Content-Type': 'application/json',
              'Accept': 'text/event-stream',
            }.jsify()
            as web.HeadersInit;

    final body = jsonEncode({'token': token}).toJS;

    final requestOptions = web.RequestInit(
      method: 'POST',
      headers: headers,
      body: body,
    );

    try {
      final response = await web.window.fetch(url.toJS, requestOptions).toDart;
      final reader = response.body!.getReader();
      bool active = true;

      controller.onCancel = () {
        active = false;
        reader.callMethod('cancel'.toJS);
      };

      String buffer = '';

      Future<void> read() async {
        try {
          while (active && !controller.isClosed) {
            final promise = reader.callMethod('read'.toJS) as JSPromise<JSAny?>;
            final resultAny = await promise.toDart;
            final jsObj = resultAny as JSObject;

            final doneNode = jsObj['done'];
            final done = doneNode != null
                ? (doneNode as JSBoolean).toDart
                : false;

            if (done) {
              controller.close();
              active = false;
              break;
            }

            final valueNode = jsObj['value'];
            if (valueNode != null) {
              final chunkData = (valueNode as JSUint8Array).toDart;
              final chunkStr = utf8.decode(chunkData);
              buffer += chunkStr;

              while (buffer.contains('\n\n')) {
                final endIndex = buffer.indexOf('\n\n');
                final message = buffer.substring(0, endIndex);
                buffer = buffer.substring(endIndex + 2);

                if (message.startsWith('data:')) {
                  final data = message.substring(5).trim();
                  if (data.isNotEmpty) {
                    try {
                      final parsed = jsonDecode(data);
                      final model = PortfolioSummaryModel.fromJson(parsed);
                      if (!controller.isClosed) controller.add(model);
                    } catch (_) {}
                  }
                }
              }
            }
          }
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
      }

      read();
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(Exception('Fetch error for Portfolio Stream'));
      }
    }

    yield* controller.stream;
  }
}
