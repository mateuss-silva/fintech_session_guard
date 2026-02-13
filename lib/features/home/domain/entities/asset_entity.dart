import 'package:equatable/equatable.dart';

class AssetEntity extends Equatable {
  final String id;
  final String instrumentId;
  final String ticker;
  final String name;
  final String type;
  final double quantity;
  final double avgPrice;
  final double currentPrice;
  final double currentValue;
  final double profit;
  final double variationPct;
  final double change;
  final double changePercent;

  const AssetEntity({
    required this.id,
    required this.instrumentId,
    required this.ticker,
    required this.name,
    required this.type,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
    required this.currentValue,
    required this.profit,
    required this.variationPct,
    required this.change,
    required this.changePercent,
  });

  @override
  List<Object?> get props => [
    id,
    instrumentId,
    ticker,
    name,
    type,
    quantity,
    avgPrice,
    currentPrice,
    currentValue,
    profit,
    variationPct,
    change,
    changePercent,
  ];
}
