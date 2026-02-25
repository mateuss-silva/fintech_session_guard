import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/core/security/transaction_auth_helper.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/asset_list.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/portfolio_summary_card.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/portfolio_composition_chart.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/wallet_dialogs.dart';

class DashboardView extends StatelessWidget {
  final VoidCallback onHistoryTapped;
  final bool hasPinConfigured;
  final String userName;

  const DashboardView({
    super.key,
    required this.onHistoryTapped,
    required this.userName,
    this.hasPinConfigured = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PortfolioBloc, PortfolioState>(
      listenWhen: (previous, current) =>
          current is WalletTransactionSuccess ||
          current is WalletTransactionFailure ||
          current is WalletLiquidationRequired,
      listener: (context, state) {
        if (state is WalletLiquidationRequired) {
          WalletDialogs.showLiquidationConfirmationDialog(
            context,
            originalAmount: state.amount,
            assetsToSell: state.assetsToSell,
            onConfirm: () {
              context.read<PortfolioBloc>().add(
                WalletWithdrawConfirmed(state.amount),
              );
            },
          );
        } else if (state is WalletTransactionSuccess) {
          WalletDialogs.showSuccessDialog(context, state.message);
        } else if (state is WalletTransactionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.loss,
            ),
          );
        }
      },
      child: BlocBuilder<PortfolioBloc, PortfolioState>(
        buildWhen: (previous, current) =>
            current is! WalletTransactionInProgress &&
            current is! WalletTransactionSuccess &&
            current is! WalletTransactionFailure &&
            current is! WalletLiquidationRequired,
        builder: (context, state) {
          if (state is PortfolioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PortfolioError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.loss),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PortfolioBloc>().add(
                        const PortfolioSummaryRequested(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is PortfolioLoaded) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WelcomeHeader(userName: userName),
                        const SizedBox(height: 20),
                        PortfolioSummaryCard(
                          summary: state.portfolio,
                          onHistoryTapped: onHistoryTapped,
                          onDeposit: () {
                            if (!hasPinConfigured) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please set up your PIN first to perform transactions.',
                                  ),
                                  backgroundColor: Color(0xFF7C4B00),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            WalletDialogs.showDepositDialog(
                              context,
                              onConfirm: (amount) {
                                context.read<PortfolioBloc>().add(
                                  WalletDepositRequested(amount),
                                );
                              },
                            );
                          },
                          onWithdraw: () {
                            if (!hasPinConfigured) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please set up your PIN first to perform transactions.',
                                  ),
                                  backgroundColor: Color(0xFF7C4B00),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            WalletDialogs.showWithdrawDialog(
                              context,
                              onConfirm: (amount) async {
                                final authResult =
                                    await TransactionAuthHelper.authenticate(
                                      context,
                                      reason:
                                          'Authenticate to withdraw \$$amount',
                                    );
                                if (!authResult.isAuthenticated) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Authentication failed. Withdraw cancelled.',
                                        ),
                                        backgroundColor: AppColors.loss,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (context.mounted) {
                                  context.read<PortfolioBloc>().add(
                                    WalletWithdrawRequested(amount),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        if (state.portfolio.byType.isNotEmpty) ...[
                          PortfolioCompositionChart(
                            byType: state.portfolio.byType,
                            totalCurrent: state.portfolio.totalCurrent,
                            allAssets: state.portfolio.assets,
                          ),
                          const SizedBox(height: 24),
                        ],
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                indicatorColor: AppColors.primary,
                                labelColor: AppColors.textPrimary,
                                unselectedLabelColor: AppColors.textSecondary,
                                dividerColor: Colors.transparent,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                tabs: const [
                                  Tab(text: 'My Portfolio'),
                                  Tab(text: 'Watchlist'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Builder(
                                builder: (context) {
                                  final tabController = DefaultTabController.of(
                                    context,
                                  );
                                  return AnimatedBuilder(
                                    animation: tabController,
                                    builder: (context, _) {
                                      // Portfolio Tab
                                      if (tabController.index == 0) {
                                        final ownedAssets = state
                                            .portfolio
                                            .assets
                                            .where((a) => a.quantity > 0)
                                            .toList();
                                        return ownedAssets.isEmpty
                                            ? const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 32.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'You have no assets yet.',
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : AssetList(
                                                assets: ownedAssets,
                                                hasPinConfigured:
                                                    hasPinConfigured,
                                              );
                                      }
                                      // Watchlist Tab
                                      else {
                                        final watchedAssets = state
                                            .portfolio
                                            .assets
                                            .where(
                                              (a) => state.watchlist.contains(
                                                a.ticker,
                                              ),
                                            )
                                            .toList();
                                        return watchedAssets.isEmpty
                                            ? const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 32.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Add instruments from Search or instrument details to your watchlist.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : AssetList(
                                                assets: watchedAssets,
                                                hasPinConfigured:
                                                    hasPinConfigured,
                                              );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Time-aware greeting header with the user's name.
class _WelcomeHeader extends StatelessWidget {
  final String userName;

  const _WelcomeHeader({required this.userName});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting,',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, Color(0xFF00B4D8)],
          ).createShader(bounds),
          child: Text(
            '$userName 👋',
            style: const TextStyle(
              color: Colors.white, // masked by shader
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
