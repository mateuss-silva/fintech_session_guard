import 'package:equatable/equatable.dart';

class InstrumentEntity extends Equatable {
  final String id;
  final String ticker;
  final String name;
  final String type;
  final String? sector;
  final double currentPrice;
  final double open;
  final double high;
  final double low;
  final double change;
  final double changePercent;
  final String timestamp;

  const InstrumentEntity({
    required this.id,
    required this.ticker,
    required this.name,
    required this.type,
    this.sector,
    required this.currentPrice,
    required this.open,
    required this.high,
    required this.low,
    required this.change,
    required this.changePercent,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    ticker,
    name,
    type,
    sector,
    currentPrice,
    open,
    high,
    low,
    change,
    changePercent,
    timestamp,
  ];
}
