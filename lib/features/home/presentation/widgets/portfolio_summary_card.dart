import 'package:flutter/material.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/portfolio_stat_item.dart';
import 'package:intl/intl.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final PortfolioSummaryEntity summary;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistoryTapped;

  const PortfolioSummaryCard({
    super.key,
    required this.summary,
    this.onDeposit,
    this.onWithdraw,
    this.onHistoryTapped,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Portfolio Value',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    onHistoryTapped?.call();
                  },
                  tooltip: 'Transaction History',
                ),
              ],
            ),
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
                PortfolioStatItem(
                  label: 'Invested',
                  value: currencyFormat.format(summary.totalInvested),
                  valueColor: AppColors.textPrimary,
                ),
                PortfolioStatItem(
                  label: 'Profit',
                  value: currencyFormat.format(summary.totalProfit),
                  valueColor: summary.totalProfit >= 0
                      ? AppColors.profit
                      : AppColors.loss,
                  isProfit: true,
                ),
                PortfolioStatItem(
                  label: 'Return',
                  value:
                      '${summary.variationPct >= 0 ? '+' : ''}${percentFormat.format(summary.variationPct / 100)}',
                  valueColor: summary.variationPct >= 0
                      ? AppColors.profit
                      : AppColors.loss,
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
                PortfolioStatItem(
                  label: 'Available Cash',
                  value: currencyFormat.format(summary.availableForInvestment),
                  valueColor: AppColors.textPrimary,
                ),
                PortfolioStatItem(
                  label: 'Market Status',
                  value: summary.isMarketOpen ? 'Open' : 'Closed',
                  valueColor: summary.isMarketOpen
                      ? AppColors.profit
                      : AppColors.loss,
                  isProfit: true,
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
}
