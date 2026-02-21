import 'package:flutter/material.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/live_asset_item.dart';

class AssetList extends StatelessWidget {
  final List<AssetEntity> assets;
  final List<String> watchlist;

  const AssetList({super.key, required this.assets, this.watchlist = const []});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: assets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asset = assets[index];
        final isWatched = watchlist.contains(asset.ticker);
        return LiveAssetItem(asset: asset, isWatched: isWatched);
      },
    );
  }
}
