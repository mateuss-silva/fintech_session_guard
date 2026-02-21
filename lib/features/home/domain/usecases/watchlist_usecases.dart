import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

class GetWatchlistUseCase {
  final PortfolioRepository repository;
  GetWatchlistUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getWatchlist();
  }
}

class AddTickerUseCase {
  final PortfolioRepository repository;
  AddTickerUseCase(this.repository);

  Future<Either<Failure, void>> call(String ticker) {
    return repository.addWatchlistTicker(ticker);
  }
}

class RemoveTickerUseCase {
  final PortfolioRepository repository;
  RemoveTickerUseCase(this.repository);

  Future<Either<Failure, void>> call(String ticker) {
    return repository.removeWatchlistTicker(ticker);
  }
}
