import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/entities/withdraw_preview_entity.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

class PreviewWithdrawUseCase {
  final PortfolioRepository repository;

  PreviewWithdrawUseCase(this.repository);

  Future<Either<Failure, WithdrawPreviewEntity>> call(double amount) async {
    return await repository.previewWithdraw(amount);
  }
}
