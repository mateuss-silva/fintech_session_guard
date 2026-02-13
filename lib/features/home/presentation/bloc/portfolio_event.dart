import 'package:equatable/equatable.dart';

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
