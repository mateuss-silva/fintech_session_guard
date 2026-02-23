import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_bloc.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_event.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_state.dart';
import 'package:fintech_session_guard/core/di/injection.dart';

class InstrumentSearchDelegate extends SearchDelegate<InstrumentEntity?> {
  final MarketBloc marketBloc = sl<MarketBloc>();

  InstrumentSearchDelegate()
    : super(searchFieldLabel: 'Search for assets (e.g. PETR4)');

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

            return ListView.separated(
              itemCount: instruments.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.cardBorder, height: 1),
              itemBuilder: (context, index) {
                final instrument = instruments[index];
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
                  trailing: Column(
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
                  onTap: () {
                    // When tapped, we could close the search and pass back the selected instrument.
                    // For now, let's just show a simple snackbar or navigate if needed
                    close(context, instrument);
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

            return ListView.separated(
              itemCount: instruments.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.cardBorder, height: 1),
              itemBuilder: (context, index) {
                final instrument = instruments[index];
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
                  ), // Show sector in suggestion
                  trailing: Text(
                    '\$ ${instrument.currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    close(context, instrument);
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
