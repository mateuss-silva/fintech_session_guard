import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/asset_list.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/portfolio_summary_card.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/wallet_dialogs.dart';
import 'package:fintech_session_guard/features/market/presentation/widgets/instrument_search_delegate.dart';

import 'package:fintech_session_guard/core/presentation/widgets/responsive_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PortfolioBloc>()..add(const PortfolioSummaryRequested()),
      child: Builder(
        builder: (context) {
          return ResponsiveScaffold(
            title: 'My Portfolio',
            onSearchTapped: () {
              showSearch(
                context: context,
                delegate: InstrumentSearchDelegate(),
              );
            },
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<PortfolioBloc>().add(const PortfolioRefreshed());
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
            ],
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<PortfolioBloc>().add(const PortfolioRefreshed());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocListener<PortfolioBloc, PortfolioState>(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: AppColors.profit,
                        ),
                      );
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
                        current is! WalletTransactionFailure,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PortfolioSummaryCard(
                                      summary: state.portfolio,
                                      onDeposit: () {
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
                                        WalletDialogs.showWithdrawDialog(
                                          context,
                                          onConfirm: (amount) {
                                            context.read<PortfolioBloc>().add(
                                              WalletWithdrawRequested(amount),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    DefaultTabController(
                                      length: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TabBar(
                                            isScrollable: true,
                                            tabAlignment: TabAlignment.start,
                                            indicatorColor: AppColors.primary,
                                            labelColor: AppColors.textPrimary,
                                            unselectedLabelColor:
                                                AppColors.textSecondary,
                                            dividerColor: Colors.transparent,
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            tabs: const [
                                              Tab(text: 'My Portfolio'),
                                              Tab(text: 'Watchlist'),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Builder(
                                            builder: (context) {
                                              final tabController =
                                                  DefaultTabController.of(
                                                    context,
                                                  );
                                              return AnimatedBuilder(
                                                animation: tabController,
                                                builder: (context, _) {
                                                  // Portfolio Tab
                                                  if (tabController.index ==
                                                      0) {
                                                    return state
                                                            .portfolio
                                                            .assets
                                                            .isEmpty
                                                        ? const Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical:
                                                                      32.0,
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
                                                            assets: state
                                                                .portfolio
                                                                .assets,
                                                            watchlist:
                                                                state.watchlist,
                                                          );
                                                  }
                                                  // Watchlist Tab
                                                  else {
                                                    final watchedAssets = state
                                                        .portfolio
                                                        .assets
                                                        .where(
                                                          (a) => state.watchlist
                                                              .contains(
                                                                a.ticker,
                                                              ),
                                                        )
                                                        .toList();
                                                    return watchedAssets.isEmpty
                                                        ? const Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical:
                                                                      32.0,
                                                                ),
                                                            child: Center(
                                                              child: Text(
                                                                'Your watchlist is empty.',
                                                                style: TextStyle(
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : AssetList(
                                                            assets:
                                                                watchedAssets,
                                                            watchlist:
                                                                state.watchlist,
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
