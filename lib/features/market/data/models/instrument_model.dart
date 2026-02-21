import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';

class InstrumentModel extends InstrumentEntity {
  const InstrumentModel({
    required super.id,
    required super.ticker,
    required super.name,
    required super.type,
    super.sector,
    required super.currentPrice,
    required super.open,
    required super.high,
    required super.low,
    required super.change,
    required super.changePercent,
    required super.timestamp,
  });

  factory InstrumentModel.fromJson(Map<String, dynamic> json) {
    return InstrumentModel(
      id: json['id'] as String? ?? '',
      ticker: json['ticker'] as String? ?? 'UNKNOWN',
      name: json['name'] as String? ?? 'Unknown Asset',
      type: json['type'] as String? ?? 'unknown',
      sector: json['sector'] as String?,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      timestamp:
          json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticker': ticker,
      'name': name,
      'type': type,
      'sector': sector,
      'currentPrice': currentPrice,
      'open': open,
      'high': high,
      'low': low,
      'change': change,
      'changePercent': changePercent,
      'timestamp': timestamp,
    };
  }
}
