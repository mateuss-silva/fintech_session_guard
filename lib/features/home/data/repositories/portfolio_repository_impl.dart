import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/data/datasources/portfolio_remote_data_source.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

import 'package:fintech_session_guard/features/home/data/datasources/asset_price_service.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';

import 'package:fintech_session_guard/features/home/data/datasources/portfolio_stream_service.dart';
import 'package:fintech_session_guard/features/home/data/datasources/watchlist_local_data_source.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;
  final AssetPriceService priceService;
  final WatchlistLocalDataSource localDataSource;
  final PortfolioStreamService portfolioStreamService;

  PortfolioRepositoryImpl({
    required this.remoteDataSource,
    required this.priceService,
    required this.localDataSource,
    required this.portfolioStreamService,
  });

  @override
  Stream<AssetPriceUpdate> getAssetPriceStream(String ticker) {
    return priceService.getPriceStream(ticker);
  }

  @override
  Stream<Either<Failure, PortfolioSummaryEntity>> getPortfolioStream() async* {
    try {
      await for (final model in portfolioStreamService.getPortfolioStream()) {
        yield Right(model);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(message: e.message, code: e.code));
    } on UnauthorizedException catch (e) {
      yield Left(AuthFailure(message: e.message, code: e.code));
    } on SessionExpiredException {
      yield const Left(SessionExpiredFailure());
    } catch (e) {
      yield Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PortfolioSummaryEntity>> getPortfolioSummary() async {
    try {
      final remotePortfolio = await remoteDataSource.getPortfolioSummary();
      return Right(remotePortfolio);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on SessionExpiredException {
      return const Left(SessionExpiredFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> depositMoney(double amount) async {
    try {
      await remoteDataSource.depositMoney(amount);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> withdrawMoney(double amount) async {
    try {
      await remoteDataSource.withdrawMoney(amount);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getWatchlist() async {
    try {
      final list = await localDataSource.getWatchlist();
      return Right(list);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addWatchlistTicker(String ticker) async {
    try {
      await localDataSource.addTicker(ticker);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeWatchlistTicker(String ticker) async {
    try {
      await localDataSource.removeTicker(ticker);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}
