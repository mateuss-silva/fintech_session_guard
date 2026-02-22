import 'package:fintech_session_guard/features/home/domain/entities/portfolio_type_summary_entity.dart';

class PortfolioTypeSummaryModel extends PortfolioTypeSummaryEntity {
  const PortfolioTypeSummaryModel({
    required super.type,
    required super.invested,
    required super.current,
    required super.assetCount,
  });

  factory PortfolioTypeSummaryModel.fromJson(Map<String, dynamic> json) {
    return PortfolioTypeSummaryModel(
      type: json['type'] as String? ?? 'Others',
      invested: (json['invested'] as num?)?.toDouble() ?? 0.0,
      current: (json['current'] as num?)?.toDouble() ?? 0.0,
      assetCount: (json['assetCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'invested': invested,
      'current': current,
      'assetCount': assetCount,
    };
  }
}
