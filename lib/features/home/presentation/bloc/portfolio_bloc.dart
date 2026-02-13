import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/get_portfolio_summary_usecase.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetPortfolioSummaryUseCase _getPortfolioSummaryUseCase;

  PortfolioBloc({
    required GetPortfolioSummaryUseCase getPortfolioSummaryUseCase,
  }) : _getPortfolioSummaryUseCase = getPortfolioSummaryUseCase,
       super(const PortfolioInitial()) {
    on<PortfolioSummaryRequested>(_onSummaryRequested);
    on<PortfolioRefreshed>(_onRefreshed);
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
    // Don't emit loading on refresh to keep UI stable
    await _fetchPortfolio(emit);
  }

  Future<void> _fetchPortfolio(Emitter<PortfolioState> emit) async {
    final result = await _getPortfolioSummaryUseCase();

    result.fold(
      (failure) => emit(PortfolioError(_mapFailureToMessage(failure))),
      (portfolio) => emit(PortfolioLoaded(portfolio)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Failure: Unable to fetch portfolio.';
    } else if (failure is NetworkFailure) {
      return 'Network Failure: Please check your internet connection.';
    } else if (failure is SessionExpiredFailure) {
      return 'Session Expired: Please login again.';
    } else {
      return 'Unexpected Error';
    }
  }
}
