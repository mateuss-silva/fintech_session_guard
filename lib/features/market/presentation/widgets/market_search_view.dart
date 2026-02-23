import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_bloc.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_event.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_state.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';
import 'package:fintech_session_guard/core/di/injection.dart';

class MarketSearchView extends StatefulWidget {
  final PortfolioBloc portfolioBloc;
  final bool hasPinConfigured;

  const MarketSearchView({
    super.key,
    required this.portfolioBloc,
    this.hasPinConfigured = true,
  });

  @override
  State<MarketSearchView> createState() => _MarketSearchViewState();
}

class _MarketSearchViewState extends State<MarketSearchView> {
  final MarketBloc marketBloc = sl<MarketBloc>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load popular instruments by default
    marketBloc.add(const SearchInstrumentsEvent(query: ''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    marketBloc.add(SearchInstrumentsEvent(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search for assets (e.g. PETR4)',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  return value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : const SizedBox.shrink();
                },
              ),
              filled: true,
              fillColor: AppColors.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocProvider.value(
            value: marketBloc,
            child: BlocBuilder<MarketBloc, MarketState>(
              builder: (context, state) {
                if (state is MarketLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MarketError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.loss),
                    ),
                  );
                } else if (state is MarketLoaded) {
                  final instruments = state.instruments;

                  if (instruments.isEmpty) {
                    return const Center(
                      child: Text(
                        'No instruments found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return BlocBuilder<PortfolioBloc, PortfolioState>(
                    bloc: widget.portfolioBloc,
                    builder: (context, portfolioState) {
                      List<String> watchlist = [];
                      if (portfolioState is PortfolioLoaded) {
                        watchlist = portfolioState.watchlist;
                      }

                      return ListView.separated(
                        itemCount: instruments.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        separatorBuilder: (context, index) => const Divider(
                          color: AppColors.cardBorder,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final instrument = instruments[index];
                          final isSaved = watchlist.contains(instrument.ticker);

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.cardColor,
                              child: Text(
                                instrument.ticker.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              instrument.ticker,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${instrument.name} • ${instrument.sector ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$ ${instrument.currentPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    isSaved ? Icons.star : Icons.star_border,
                                    color: isSaved
                                        ? Colors.amber
                                        : AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    if (isSaved) {
                                      widget.portfolioBloc.add(
                                        WatchlistRemoved(instrument.ticker),
                                      );
                                    } else {
                                      widget.portfolioBloc.add(
                                        WatchlistAdded(instrument.ticker),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              context.push(
                                '/instrument/${instrument.id}',
                                extra: {
                                  'instrument': instrument,
                                  'hasPinConfigured': widget.hasPinConfigured,
                                  'portfolioBloc': widget.portfolioBloc,
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: Text(
                    'Start typing to find assets',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
