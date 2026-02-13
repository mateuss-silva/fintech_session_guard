import 'package:flutter/material.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';
import 'package:intl/intl.dart';

class AssetList extends StatelessWidget {
  final List<AssetEntity> assets;

  const AssetList({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: assets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asset = assets[index];
        return _buildAssetItem(context, asset);
      },
    );
  }

  Widget _buildAssetItem(BuildContext context, AssetEntity asset) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    final isPositive = asset.variationPct >= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        // Removed border for a cleaner, modern look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  asset.ticker.substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.ticker,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    asset.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(asset.currentValue),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      color: isPositive ? AppColors.profit : AppColors.loss,
                      size: 20,
                    ),
                    Text(
                      percentFormat.format(asset.variationPct / 100),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPositive ? AppColors.profit : AppColors.loss,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
