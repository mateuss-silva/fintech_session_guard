import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';
import 'package:intl/intl.dart';

class TransactionHistoryView extends StatefulWidget {
  const TransactionHistoryView({super.key});

  @override
  State<TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<TransactionHistoryView> {
  @override
  void initState() {
    super.initState();
    context.read<PortfolioBloc>().add(const TransactionHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<PortfolioBloc, PortfolioState>(
              buildWhen: (previous, current) =>
                  current is TransactionHistoryLoading ||
                  current is TransactionHistoryLoaded ||
                  current is TransactionHistoryError,
              builder: (context, state) {
                if (state is TransactionHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TransactionHistoryError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.loss),
                    ),
                  );
                } else if (state is TransactionHistoryLoaded) {
                  if (state.transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No transactions found.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = state.transactions[index];
                      final isPositive =
                          tx.type == 'deposit' || tx.type == 'sell';
                      final currencyFormat = NumberFormat.simpleCurrency(
                        locale: 'en_US',
                      );
                      final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

                      String title = tx.type.toUpperCase();
                      if (tx.assetName != null && tx.assetName!.isNotEmpty) {
                        title += ' • ${tx.ticker}';
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cardColor,
                          child: Icon(
                            isPositive
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isPositive
                                ? AppColors.profit
                                : AppColors.loss,
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormat.format(tx.createdAt.toLocal()),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (tx.quantity != null)
                              Text(
                                'Qty: ${tx.quantity!.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          '${isPositive ? '+' : '-'} ${currencyFormat.format(tx.amount)}',
                          style: TextStyle(
                            color: isPositive
                                ? AppColors.profit
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text(
                    'Loading history...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Transaction History',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
