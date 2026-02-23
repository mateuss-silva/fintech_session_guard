import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/market/presentation/widgets/instrument_search_delegate.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/transaction_history_view.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/dashboard_view.dart';

import 'package:fintech_session_guard/features/trade/presentation/widgets/trade_bottom_sheet.dart';

import 'package:fintech_session_guard/core/presentation/widgets/responsive_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PortfolioBloc>()..add(const PortfolioSummaryRequested()),
      child: Builder(
        builder: (context) {
          return ResponsiveScaffold(
            title: _currentIndex == 2 ? 'Transaction History' : 'My Portfolio',
            currentIndex: _currentIndex,
            onIndexChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            onSearchTapped: () async {
              final selected = await showSearch(
                context: context,
                delegate: InstrumentSearchDelegate(),
              );

              if (selected != null && context.mounted) {
                final portfolioBloc = context.read<PortfolioBloc>();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (bottomSheetContext) => BlocProvider.value(
                    value: portfolioBloc,
                    child: TradeBottomSheet(
                      ticker: selected.ticker,
                      assetName: selected.name,
                      currentPrice: selected.currentPrice,
                    ),
                  ),
                );
              }
            },
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
            ],
            body: _currentIndex == 2
                ? const TransactionHistoryView()
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<PortfolioBloc>().add(
                        const PortfolioRefreshed(),
                      );
                    },
                    child: DashboardView(
                      onHistoryTapped: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
