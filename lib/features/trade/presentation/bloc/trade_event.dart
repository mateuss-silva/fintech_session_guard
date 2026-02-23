import 'package:equatable/equatable.dart';

abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override
  List<Object?> get props => [];
}

class TradeBuyRequested extends TradeEvent {
  final String ticker;
  final double quantity;
  final String? pin;
  final String? biometricToken;

  const TradeBuyRequested({
    required this.ticker,
    required this.quantity,
    this.pin,
    this.biometricToken,
  });

  @override
  List<Object?> get props => [ticker, quantity, pin, biometricToken];
}

class TradeSellRequested extends TradeEvent {
  final String ticker;
  final double quantity;
  final String? pin;
  final String? biometricToken;

  const TradeSellRequested({
    required this.ticker,
    required this.quantity,
    this.pin,
    this.biometricToken,
  });

  @override
  List<Object?> get props => [ticker, quantity, pin, biometricToken];
}
