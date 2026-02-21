import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';
import 'package:fintech_session_guard/features/home/domain/repositories/portfolio_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LiveAssetItem extends StatefulWidget {
  final AssetEntity asset;
  final bool isWatched;

  const LiveAssetItem({super.key, required this.asset, this.isWatched = false});

  @override
  State<LiveAssetItem> createState() => _LiveAssetItemState();
}

class _LiveAssetItemState extends State<LiveAssetItem>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  StreamSubscription? _subscription;
  late double _currentUnitPrice;
  late double _currentVariation;
  AnimationController? _controller;
  Color? _flashColor;
  Timer? _debounceTimer;
  final Key _visibilityKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentUnitPrice = widget.asset.currentPrice;
    _currentVariation = widget.asset.variationPct;

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
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _disconnectStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    VisibilityDetectorController.instance.notifyNow();
  }

  void _connectStream() {
    if (_subscription != null) return;

    final stream = sl<PortfolioRepository>().getAssetPriceStream(
      widget.asset.ticker,
    );

    _subscription = stream.listen((update) {
      if (!mounted) return;

      final oldPrice = _currentUnitPrice;
      if (update.price != oldPrice) {
        setState(() {
          _currentUnitPrice = update.price;
          _currentVariation = update.variationPct;

          if (oldPrice != _currentUnitPrice) {
            _flash(_currentUnitPrice > oldPrice);
          }
        });
      }
    });
  }

  void _disconnectStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _flash(bool isPositive) {
    if (!mounted) return;
    setState(() {
      _flashColor = isPositive
          ? AppColors.profit.withValues(alpha: 0.3)
          : AppColors.loss.withValues(alpha: 0.3);
    });
    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    final isPositive = _currentVariation >= 0;

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0) {
          // Debounce connection to prevent scroll-by triggers
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 300), () {
            if (mounted) _connectStream();
          });
        } else {
          _debounceTimer?.cancel();
          _disconnectStream();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _flashColor ?? AppColors.cardColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    Text(
                      '${widget.asset.quantity} • ${currencyFormat.format(_currentUnitPrice)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(
                      widget.asset.quantity * _currentUnitPrice,
                    ),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPositive ? AppColors.profit : AppColors.loss,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  widget.isWatched ? Icons.star : Icons.star_border,
                  color: widget.isWatched
                      ? Colors.amber
                      : AppColors.textSecondary,
                ),
                onPressed: () {
                  if (widget.isWatched) {
                    context.read<PortfolioBloc>().add(
                      WatchlistRemoved(widget.asset.ticker),
                    );
                  } else {
                    context.read<PortfolioBloc>().add(
                      WatchlistAdded(widget.asset.ticker),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
