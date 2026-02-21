import 'package:equatable/equatable.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';

abstract class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final List<InstrumentEntity> instruments;

  const MarketLoaded({required this.instruments});

  @override
  List<Object?> get props => [instruments];
}

class MarketError extends MarketState {
  final String message;

  const MarketError({required this.message});

  @override
  List<Object?> get props => [message];
}
