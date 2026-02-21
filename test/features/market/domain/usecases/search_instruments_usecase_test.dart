import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';
import 'package:fintech_session_guard/features/market/domain/repositories/market_repository.dart';
import 'package:fintech_session_guard/features/market/domain/usecases/search_instruments_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late SearchInstrumentsUseCase usecase;
  late MockMarketRepository mockRepository;

  setUp(() {
    mockRepository = MockMarketRepository();
    usecase = SearchInstrumentsUseCase(mockRepository);
  });

  const tInstrument = InstrumentEntity(
    id: '1',
    ticker: 'TEST3',
    name: 'Test Asset',
    type: 'acao',
    currentPrice: 100.0,
    open: 100.0,
    high: 100.0,
    low: 100.0,
    change: 0.0,
    changePercent: 0.0,
    timestamp: '2023-01-01T00:00:00Z',
  );

  final tInstruments = [tInstrument];
  const tQuery = 'TEST';

  test('should get instruments from the repository', () async {
    // arrange
    when(
      () => mockRepository.searchInstruments(query: tQuery, type: null),
    ).thenAnswer((_) async => Right(tInstruments));
    // act
    final result = await usecase(const SearchInstrumentsParams(query: tQuery));
    // assert
    expect(result, Right(tInstruments));
    verify(() => mockRepository.searchInstruments(query: tQuery, type: null));
    verifyNoMoreInteractions(mockRepository);
  });
}
