import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_history_entity.dart';
import 'package:fintech_session_guard/features/market/domain/repositories/market_repository.dart';

class GetInstrumentHistoryUseCase {
  final MarketRepository _repository;

  GetInstrumentHistoryUseCase(this._repository);

  Future<Either<Failure, InstrumentHistoryEntity>> call({
    required String instrumentId,
    required String range,
  }) {
    return _repository.getInstrumentHistory(
      instrumentId: instrumentId,
      range: range,
    );
  }
}
