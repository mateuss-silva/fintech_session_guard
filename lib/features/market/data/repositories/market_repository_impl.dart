import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/market/data/datasources/market_remote_data_source.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';
import 'package:fintech_session_guard/features/market/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remoteDataSource;

  MarketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<InstrumentEntity>>> searchInstruments({
    String? query,
    String? type,
  }) async {
    try {
      final remoteInstruments = await remoteDataSource.searchInstruments(
        query: query,
        type: type,
      );
      return Right(remoteInstruments);
    } on UnauthorizedException {
      return const Left(
        AuthFailure(message: 'Session expired or unauthorized'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
