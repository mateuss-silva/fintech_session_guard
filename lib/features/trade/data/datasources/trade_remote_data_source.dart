import 'package:dio/dio.dart';
import 'package:fintech_session_guard/core/constants/api_constants.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/network/api_client.dart';

abstract class TradeRemoteDataSource {
  Future<void> buyAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  });

  Future<void> sellAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  });
}

class TradeRemoteDataSourceImpl implements TradeRemoteDataSource {
  final ApiClient _client;

  TradeRemoteDataSourceImpl(this._client);

  @override
  Future<void> buyAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.tradeBuy,
        data: {
          'ticker': ticker,
          'quantity': quantity,
          if (pin != null) 'pin': pin,
          if (biometricToken != null) 'biometricToken': biometricToken,
        },
      );

      if (response.statusCode != 200) {
        throw const ServerException(message: 'Failed to buy asset');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 401 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 404) {
        final message = e.response?.data['message'] ?? 'Trade failed';
        final error = e.response?.data['error'];

        if (error == 'AUTH_ERROR') {
          throw const UnauthorizedException();
        }
        throw ServerException(message: message);
      }
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> sellAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.tradeSell,
        data: {
          'ticker': ticker,
          'quantity': quantity,
          if (pin != null) 'pin': pin,
          if (biometricToken != null) 'biometricToken': biometricToken,
        },
      );

      if (response.statusCode != 200) {
        throw const ServerException(message: 'Failed to sell asset');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 401 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 404) {
        final message = e.response?.data['message'] ?? 'Trade failed';
        final error = e.response?.data['error'];

        if (error == 'AUTH_ERROR') {
          throw const UnauthorizedException();
        }
        throw ServerException(message: message);
      }
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
