import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_type_summary_entity.dart';
import 'package:fintech_session_guard/features/home/domain/entities/asset_entity.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/asset_list.dart';

class PortfolioCompositionChart extends StatefulWidget {
  final List<PortfolioTypeSummaryEntity> byType;
  final double totalCurrent;
  final List<AssetEntity> allAssets;

  const PortfolioCompositionChart({
    super.key,
    required this.byType,
    required this.totalCurrent,
    required this.allAssets,
  });

  @override
  State<PortfolioCompositionChart> createState() =>
      _PortfolioCompositionChartState();
}

class _PortfolioCompositionChartState extends State<PortfolioCompositionChart> {
  int touchedIndex = -1;

  Color _getColorForType(String type, int index) {
    switch (type.toLowerCase()) {
      case 'stock':
      case 'acao':
        return AppColors.secondary; // Blue
      case 'fii':
        return AppColors.primary; // Teal/Green
      case 'crypto':
        return AppColors.warning; // Orange/Yellow
      case 'currency':
        return AppColors.profit; // Green
      case 'renda_fixa':
        return AppColors.accent; // Purple
      default:
        // Fallback colors for unknown types
        final defaultColors = [
          Colors.pink,
          Colors.cyan,
          Colors.amber,
          Colors.indigo,
          Colors.lime,
        ];
        return defaultColors[index % defaultColors.length];
    }
  }

  String _formatTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
      case 'acao':
        return 'Stocks';
      case 'fii':
        return 'Real Estate (FIIs)';
      case 'crypto':
        return 'Crypto';
      case 'currency':
        return 'Cash / Currency';
      case 'renda_fixa':
        return 'Fixed Income';
      default:
        return type[0].toUpperCase() + type.substring(1);
    }
  }

  void _showAssetsDialog(BuildContext context, String type) {
    final filteredAssets = widget.allAssets
        .where((a) => a.type.toLowerCase() == type.toLowerCase())
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTypeLabel(type),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: filteredAssets.isEmpty
                      ? const Center(
                          child: Text(
                            'No assets found for this type.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : SingleChildScrollView(
                          child: AssetList(assets: filteredAssets),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.byType.isEmpty || widget.totalCurrent <= 0) {
      return const SizedBox.shrink();
    }

    // Sort by current value ascending so largest is last/top
    final sortedTypes = List<PortfolioTypeSummaryEntity>.from(widget.byType)
      ..sort((a, b) => b.current.compareTo(a.current));

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Composition',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });

                          if (event is FlTapUpEvent &&
                              pieTouchResponse != null &&
                              pieTouchResponse.touchedSection != null) {
                            final index = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                            if (index >= 0 && index < sortedTypes.length) {
                              _showAssetsDialog(
                                context,
                                sortedTypes[index].type,
                              );
                            }
                          }
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sortedTypes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final percentage =
                            (data.current / widget.totalCurrent) * 100;

                        final isTouched = index == touchedIndex;
                        final radius = isTouched ? 60.0 : 50.0;
                        final fontSize = isTouched ? 16.0 : 12.0;

                        return PieChartSectionData(
                          color: _getColorForType(data.type, index),
                          value: data.current,
                          title: percentage >= 5
                              ? '${percentage.toStringAsFixed(1)}%'
                              : '',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedTypes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final percentage =
                        (data.current / widget.totalCurrent) * 100;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => _showAssetsDialog(context, data.type),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getColorForType(data.type, index),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatTypeLabel(data.type),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}% • \$ ${data.current.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ], // Closes Row children
                          ), // Closes Row
                        ), // Closes inner Padding
                      ), // Closes InkWell
                    ); // Closes outer Padding
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
