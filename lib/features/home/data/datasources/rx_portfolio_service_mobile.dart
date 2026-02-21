import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/core/security/secure_storage_service.dart';
import 'package:fintech_session_guard/features/home/data/datasources/portfolio_stream_service.dart';
import 'package:fintech_session_guard/features/home/data/models/portfolio_summary_model.dart';
import 'package:rxdart/rxdart.dart';

PortfolioStreamService getRxPortfolioService(
  ApiClient client,
  SecureStorageService secureStorage,
) => RxPortfolioServiceMobile(client);

class RxPortfolioServiceMobile implements PortfolioStreamService {
  final ApiClient _client;

  RxPortfolioServiceMobile(this._client);

  @override
  Stream<PortfolioSummaryModel> getPortfolioStream() {
    return Rx.retry(
      () => _getStream(),
    ).asBroadcastStream(onCancel: (subscription) => subscription.cancel());
  }

  Stream<PortfolioSummaryModel> _getStream() async* {
    try {
      final response = await _client.dio.get<ResponseBody>(
        '/portfolio/stream',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(days: 1),
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
            var jsonLine = line;
            if (line.startsWith('data:')) {
              jsonLine = line.substring(5).trim();
            }
            try {
              final json = jsonDecode(jsonLine);
              return PortfolioSummaryModel.fromJson(
                json as Map<String, dynamic>,
              );
            } catch (_) {
              return null;
            }
          })
          .where((event) => event != null)
          .cast<PortfolioSummaryModel>();
    } catch (e) {
      debugPrint('[DEBUG] Portfolio Stream error: $e');
      rethrow;
    }
  }
}
