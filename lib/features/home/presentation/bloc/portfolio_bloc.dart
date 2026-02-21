import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/get_portfolio_summary_usecase.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/wallet_usecases.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/watchlist_usecases.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetPortfolioSummaryUseCase _getPortfolioSummaryUseCase;
  final DepositUseCase _depositUseCase;
  final WithdrawUseCase _withdrawUseCase;
  final GetWatchlistUseCase _getWatchlistUseCase;
  final AddTickerUseCase _addTickerUseCase;
  final RemoveTickerUseCase _removeTickerUseCase;

  PortfolioBloc({
    required GetPortfolioSummaryUseCase getPortfolioSummaryUseCase,
    required DepositUseCase depositUseCase,
    required WithdrawUseCase withdrawUseCase,
    required GetWatchlistUseCase getWatchlistUseCase,
    required AddTickerUseCase addTickerUseCase,
    required RemoveTickerUseCase removeTickerUseCase,
  }) : _getPortfolioSummaryUseCase = getPortfolioSummaryUseCase,
       _depositUseCase = depositUseCase,
       _withdrawUseCase = withdrawUseCase,
       _getWatchlistUseCase = getWatchlistUseCase,
       _addTickerUseCase = addTickerUseCase,
       _removeTickerUseCase = removeTickerUseCase,
       super(const PortfolioInitial()) {
    on<PortfolioSummaryRequested>(_onSummaryRequested);
    on<PortfolioRefreshed>(_onRefreshed);
    on<WalletDepositRequested>(_onDepositRequested);
    on<WalletWithdrawRequested>(_onWithdrawRequested);
    on<WatchlistAdded>(_onWatchlistAdded);
    on<WatchlistRemoved>(_onWatchlistRemoved);
  }

  Future<void> _onSummaryRequested(
    PortfolioSummaryRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    await _fetchPortfolio(emit);
  }

  Future<void> _onRefreshed(
    PortfolioRefreshed event,
    Emitter<PortfolioState> emit,
  ) async {
    await _fetchPortfolio(emit);
  }

  Future<void> _onWatchlistAdded(
    WatchlistAdded event,
    Emitter<PortfolioState> emit,
  ) async {
    await _addTickerUseCase(event.ticker);
    await _fetchPortfolio(emit);
  }

  Future<void> _onWatchlistRemoved(
    WatchlistRemoved event,
    Emitter<PortfolioState> emit,
  ) async {
    await _removeTickerUseCase(event.ticker);
    await _fetchPortfolio(emit);
  }

  Future<void> _onDepositRequested(
    WalletDepositRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const WalletTransactionInProgress());
    final result = await _depositUseCase(event.amount);

    result.fold(
      (failure) =>
          emit(WalletTransactionFailure(_mapFailureToMessage(failure))),
      (_) {
        emit(const WalletTransactionSuccess('Deposit successful'));
        add(const PortfolioSummaryRequested());
      },
    );
  }

  Future<void> _onWithdrawRequested(
    WalletWithdrawRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const WalletTransactionInProgress());
    final result = await _withdrawUseCase(event.amount);

    result.fold(
      (failure) =>
          emit(WalletTransactionFailure(_mapFailureToMessage(failure))),
      (_) {
        emit(const WalletTransactionSuccess('Withdrawal successful'));
        add(const PortfolioSummaryRequested());
      },
    );
  }

  Future<void> _fetchPortfolio(Emitter<PortfolioState> emit) async {
    final portfolioResult = await _getPortfolioSummaryUseCase();
    final watchlistResult = await _getWatchlistUseCase();

    portfolioResult.fold(
      (failure) => emit(PortfolioError(_mapFailureToMessage(failure))),
      (portfolio) {
        watchlistResult.fold(
          (failure) =>
              emit(PortfolioLoaded(portfolio)), // Render without if fails
          (watchlist) => emit(PortfolioLoaded(portfolio, watchlist: watchlist)),
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network Failure: Please check your internet connection.';
    } else if (failure is SessionExpiredFailure) {
      return 'Session Expired: Please login again.';
    } else {
      return 'Unexpected Error';
    }
  }
}
