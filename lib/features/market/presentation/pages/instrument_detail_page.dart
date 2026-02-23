import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/bloc/portfolio_bloc.dart';
import '../../../home/presentation/bloc/portfolio_state.dart';
import '../../../market/domain/entities/instrument_entity.dart';
import '../../../market/domain/entities/instrument_history_entity.dart';
import '../../../trade/presentation/widgets/trade_bottom_sheet.dart';
import '../bloc/instrument_detail_bloc.dart';

const _timeframes = ['1M', '6M', '1Y', '3Y', '5Y'];

class InstrumentDetailPage extends StatelessWidget {
  final InstrumentEntity instrument;
  final bool hasPinConfigured;

  const InstrumentDetailPage({
    super.key,
    required this.instrument,
    required this.hasPinConfigured,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InstrumentDetailBloc>()
        ..add(
          InstrumentDetailRequested(instrumentId: instrument.id, range: '1Y'),
        ),
      child: _InstrumentDetailView(
        instrument: instrument,
        hasPinConfigured: hasPinConfigured,
      ),
    );
  }
}

class _InstrumentDetailView extends StatelessWidget {
  final InstrumentEntity instrument;
  final bool hasPinConfigured;

  const _InstrumentDetailView({
    required this.instrument,
    required this.hasPinConfigured,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          instrument.ticker,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _ChangeChip(changePercent: instrument.changePercent),
          ),
        ],
      ),
      body: BlocBuilder<InstrumentDetailBloc, InstrumentDetailState>(
        builder: (context, state) {
          if (state is InstrumentDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InstrumentDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.loss,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.loss),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<InstrumentDetailBloc>().add(
                      InstrumentDetailRequested(
                        instrumentId: instrument.id,
                        range: '1Y',
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is InstrumentDetailLoaded) {
            return _LoadedBody(
              instrument: instrument,
              history: state.history,
              selectedRange: state.selectedRange,
              hasPinConfigured: hasPinConfigured,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Main content when history is loaded.
class _LoadedBody extends StatelessWidget {
  final InstrumentEntity instrument;
  final InstrumentHistoryEntity history;
  final String selectedRange;
  final bool hasPinConfigured;

  const _LoadedBody({
    required this.instrument,
    required this.history,
    required this.selectedRange,
    required this.hasPinConfigured,
  });

  @override
  Widget build(BuildContext context) {
    // Derive owned quantity from PortfolioBloc
    double ownedQty = 0;
    final portfolioState = context.watch<PortfolioBloc>().state;
    if (portfolioState is PortfolioLoaded) {
      try {
        final found = portfolioState.portfolio.assets.firstWhere(
          (a) => a.ticker == instrument.ticker,
        );
        ownedQty = found.quantity;
      } catch (_) {
        ownedQty = 0;
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriceHeader(instrument: instrument),
                const SizedBox(height: 24),
                _TimeframeChart(
                  history: history,
                  selectedRange: selectedRange,
                  instrumentId: instrument.id,
                ),
                const SizedBox(height: 24),
                _StatsRow(instrument: instrument),
                const SizedBox(height: 24),
                _InstrumentInfoCard(history: history),
              ],
            ),
          ),
        ),
        _ActionBar(
          instrument: instrument,
          ownedQuantity: ownedQty,
          hasPinConfigured: hasPinConfigured,
        ),
      ],
    );
  }
}

/// Prominent price display at the top.
class _PriceHeader extends StatelessWidget {
  final InstrumentEntity instrument;

  const _PriceHeader({required this.instrument});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final isPositive = instrument.changePercent >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          instrument.name,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, Color(0xFF00B4D8)],
          ).createShader(bounds),
          child: Text(
            fmt.format(instrument.currentPrice),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: 16,
              color: isPositive ? AppColors.profit : AppColors.loss,
            ),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${fmt.format(instrument.change)} '
              '(${instrument.changePercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                color: isPositive ? AppColors.profit : AppColors.loss,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Timeframe selector + fl_chart line chart.
class _TimeframeChart extends StatelessWidget {
  final InstrumentHistoryEntity history;
  final String selectedRange;
  final String instrumentId;

  const _TimeframeChart({
    required this.history,
    required this.selectedRange,
    required this.instrumentId,
  });

  @override
  Widget build(BuildContext context) {
    final points = history.history;
    if (points.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = points.map((p) => p.value).reduce(min) * 0.98;
    final maxY = points.map((p) => p.value).reduce(max) * 1.02;
    final isPositive = points.last.value >= points.first.value;
    final lineColor = isPositive ? AppColors.profit : AppColors.loss;

    return Column(
      children: [
        // Chart
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surface,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final idx = spot.x.toInt().clamp(0, points.length - 1);
                      final point = points[idx];
                      final dateFmt = DateFormat('dd/MM/yy');
                      final priceFmt = NumberFormat.simpleCurrency(
                        locale: 'pt_BR',
                      );
                      return LineTooltipItem(
                        '${dateFmt.format(point.date)}\n${priceFmt.format(point.value)}',
                        TextStyle(
                          color: lineColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: lineColor,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        lineColor.withOpacity(0.25),
                        lineColor.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 500),
          ),
        ),
        const SizedBox(height: 12),
        // Timeframe pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _timeframes.map((tf) {
            final isSelected = tf == selectedRange;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  context.read<InstrumentDetailBloc>().add(
                    InstrumentDetailRequested(
                      instrumentId: instrumentId,
                      range: tf,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tf,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// High / Low / Open stats row.
class _StatsRow extends StatelessWidget {
  final InstrumentEntity instrument;

  const _StatsRow({required this.instrument});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _StatCell(label: 'Open', value: fmt.format(instrument.open)),
          const _Divider(),
          _StatCell(
            label: 'High',
            value: fmt.format(instrument.high),
            color: AppColors.profit,
          ),
          const _Divider(),
          _StatCell(
            label: 'Low',
            value: fmt.format(instrument.low),
            color: AppColors.loss,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.cardBorder);
  }
}

/// Description and investor profile badge.
class _InstrumentInfoCard extends StatelessWidget {
  final InstrumentHistoryEntity history;

  const _InstrumentInfoCard({required this.history});

  Color _profileColor(String profile) {
    return switch (profile) {
      'Conservative' => const Color(0xFF22C55E),
      'Moderate' => const Color(0xFFF59E0B),
      _ => AppColors.loss,
    };
  }

  IconData _profileIcon(String profile) {
    return switch (profile) {
      'Conservative' => Icons.shield_outlined,
      'Moderate' => Icons.balance_outlined,
      _ => Icons.rocket_launch_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final profileColor = _profileColor(history.investorProfile);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: profileColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: profileColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _profileIcon(history.investorProfile),
                  color: profileColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${history.investorProfile} Investor',
                  style: TextStyle(
                    color: profileColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'About',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            history.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky BUY / SELL action bar at the bottom.
class _ActionBar extends StatelessWidget {
  final InstrumentEntity instrument;
  final double ownedQuantity;
  final bool hasPinConfigured;

  const _ActionBar({
    required this.instrument,
    required this.ownedQuantity,
    required this.hasPinConfigured,
  });

  void _openTradeSheet(BuildContext context, {required bool isSellMode}) {
    final portfolioBloc = context.read<PortfolioBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: portfolioBloc,
        child: TradeBottomSheet(
          ticker: instrument.ticker,
          assetName: instrument.name,
          currentPrice: instrument.currentPrice,
          hasPinConfigured: hasPinConfigured,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSellable = ownedQuantity > 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (hasSellable) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openTradeSheet(context, isSellMode: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.loss,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'SELL  ${ownedQuantity.toStringAsFixed(ownedQuantity < 10 ? 4 : 0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openTradeSheet(context, isSellMode: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'BUY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  final double changePercent;

  const _ChangeChip({required this.changePercent});

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent >= 0;
    final bg = (isPositive ? AppColors.profit : AppColors.loss).withOpacity(
      0.15,
    );
    final fg = isPositive ? AppColors.profit : AppColors.loss;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
