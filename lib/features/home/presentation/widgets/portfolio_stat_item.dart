import 'package:flutter/material.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';

class PortfolioStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isProfit;

  const PortfolioStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    this.isProfit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: isProfit && valueColor != AppColors.textPrimary
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              : EdgeInsets.zero,
          decoration: isProfit && valueColor != AppColors.textPrimary
              ? BoxDecoration(
                  color: valueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
