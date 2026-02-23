import 'package:equatable/equatable.dart';

abstract class TradeState extends Equatable {
  const TradeState();

  @override
  List<Object?> get props => [];
}

class TradeInitial extends TradeState {}

class TradeLoading extends TradeState {}

class TradeSuccess extends TradeState {
  final String message;
  final bool isBuy;

  const TradeSuccess({required this.message, required this.isBuy});

  @override
  List<Object?> get props => [message, isBuy];
}

class TradeFailure extends TradeState {
  final String message;

  const TradeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class TradeAuthRequired extends TradeState {
  final String ticker;
  final double quantity;
  final bool isBuy;
  final String message;

  const TradeAuthRequired({
    required this.ticker,
    required this.quantity,
    required this.isBuy,
    this.message = 'Authentication required to complete trade',
  });

  @override
  List<Object?> get props => [ticker, quantity, isBuy, message];
}
