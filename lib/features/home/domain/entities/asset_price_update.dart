class AssetPriceUpdate {
  final String ticker;
  final double price;
  final double variationPct;

  const AssetPriceUpdate({
    required this.ticker,
    required this.price,
    required this.variationPct,
  });
}
