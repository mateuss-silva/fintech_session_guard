import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_price_update.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';

class LiveAssetItem extends StatefulWidget {
  final AssetEntity asset;

  const LiveAssetItem({super.key, required this.asset});

  @override
  State<LiveAssetItem> createState() => _LiveAssetItemState();
}

class _LiveAssetItemState extends State<LiveAssetItem>
    with SingleTickerProviderStateMixin {
  late Stream<AssetPriceUpdate> _priceStream;
  late double _currentPrice;
  late double _currentVariation;
  AnimationController? _controller;
  Color? _flashColor;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.asset.currentValue;
    _currentVariation = widget.asset.variationPct;
    _priceStream = sl<PortfolioRepository>().getAssetPriceStream(
      widget.asset.ticker,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _flashColor = null;
        });
        _controller?.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _flash(bool isPositive) {
    if (!mounted) return;
    setState(() {
      _flashColor = isPositive
          ? AppColors.profit.withOpacity(0.3)
          : AppColors.loss.withOpacity(0.3);
    });
    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);

    return StreamBuilder<AssetPriceUpdate>(
      stream: _priceStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final oldPrice = _currentPrice;
          _currentPrice = snapshot.data!.price;
          _currentVariation = snapshot.data!.variationPct;

          if (_currentPrice != oldPrice) {
            // Trigger flash effect on next frame if we could, but here we just set state
            // actually we should trigger flash in the builder but we need to be careful about build cycles.
            // A better way is to listen to the stream in initState and setState, but StreamBuilder handles disposal better.
            // For simplicity in this demo, we'll just flash based on comparison if we were using a listener.
            // Since we are in build, we can't call setState.
            // So we'll accept the limitation of no flash for now, or use a custom hook.
            // Let's stick to just updating the values for now.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (oldPrice != _currentPrice) {
                _flash(_currentPrice > oldPrice);
              }
            });
          }
        }

        final isPositive = _currentVariation >= 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _flashColor ?? AppColors.cardColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
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
                      widget.asset.ticker.substring(0, 1),
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
                        widget.asset.ticker,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Text(
                        widget.asset.name,
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
                      currencyFormat.format(_currentPrice),
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
                          percentFormat.format(_currentVariation / 100),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isPositive
                                    ? AppColors.profit
                                    : AppColors.loss,
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
      },
    );
  }
}
