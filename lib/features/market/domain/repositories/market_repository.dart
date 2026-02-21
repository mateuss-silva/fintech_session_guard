import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<InstrumentEntity>>> searchInstruments({
    String? query,
    String? type,
  });
}
