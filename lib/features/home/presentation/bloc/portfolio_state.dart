import 'package:equatable/equatable.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/domain/entities/withdraw_preview_entity.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object> get props => [];
}

class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

class PortfolioLoaded extends PortfolioState {
  final PortfolioSummaryEntity portfolio;
  final List<String> watchlist;

  const PortfolioLoaded(this.portfolio, {this.watchlist = const []});

  @override
  List<Object> get props => [portfolio, watchlist];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object> get props => [message];
}

class WalletLiquidationRequired extends PortfolioState {
  final double amount;
  final List<AssetSoldPreviewEntity> assetsToSell;

  const WalletLiquidationRequired(this.amount, this.assetsToSell);

  @override
  List<Object> get props => [amount, assetsToSell];
}

class WalletTransactionInProgress extends PortfolioState {
  const WalletTransactionInProgress();
}

class WalletTransactionSuccess extends PortfolioState {
  final String message;
  const WalletTransactionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class WalletTransactionFailure extends PortfolioState {
  final String message;
  const WalletTransactionFailure(this.message);

  @override
  List<Object> get props => [message];
}
