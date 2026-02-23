import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/get_portfolio_summary_usecase.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/wallet_usecases.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/watchlist_usecases.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/stream_portfolio_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/features/home/domain/entities/portfolio_summary_entity.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetPortfolioSummaryUseCase _getPortfolioSummaryUseCase;
  final DepositUseCase _depositUseCase;
  final WithdrawUseCase _withdrawUseCase;
  final PreviewWithdrawUseCase _previewWithdrawUseCase;
  final GetTransactionHistoryUseCase _getTransactionHistoryUseCase;
  final GetWatchlistUseCase _getWatchlistUseCase;
  final AddTickerUseCase _addTickerUseCase;
  final RemoveTickerUseCase _removeTickerUseCase;

  final StreamPortfolioUseCase _streamPortfolioUseCase;
  List<String> _currentWatchlist = [];
  StreamSubscription<Either<Failure, PortfolioSummaryEntity>>?
  _portfolioSubscription;

  PortfolioBloc({
    required GetPortfolioSummaryUseCase getPortfolioSummaryUseCase,
    required DepositUseCase depositUseCase,
    required WithdrawUseCase withdrawUseCase,
    required PreviewWithdrawUseCase previewWithdrawUseCase,
    required GetTransactionHistoryUseCase getTransactionHistoryUseCase,
    required GetWatchlistUseCase getWatchlistUseCase,
    required AddTickerUseCase addTickerUseCase,
    required RemoveTickerUseCase removeTickerUseCase,
    required StreamPortfolioUseCase streamPortfolioUseCase,
  }) : _getPortfolioSummaryUseCase = getPortfolioSummaryUseCase,
       _depositUseCase = depositUseCase,
       _withdrawUseCase = withdrawUseCase,
       _previewWithdrawUseCase = previewWithdrawUseCase,
       _getTransactionHistoryUseCase = getTransactionHistoryUseCase,
       _getWatchlistUseCase = getWatchlistUseCase,
       _addTickerUseCase = addTickerUseCase,
       _removeTickerUseCase = removeTickerUseCase,
       _streamPortfolioUseCase = streamPortfolioUseCase,
       super(const PortfolioInitial()) {
    on<PortfolioSummaryRequested>(_onSummaryRequested);
    on<PortfolioStreamUpdated>(_onStreamUpdated);
    on<PortfolioRefreshed>(_onRefreshed);
    on<WalletDepositRequested>(_onDepositRequested);
    on<WalletWithdrawRequested>(_onWithdrawRequested);
    on<WalletWithdrawConfirmed>(_onWithdrawConfirmed);
    on<TransactionHistoryRequested>(_onTransactionHistoryRequested);
    on<WatchlistAdded>(_onWatchlistAdded);
    on<WatchlistRemoved>(_onWatchlistRemoved);
  }

  Future<void> _onSummaryRequested(
    PortfolioSummaryRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());

    // Load initial watchlist to have it ready for the stream
    final watchlistResult = await _getWatchlistUseCase();
    watchlistResult.fold(
      (_) => _currentWatchlist = [],
      (list) => _currentWatchlist = list,
    );

    await _portfolioSubscription?.cancel();
    _portfolioSubscription = _streamPortfolioUseCase(_currentWatchlist).listen(
      (result) => add(PortfolioStreamUpdated(result)),
      onError: (error) => add(
        PortfolioStreamUpdated(Left(ServerFailure(message: error.toString()))),
      ),
    );
  }

  void _onStreamUpdated(
    PortfolioStreamUpdated event,
    Emitter<PortfolioState> emit,
  ) {
    event.result.fold(
      (failure) => emit(PortfolioError(_mapFailureToMessage(failure))),
      (portfolio) =>
          emit(PortfolioLoaded(portfolio, watchlist: _currentWatchlist)),
    );
  }

  @override
  Future<void> close() {
    _portfolioSubscription?.cancel();
    return super.close();
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
    if (!_currentWatchlist.contains(event.ticker)) {
      _currentWatchlist.add(event.ticker);
    }
    await _portfolioSubscription?.cancel();
    _portfolioSubscription = _streamPortfolioUseCase(_currentWatchlist).listen(
      (result) => add(PortfolioStreamUpdated(result)),
      onError: (error) => add(
        PortfolioStreamUpdated(Left(ServerFailure(message: error.toString()))),
      ),
    );
  }

  Future<void> _onWatchlistRemoved(
    WatchlistRemoved event,
    Emitter<PortfolioState> emit,
  ) async {
    await _removeTickerUseCase(event.ticker);
    _currentWatchlist.remove(event.ticker);
    await _portfolioSubscription?.cancel();
    _portfolioSubscription = _streamPortfolioUseCase(_currentWatchlist).listen(
      (result) => add(PortfolioStreamUpdated(result)),
      onError: (error) => add(
        PortfolioStreamUpdated(Left(ServerFailure(message: error.toString()))),
      ),
    );
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
        // Stream automatically updates the balance, no need to manually fetch.
      },
    );
  }

  Future<void> _onWithdrawRequested(
    WalletWithdrawRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const WalletTransactionInProgress());

    final previewResult = await _previewWithdrawUseCase(event.amount);

    await previewResult.fold(
      (failure) async {
        emit(WalletTransactionFailure(_mapFailureToMessage(failure)));
      },
      (preview) async {
        if (preview.requiresLiquidation) {
          emit(WalletLiquidationRequired(event.amount, preview.assetsToSell));
        } else {
          // Perform withdraw directly if no liquidation needed
          final withdrawResult = await _withdrawUseCase(event.amount);
          withdrawResult.fold(
            (failure) =>
                emit(WalletTransactionFailure(_mapFailureToMessage(failure))),
            (_) =>
                emit(const WalletTransactionSuccess('Withdrawal successful')),
          );
        }
      },
    );
  }

  Future<void> _onWithdrawConfirmed(
    WalletWithdrawConfirmed event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const WalletTransactionInProgress());
    final withdrawResult = await _withdrawUseCase(event.amount);

    withdrawResult.fold(
      (failure) =>
          emit(WalletTransactionFailure(_mapFailureToMessage(failure))),
      (_) => emit(const WalletTransactionSuccess('Withdrawal successful')),
    );
  }

  Future<void> _onTransactionHistoryRequested(
    TransactionHistoryRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const TransactionHistoryLoading());

    final result = await _getTransactionHistoryUseCase(
      limit: event.limit,
      offset: event.offset,
      type: event.type,
    );

    result.fold(
      (failure) => emit(TransactionHistoryError(_mapFailureToMessage(failure))),
      (transactions) => emit(TransactionHistoryLoaded(transactions)),
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
              emit(PortfolioLoaded(portfolio, watchlist: _currentWatchlist)),
          (watchlist) {
            _currentWatchlist = watchlist;
            emit(PortfolioLoaded(portfolio, watchlist: watchlist));
          },
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
