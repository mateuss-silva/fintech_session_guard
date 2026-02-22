import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/domain/entities/transaction_entity.dart';
import 'package:fintech_session_guard/features/home/domain/entities/withdraw_preview_entity.dart';

abstract class PortfolioRepository {
  Future<Either<Failure, PortfolioSummaryEntity>> getPortfolioSummary();
  Stream<Either<Failure, PortfolioSummaryEntity>> getPortfolioStream();
  Stream<AssetPriceUpdate> getAssetPriceStream(String ticker);
  Future<Either<Failure, void>> depositMoney(double amount);
  Future<Either<Failure, void>> withdrawMoney(double amount);
  Future<Either<Failure, WithdrawPreviewEntity>> previewWithdraw(double amount);
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
    String? type,
  });

  Future<Either<Failure, List<String>>> getWatchlist();
  Future<Either<Failure, void>> addWatchlistTicker(String ticker);
  Future<Either<Failure, void>> removeWatchlistTicker(String ticker);
}
