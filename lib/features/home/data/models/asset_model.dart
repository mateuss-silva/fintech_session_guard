import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';

class AssetModel extends AssetEntity {
  const AssetModel({
    required super.id,
    required super.instrumentId,
    required super.ticker,
    required super.name,
    required super.type,
    required super.quantity,
    required super.avgPrice,
    required super.currentPrice,
    required super.currentValue,
    required super.profit,
    required super.variationPct,
    required super.change,
    required super.changePercent,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] ?? '',
      instrumentId: json['instrumentId'] ?? '',
      ticker: json['ticker'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      avgPrice: (json['avgPrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      variationPct: (json['variationPct'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instrumentId': instrumentId,
      'ticker': ticker,
      'name': name,
      'type': type,
      'quantity': quantity,
      'avgPrice': avgPrice,
      'currentPrice': currentPrice,
      'currentValue': currentValue,
      'profit': profit,
      'variationPct': variationPct,
      'change': change,
      'changePercent': changePercent,
    };
  }
}
