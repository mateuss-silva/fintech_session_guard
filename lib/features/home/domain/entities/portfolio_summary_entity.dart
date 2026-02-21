import 'package:equatable/equatable.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';

class PortfolioSummaryEntity extends Equatable {
  final double totalBalance;
  final double totalInvested;
  final double totalCurrent;
  final double totalProfit;
  final double variationPct;
  final double availableBalance;
  final double availableForInvestment;
  final double availableForWithdrawal;
  final int totalAssets;
  final List<AssetEntity> assets;

  const PortfolioSummaryEntity({
    required this.totalBalance,
    required this.totalInvested,
    required this.totalCurrent,
    required this.totalProfit,
    required this.variationPct,
    required this.availableBalance,
    required this.availableForInvestment,
    required this.availableForWithdrawal,
    required this.totalAssets,
    required this.assets,
  });

  @override
  List<Object?> get props => [
    totalBalance,
    totalInvested,
    totalCurrent,
    totalProfit,
    variationPct,
    availableBalance,
    availableForInvestment,
    availableForWithdrawal,
    totalAssets,
    assets,
  ];
}
