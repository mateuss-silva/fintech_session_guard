import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';

abstract class PortfolioRepository {
  Future<Either<Failure, PortfolioSummaryEntity>> getPortfolioSummary();
  Stream<AssetPriceUpdate> getAssetPriceStream(String ticker);
  Future<Either<Failure, void>> depositMoney(double amount);
  Future<Either<Failure, void>> withdrawMoney(double amount);

  Future<Either<Failure, List<String>>> getWatchlist();
  Future<Either<Failure, void>> addWatchlistTicker(String ticker);
  Future<Either<Failure, void>> removeWatchlistTicker(String ticker);
}
