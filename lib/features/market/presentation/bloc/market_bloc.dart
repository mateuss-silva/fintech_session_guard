import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/features/market/domain/usecases/search_instruments_usecase.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_event.dart';
import 'package:fintech_session_guard/features/market/presentation/bloc/market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final SearchInstrumentsUseCase searchInstrumentsUseCase;

  MarketBloc({required this.searchInstrumentsUseCase})
    : super(MarketInitial()) {
    on<SearchInstrumentsEvent>(_onSearchInstruments);
  }

  Future<void> _onSearchInstruments(
    SearchInstrumentsEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketLoading());

    final result = await searchInstrumentsUseCase(
      SearchInstrumentsParams(query: event.query, type: event.type),
    );

    result.fold(
      (failure) => emit(MarketError(message: failure.message)),
      (instruments) => emit(MarketLoaded(instruments: instruments)),
    );
  }
}
