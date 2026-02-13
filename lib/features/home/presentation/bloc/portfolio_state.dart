import 'package:equatable/equatable.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';

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

  const PortfolioLoaded(this.portfolio);

  @override
  List<Object> get props => [portfolio];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object> get props => [message];
}
