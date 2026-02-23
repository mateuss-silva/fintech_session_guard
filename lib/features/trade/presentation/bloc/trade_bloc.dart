import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_session_guard/features/trade/domain/repositories/trade_repository.dart';
import 'package:fintech_session_guard/features/trade/presentation/bloc/trade_event.dart';
import 'package:fintech_session_guard/features/trade/presentation/bloc/trade_state.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final TradeRepository tradeRepository;

  TradeBloc({required this.tradeRepository}) : super(TradeInitial()) {
    on<TradeBuyRequested>(_onTradeBuyRequested);
    on<TradeSellRequested>(_onTradeSellRequested);
  }

  Future<void> _onTradeBuyRequested(
    TradeBuyRequested event,
    Emitter<TradeState> emit,
  ) async {
    emit(TradeLoading());
    final result = await tradeRepository.buyAsset(
      ticker: event.ticker,
      quantity: event.quantity,
      pin: event.pin,
      biometricToken: event.biometricToken,
    );

    result.fold(
      (failure) {
        if ((failure.message.contains('PIN') ||
                failure.message.contains('biometric')) &&
            failure.message != 'Invalid PIN') {
          emit(
            TradeAuthRequired(
              ticker: event.ticker,
              quantity: event.quantity,
              isBuy: true,
              message: failure.message,
            ),
          );
        } else {
          emit(TradeFailure(message: failure.message));
        }
      },
      (_) => emit(
        const TradeSuccess(
          message: 'Buy order executed successfully!',
          isBuy: true,
        ),
      ),
    );
  }

  Future<void> _onTradeSellRequested(
    TradeSellRequested event,
    Emitter<TradeState> emit,
  ) async {
    emit(TradeLoading());
    final result = await tradeRepository.sellAsset(
      ticker: event.ticker,
      quantity: event.quantity,
      pin: event.pin,
      biometricToken: event.biometricToken,
    );

    result.fold(
      (failure) {
        if ((failure.message.contains('PIN') ||
                failure.message.contains('biometric')) &&
            failure.message != 'Invalid PIN') {
          emit(
            TradeAuthRequired(
              ticker: event.ticker,
              quantity: event.quantity,
              isBuy: false,
              message: failure.message,
            ),
          );
        } else {
          emit(TradeFailure(message: failure.message));
        }
      },
      (_) => emit(
        const TradeSuccess(
          message: 'Sell order executed successfully!',
          isBuy: false,
        ),
      ),
    );
  }
}
