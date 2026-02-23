import 'package:equatable/equatable.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_history_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_instrument_history_usecase.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class InstrumentDetailEvent extends Equatable {
  const InstrumentDetailEvent();
  @override
  List<Object?> get props => [];
}

class InstrumentDetailRequested extends InstrumentDetailEvent {
  final String instrumentId;
  final String range;

  const InstrumentDetailRequested({
    required this.instrumentId,
    this.range = '1Y',
  });

  @override
  List<Object?> get props => [instrumentId, range];
}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class InstrumentDetailState extends Equatable {
  const InstrumentDetailState();
  @override
  List<Object?> get props => [];
}

class InstrumentDetailInitial extends InstrumentDetailState {}

class InstrumentDetailLoading extends InstrumentDetailState {}

class InstrumentDetailLoaded extends InstrumentDetailState {
  final InstrumentHistoryEntity history;
  final String selectedRange;

  const InstrumentDetailLoaded({
    required this.history,
    required this.selectedRange,
  });

  @override
  List<Object?> get props => [history, selectedRange];
}

class InstrumentDetailError extends InstrumentDetailState {
  final String message;

  const InstrumentDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Bloc ────────────────────────────────────────────────────────────────────
class InstrumentDetailBloc
    extends Bloc<InstrumentDetailEvent, InstrumentDetailState> {
  final GetInstrumentHistoryUseCase _getHistory;

  InstrumentDetailBloc({required GetInstrumentHistoryUseCase getHistory})
    : _getHistory = getHistory,
      super(InstrumentDetailInitial()) {
    on<InstrumentDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(
    InstrumentDetailRequested event,
    Emitter<InstrumentDetailState> emit,
  ) async {
    emit(InstrumentDetailLoading());
    final result = await _getHistory(
      instrumentId: event.instrumentId,
      range: event.range,
    );
    result.fold(
      (failure) => emit(InstrumentDetailError(failure.message)),
      (history) => emit(
        InstrumentDetailLoaded(history: history, selectedRange: event.range),
      ),
    );
  }
}
