import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/trade/data/datasources/trade_remote_data_source.dart';
import 'package:fintech_session_guard/features/trade/domain/repositories/trade_repository.dart';

class TradeRepositoryImpl implements TradeRepository {
  final TradeRemoteDataSource remoteDataSource;

  TradeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> buyAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  }) async {
    try {
      await remoteDataSource.buyAsset(
        ticker: ticker,
        quantity: quantity,
        pin: pin,
        biometricToken: biometricToken,
      );
      return const Right(null);
    } on UnauthorizedException {
      return Left(ServerFailure(message: 'Invalid PIN or Biometrics'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sellAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  }) async {
    try {
      await remoteDataSource.sellAsset(
        ticker: ticker,
        quantity: quantity,
        pin: pin,
        biometricToken: biometricToken,
      );
      return const Right(null);
    } on UnauthorizedException {
      return Left(ServerFailure(message: 'Invalid PIN or Biometrics'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }
}
