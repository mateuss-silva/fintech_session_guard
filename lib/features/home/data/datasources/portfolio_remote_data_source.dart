import 'package:dio/dio.dart';
import 'package:fintech_session_guard/core/constants/api_constants.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/features/home/data/models/portfolio_summary_model.dart';
import 'package:fintech_session_guard/features/home/data/models/transaction_model.dart';
import 'package:fintech_session_guard/features/home/data/models/withdraw_preview_model.dart';

abstract class PortfolioRemoteDataSource {
  Future<PortfolioSummaryModel> getPortfolioSummary();
  Future<void> depositMoney(double amount);
  Future<void> withdrawMoney(double amount);
  Future<WithdrawPreviewModel> previewWithdraw(double amount);
  Future<List<TransactionModel>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
    String? type,
  });
}

class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final ApiClient _client;

  PortfolioRemoteDataSourceImpl(this._client);

  @override
  Future<PortfolioSummaryModel> getPortfolioSummary() async {
    try {
      final response = await _client.dio.get(ApiConstants.portfolio);

      if (response.statusCode == 200) {
        return PortfolioSummaryModel.fromJson(response.data);
      } else {
        throw const ServerException(message: 'Failed to fetch portfolio');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final error = e.response?.data['error'];
        if (error == 'SESSION_EXPIRED') {
          throw const SessionExpiredException();
        }
        throw const UnauthorizedException();
      }
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> depositMoney(double amount) async {
    try {
      final response = await _client.dio.post(
        '${ApiConstants.baseUrl}/transactions/deposit',
        data: {'amount': amount},
      );
      if (response.statusCode != 200) {
        throw const ServerException(message: 'Failed to deposit money');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Invalid amount',
        );
      }
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> withdrawMoney(double amount) async {
    try {
      final response = await _client.dio.post(
        '${ApiConstants.baseUrl}/transactions/withdraw',
        data: {'amount': amount},
      );
      if (response.statusCode != 200) {
        throw const ServerException(message: 'Failed to withdraw money');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Insufficient funds',
        );
      }
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WithdrawPreviewModel> previewWithdraw(double amount) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.previewWithdraw,
        data: {'amount': amount},
      );
      if (response.statusCode == 200) {
        return WithdrawPreviewModel.fromJson(response.data);
      } else {
        throw const ServerException(message: 'Failed to preview withdrawal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Insufficient funds',
        );
      }
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'limit': limit,
        'offset': offset,
      };
      if (type != null) {
        queryParameters['type'] = type;
      }

      final response = await _client.dio.get(
        ApiConstants.transactionsHistory,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['transactions'] as List;
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw const ServerException(
          message: 'Failed to fetch transaction history',
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
