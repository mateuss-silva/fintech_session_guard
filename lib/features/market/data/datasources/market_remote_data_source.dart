import 'package:dio/dio.dart';
import 'package:fintech_session_guard/core/constants/api_constants.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/features/market/data/models/instrument_history_model.dart';
import 'package:fintech_session_guard/features/market/data/models/instrument_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<InstrumentModel>> searchInstruments({
    String? query,
    String? type,
  });

  Future<InstrumentHistoryModel> getInstrumentHistory({
    required String instrumentId,
    required String range,
  });
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final ApiClient _client;

  MarketRemoteDataSourceImpl(this._client);

  @override
  Future<List<InstrumentModel>> searchInstruments({
    String? query,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _client.dio.get(
        ApiConstants.marketSearch,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> instrumentsData =
            response.data['instruments'] ?? [];
        return instrumentsData
            .map((e) => InstrumentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException(message: 'Failed to search instruments');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException();
      }
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<InstrumentHistoryModel> getInstrumentHistory({
    required String instrumentId,
    required String range,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.instrumentHistory(instrumentId),
        queryParameters: {'range': range},
      );
      return InstrumentHistoryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const UnauthorizedException();
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
