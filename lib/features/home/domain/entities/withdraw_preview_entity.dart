class AssetSoldPreviewEntity {
  final String ticker;
  final double quantitySold;
  final double valueGenerated;
  final double priceAtExecution;

  AssetSoldPreviewEntity({
    required this.ticker,
    required this.quantitySold,
    required this.valueGenerated,
    required this.priceAtExecution,
  });
}

class WithdrawPreviewEntity {
  final bool requiresLiquidation;
  final double amountRequested;
  final double brlAvailable;
  final double? shortfall;
  final List<AssetSoldPreviewEntity> assetsToSell;

  WithdrawPreviewEntity({
    required this.requiresLiquidation,
    required this.amountRequested,
    required this.brlAvailable,
    this.shortfall,
    required this.assetsToSell,
  });
}
