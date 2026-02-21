import 'package:flutter/material.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:intl/intl.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final PortfolioSummaryEntity summary;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;

  const PortfolioSummaryCard({
    super.key,
    required this.summary,
    this.onDeposit,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: 'en_US',
    ); // Or 'pt_BR'
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.portfolioGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(summary.totalBalance),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(
                  context,
                  'Invested',
                  currencyFormat.format(summary.totalInvested),
                  AppColors.textPrimary,
                ),
                _buildStat(
                  context,
                  'Profit',
                  currencyFormat.format(summary.totalProfit),
                  summary.totalProfit >= 0 ? AppColors.profit : AppColors.loss,
                  isProfit: true,
                ),
                _buildStat(
                  context,
                  'Return',
                  '${summary.variationPct >= 0 ? '+' : ''}${percentFormat.format(summary.variationPct / 100)}',
                  summary.variationPct >= 0 ? AppColors.profit : AppColors.loss,
                  isProfit: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(
                  context,
                  'Investment Available',
                  currencyFormat.format(summary.availableForInvestment),
                  AppColors.textPrimary,
                ),
                _buildStat(
                  context,
                  'Withdrawal Available',
                  currencyFormat.format(summary.availableForWithdrawal),
                  AppColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => onDeposit?.call(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Deposit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => onWithdraw?.call(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Withdraw',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool isProfit = false,
  }) {
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
