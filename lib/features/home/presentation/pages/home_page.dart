import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_state.dart';
import 'package:fintech_session_guard/features/auth/presentation/widgets/pin_setup_dialog.dart';
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
  // null = still checking (no banner yet), false = no PIN (show banner), true = PIN ok
  bool? _hasPinConfigured;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    // Capture name from AuthAuthenticated before PIN sub-states replace it
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userName = authState.user.name.trim().split(' ').first;
    }
    // Request PIN status after first frame so AuthBloc is available in context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthPinStatusRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PortfolioBloc>()..add(const PortfolioSummaryRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            setState(() => _userName = state.user.name.trim().split(' ').first);
          } else if (state is AuthPinStatusLoaded) {
            setState(() => _hasPinConfigured = state.hasPinConfigured);
          } else if (state is AuthPinSetSuccess) {
            setState(() => _hasPinConfigured = true);
          }
        },
        child: Builder(
          builder: (context) {
            return ResponsiveScaffold(
              title: _currentIndex == 2
                  ? 'Transaction History'
                  : 'My Portfolio',
              currentIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              onSearchTapped: () async {
                final portfolioBloc = context.read<PortfolioBloc>();
                final selected = await showSearch(
                  context: context,
                  delegate: InstrumentSearchDelegate(
                    portfolioBloc: portfolioBloc,
                  ),
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
                        hasPinConfigured: _hasPinConfigured ?? true,
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
              banner: (_hasPinConfigured == false)
                  ? MaterialBanner(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      backgroundColor: const Color(0xFF7C4B00),
                      leading: const Icon(
                        Icons.lock_outline,
                        color: Colors.amber,
                      ),
                      content: const Text(
                        'Set up a PIN to unlock transactions.',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => PinSetupDialog.show(context),
                          child: const Text(
                            'SET PIN',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              body: _currentIndex == 2
                  ? const TransactionHistoryView()
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<PortfolioBloc>().add(
                          const PortfolioRefreshed(),
                        );
                      },
                      child: DashboardView(
                        hasPinConfigured: _hasPinConfigured ?? true,
                        userName: _userName,
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
      ),
    );
  }
}
