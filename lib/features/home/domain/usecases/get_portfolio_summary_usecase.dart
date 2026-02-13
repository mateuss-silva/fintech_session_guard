import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

class GetPortfolioSummaryUseCase {
  final PortfolioRepository repository;

  GetPortfolioSummaryUseCase(this.repository);

  Future<Either<Failure, PortfolioSummaryEntity>> call() async {
    return await repository.getPortfolioSummary();
  }
}
