import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_bloc.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_event.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_state.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';
import 'package:fintech_session_guard/core/di/injection.dart';

class InstrumentSearchDelegate extends SearchDelegate<InstrumentEntity?> {
  final MarketBloc marketBloc = sl<MarketBloc>();
  final PortfolioBloc portfolioBloc;
  final bool hasPinConfigured;

  InstrumentSearchDelegate({
    required this.portfolioBloc,
    this.hasPinConfigured = true,
  }) : super(searchFieldLabel: 'Search for assets (e.g. PETR4)');

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text(
          'Type a ticker or name to search',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Dispatch the search event
    marketBloc.add(SearchInstrumentsEvent(query: query));

    return BlocProvider.value(
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
                  'No instruments found matching your search',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return BlocBuilder<PortfolioBloc, PortfolioState>(
              bloc: portfolioBloc,
              builder: (context, portfolioState) {
                List<String> watchlist = [];
                if (portfolioState is PortfolioLoaded) {
                  watchlist = portfolioState.watchlist;
                }

                return ListView.separated(
                  itemCount: instruments.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.cardBorder, height: 1),
                  itemBuilder: (context, index) {
                    final instrument = instruments[index];
                    final isSaved = watchlist.contains(instrument.ticker);

                    return ListTile(
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
                        instrument.name,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$ ${instrument.currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${instrument.changePercent >= 0 ? '+' : ''}${instrument.changePercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: instrument.changePercent >= 0
                                      ? AppColors.profit
                                      : AppColors.loss,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                                portfolioBloc.add(
                                  WatchlistRemoved(instrument.ticker),
                                );
                              } else {
                                portfolioBloc.add(
                                  WatchlistAdded(instrument.ticker),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        close(context, null);
                        context.push(
                          '/instrument/${instrument.id}',
                          extra: {
                            'instrument': instrument,
                            'hasPinConfigured': hasPinConfigured,
                            'portfolioBloc': portfolioBloc,
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
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      // Let's do an empty search to load popular/default instruments
      marketBloc.add(const SearchInstrumentsEvent(query: ''));
    } else {
      // Real-time search while typing (optional, may hammer API if not debounced. But we'll do it for UX)
      marketBloc.add(SearchInstrumentsEvent(query: query));
    }

    return BlocProvider.value(
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
              bloc: portfolioBloc,
              builder: (context, portfolioState) {
                List<String> watchlist = [];
                if (portfolioState is PortfolioLoaded) {
                  watchlist = portfolioState.watchlist;
                }

                return ListView.separated(
                  itemCount: instruments.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.cardBorder, height: 1),
                  itemBuilder: (context, index) {
                    final instrument = instruments[index];
                    final isSaved = watchlist.contains(instrument.ticker);

                    return ListTile(
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
                        style: const TextStyle(color: AppColors.textSecondary),
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
                                portfolioBloc.add(
                                  WatchlistRemoved(instrument.ticker),
                                );
                              } else {
                                portfolioBloc.add(
                                  WatchlistAdded(instrument.ticker),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        close(context, null);
                        context.push(
                          '/instrument/${instrument.id}',
                          extra: {
                            'instrument': instrument,
                            'hasPinConfigured': hasPinConfigured,
                            'portfolioBloc': portfolioBloc,
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
    );
  }
}
