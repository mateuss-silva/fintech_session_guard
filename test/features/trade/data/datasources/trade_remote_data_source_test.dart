import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_session_guard/core/constants/api_constants.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/features/trade/data/datasources/trade_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late TradeRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = TradeRemoteDataSourceImpl(mockApiClient);
  });

  group('TradeRemoteDataSource', () {
    const tTicker = 'AAPL';
    const tQuantity = 10.5;
    const tPin = '1234';

    test('buyAsset should complete successfully on status 200', () async {
      // arrange
      when(
        () => mockDio.post(ApiConstants.tradeBuy, data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.tradeBuy),
          statusCode: 200,
          data: {'message': 'Buy successful'},
        ),
      );

      // act
      final call = dataSource.buyAsset;

      // assert
      expect(
        () => call(ticker: tTicker, quantity: tQuantity, pin: tPin),
        returnsNormally,
      );
      verify(
        () => mockDio.post(
          ApiConstants.tradeBuy,
          data: {'ticker': tTicker, 'quantity': tQuantity, 'pin': tPin},
        ),
      ).called(1);
    });

    test('buyAsset should throw UnauthorizedException on AUTH_ERROR', () async {
      // arrange
      when(
        () => mockDio.post(ApiConstants.tradeBuy, data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.tradeBuy),
          response: Response(
            requestOptions: RequestOptions(path: ApiConstants.tradeBuy),
            statusCode: 400,
            data: {'error': 'AUTH_ERROR', 'message': 'Invalid PIN'},
          ),
        ),
      );

      // act
      final call = dataSource.buyAsset;

      // assert
      expect(
        () => call(ticker: tTicker, quantity: tQuantity, pin: 'wrong'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('sellAsset should complete successfully on status 200', () async {
      // arrange
      when(
        () => mockDio.post(ApiConstants.tradeSell, data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.tradeSell),
          statusCode: 200,
          data: {'message': 'Sell successful'},
        ),
      );

      // act
      final call = dataSource.sellAsset;

      // assert
      expect(
        () => call(ticker: tTicker, quantity: tQuantity, pin: tPin),
        returnsNormally,
      );
      verify(
        () => mockDio.post(
          ApiConstants.tradeSell,
          data: {'ticker': tTicker, 'quantity': tQuantity, 'pin': tPin},
        ),
      ).called(1);
    });

    test(
      'sellAsset should throw ServerException when server returns 500',
      () async {
        // arrange
        when(
          () => mockDio.post(ApiConstants.tradeSell, data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiConstants.tradeSell),
            response: Response(
              requestOptions: RequestOptions(path: ApiConstants.tradeSell),
              statusCode: 500,
            ),
            message: 'Internal Server Error',
          ),
        );

        // act
        final call = dataSource.sellAsset;

        // assert
        expect(
          () => call(ticker: tTicker, quantity: tQuantity),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
