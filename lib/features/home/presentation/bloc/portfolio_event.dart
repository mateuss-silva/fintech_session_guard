import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object> get props => [];
}

class PortfolioSummaryRequested extends PortfolioEvent {
  const PortfolioSummaryRequested();
}

class PortfolioRefreshed extends PortfolioEvent {
  const PortfolioRefreshed();
}

class WalletDepositRequested extends PortfolioEvent {
  final double amount;
  const WalletDepositRequested(this.amount);

  @override
  List<Object> get props => [amount];
}

class WalletWithdrawRequested extends PortfolioEvent {
  final double amount;
  const WalletWithdrawRequested(this.amount);

  @override
  List<Object> get props => [amount];
}

class WalletWithdrawConfirmed extends PortfolioEvent {
  final double amount;
  const WalletWithdrawConfirmed(this.amount);

  @override
  List<Object> get props => [amount];
}

class WatchlistRequested extends PortfolioEvent {
  const WatchlistRequested();
}

class WatchlistAdded extends PortfolioEvent {
  final String ticker;
  const WatchlistAdded(this.ticker);

  @override
  List<Object> get props => [ticker];
}

class WatchlistRemoved extends PortfolioEvent {
  final String ticker;
  const WatchlistRemoved(this.ticker);

  @override
  List<Object> get props => [ticker];
}

class PortfolioStreamUpdated extends PortfolioEvent {
  final Either<Failure, PortfolioSummaryEntity> result;
  const PortfolioStreamUpdated(this.result);

  @override
  List<Object> get props => [result];
}
