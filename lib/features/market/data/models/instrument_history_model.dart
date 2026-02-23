import 'package:fintech_session_guard/features/market/domain/entities/instrument_history_entity.dart';

class PricePointModel extends PricePoint {
  const PricePointModel({required super.date, required super.value});

  factory PricePointModel.fromJson(Map<String, dynamic> json) {
    return PricePointModel(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

class InstrumentHistoryModel extends InstrumentHistoryEntity {
  const InstrumentHistoryModel({
    required super.instrumentId,
    required super.ticker,
    required super.name,
    required super.type,
    super.sector,
    required super.description,
    required super.investorProfile,
    required super.history,
  });

  factory InstrumentHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'] as List<dynamic>? ?? [];
    final points = rawHistory
        .map((e) => PricePointModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return InstrumentHistoryModel(
      instrumentId: json['instrumentId'] as String? ?? '',
      ticker: json['ticker'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      sector: json['sector'] as String?,
      description: json['description'] as String? ?? '',
      investorProfile: json['investorProfile'] as String? ?? 'Moderate',
      history: points,
    );
  }
}
