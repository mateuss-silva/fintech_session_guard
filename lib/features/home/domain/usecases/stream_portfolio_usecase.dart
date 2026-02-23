import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

class StreamPortfolioUseCase {
  final PortfolioRepository _repository;

  StreamPortfolioUseCase(this._repository);

  Stream<Either<Failure, PortfolioSummaryEntity>> call([
    List<String>? watchlist,
  ]) {
    return _repository.getPortfolioStream(watchlist: watchlist);
  }
}
