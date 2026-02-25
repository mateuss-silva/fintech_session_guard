import 'package:flutter/material.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/live_asset_item.dart';

class AssetList extends StatelessWidget {
  final List<AssetEntity> assets;
  final bool hasPinConfigured;

  const AssetList({
    super.key,
    required this.assets,
    this.hasPinConfigured = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: assets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asset = assets[index];
        return LiveAssetItem(asset: asset, hasPinConfigured: hasPinConfigured);
      },
    );
  }
}
