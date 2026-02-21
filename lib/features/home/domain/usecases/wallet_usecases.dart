import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

export 'package:fintech_session_guard/features/home/domain/usecases/preview_withdraw_usecase.dart';

class DepositUseCase {
  final PortfolioRepository repository;

  DepositUseCase(this.repository);

  Future<Either<Failure, void>> call(double amount) {
    return repository.depositMoney(amount);
  }
}

class WithdrawUseCase {
  final PortfolioRepository repository;

  WithdrawUseCase(this.repository);

  Future<Either<Failure, void>> call(double amount) {
    return repository.withdrawMoney(amount);
  }
}
