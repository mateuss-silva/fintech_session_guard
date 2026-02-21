import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fintech_session_guard/core/error/failures.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';
import 'package:fintech_session_guard/features/market/domain/repositories/market_repository.dart';

class SearchInstrumentsUseCase {
  final MarketRepository repository;

  SearchInstrumentsUseCase(this.repository);

  Future<Either<Failure, List<InstrumentEntity>>> call(
    SearchInstrumentsParams params,
  ) async {
    return await repository.searchInstruments(
      query: params.query,
      type: params.type,
    );
  }
}

class SearchInstrumentsParams extends Equatable {
  final String? query;
  final String? type;

  const SearchInstrumentsParams({this.query, this.type});

  @override
  List<Object?> get props => [query, type];
}
