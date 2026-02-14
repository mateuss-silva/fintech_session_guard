import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/data/datasources/portfolio_remote_data_source.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

import 'package:fintech_session_guard/features/home/data/datasources/asset_price_service.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;
  final AssetPriceService priceService;

  PortfolioRepositoryImpl({
    required this.remoteDataSource,
    required this.priceService,
  });

  @override
  Stream<AssetPriceUpdate> getAssetPriceStream(String ticker) {
    return priceService.getPriceStream(ticker);
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
}
