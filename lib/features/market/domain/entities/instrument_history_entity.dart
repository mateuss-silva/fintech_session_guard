import 'package:equatable/equatable.dart';

class PricePoint extends Equatable {
  final DateTime date;
  final double value;

  const PricePoint({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];
}

class InstrumentHistoryEntity extends Equatable {
  final String instrumentId;
  final String ticker;
  final String name;
  final String type;
  final String? sector;
  final String description;
  final String investorProfile; // Conservative | Moderate | Aggressive
  final List<PricePoint> history;

  const InstrumentHistoryEntity({
    required this.instrumentId,
    required this.ticker,
    required this.name,
    required this.type,
    this.sector,
    required this.description,
    required this.investorProfile,
    required this.history,
  });

  @override
  List<Object?> get props => [instrumentId, ticker, history];
}
