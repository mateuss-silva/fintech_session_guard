import 'package:fintech_session_guard/features/home/data/models/asset_model.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';

class PortfolioSummaryModel extends PortfolioSummaryEntity {
  const PortfolioSummaryModel({
    required super.totalBalance,
    required super.totalInvested,
    required super.totalCurrent,
    required super.totalProfit,
    required super.variationPct,
    required super.availableBalance,
    required super.availableForInvestment,
    required super.availableForWithdrawal,
    required super.totalAssets,
    required super.isMarketOpen,
    required super.assets,
  });

  factory PortfolioSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final assetsList = json['assets'] as List<dynamic>? ?? [];

    final totalInvested = (summary['totalInvested'] as num?)?.toDouble() ?? 0.0;
    final totalCurrent = (summary['totalCurrent'] as num?)?.toDouble() ?? 0.0;

    // Calculate variationPct client-side as it is not provided in the new summary endpoint
    final variationPct = totalInvested > 0
        ? ((totalCurrent - totalInvested) / totalInvested * 100)
        : 0.0;

    return PortfolioSummaryModel(
      totalBalance: (summary['totalBalance'] as num?)?.toDouble() ?? 0.0,
      totalInvested: totalInvested,
      totalCurrent: totalCurrent,
      totalProfit: (summary['totalProfit'] as num?)?.toDouble() ?? 0.0,
      variationPct: variationPct,
      availableBalance:
          (summary['availableBalance'] as num?)?.toDouble() ?? 0.0,
      availableForInvestment:
          (summary['availableForInvestment'] as num?)?.toDouble() ??
          (summary['availableBalance'] as num?)?.toDouble() ??
          0.0,
      availableForWithdrawal:
          (summary['availableForWithdrawal'] as num?)?.toDouble() ??
          (summary['totalBalance'] as num?)?.toDouble() ??
          0.0,
      totalAssets: (summary['totalAssets'] as num?)?.toInt() ?? 0,
      isMarketOpen: summary['isMarketOpen'] as bool? ?? false,
      assets: assetsList
          .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': {
        'totalBalance': totalBalance,
        'totalInvested': totalInvested,
        'totalCurrent': totalCurrent,
        'totalProfit': totalProfit,
        'variationPct': variationPct,
        'availableBalance': availableBalance,
        'availableForInvestment': availableForInvestment,
        'availableForWithdrawal': availableForWithdrawal,
        'totalAssets': totalAssets,
        'isMarketOpen': isMarketOpen,
      },
      'assets': assets.map((e) => (e as AssetModel).toJson()).toList(),
    };
  }
}
