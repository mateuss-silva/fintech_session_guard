import 'package:fintech_session_guard/features/home/domain/entities/withdraw_preview_entity.dart';

class AssetSoldPreviewModel extends AssetSoldPreviewEntity {
  AssetSoldPreviewModel({
    required super.ticker,
    required super.quantitySold,
    required super.valueGenerated,
    required super.priceAtExecution,
  });

  factory AssetSoldPreviewModel.fromJson(Map<String, dynamic> json) {
    return AssetSoldPreviewModel(
      ticker: json['ticker'] ?? '',
      quantitySold: (json['quantity_sold'] as num?)?.toDouble() ?? 0.0,
      valueGenerated: (json['value_generated'] as num?)?.toDouble() ?? 0.0,
      priceAtExecution: (json['price_at_execution'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WithdrawPreviewModel extends WithdrawPreviewEntity {
  WithdrawPreviewModel({
    required super.requiresLiquidation,
    required super.amountRequested,
    required super.brlAvailable,
    super.shortfall,
    required super.assetsToSell,
  });

  factory WithdrawPreviewModel.fromJson(Map<String, dynamic> json) {
    var list = json['assets_to_sell'] as List? ?? [];
    List<AssetSoldPreviewModel> assetsList = list
        .map((i) => AssetSoldPreviewModel.fromJson(i))
        .toList();

    return WithdrawPreviewModel(
      requiresLiquidation: json['requires_liquidation'] ?? false,
      amountRequested: (json['amount_requested'] as num?)?.toDouble() ?? 0.0,
      brlAvailable: (json['brl_available'] as num?)?.toDouble() ?? 0.0,
      shortfall: (json['shortfall'] as num?)?.toDouble(),
      assetsToSell: assetsList,
    );
  }
}
