import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_session_guard/core/constants/api_constants.dart';
import 'package:fintech_session_guard/core/error/exceptions.dart';
import 'package:fintech_session_guard/core/network/api_client.dart';
import 'package:fintech_session_guard/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fintech_session_guard/features/auth/data/models/session_model.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late AuthRemoteDataSource dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = AuthRemoteDataSource(mockApiClient);
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tDeviceId = 'device-123';
    final tResponseData = {
      'accessToken': 'access',
      'refreshToken': 'refresh',
      'user': {'id': '1', 'email': tEmail, 'name': 'Test'},
    };

    test('should return response data when successful', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.login),
        ),
      );

      // act
      final result = await dataSource.login(
        email: tEmail,
        password: tPassword,
        deviceId: tDeviceId,
      );

      // assert
      expect(result, tResponseData);
      verify(
        () => mockDio.post(
          ApiConstants.login,
          data: {'email': tEmail, 'password': tPassword, 'deviceId': tDeviceId},
        ),
      ).called(1);
    });

    test('should throw UnauthorizedException on 401', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Invalid credentials', 'error': 'UNAUTHORIZED'},
            statusCode: 401,
            requestOptions: RequestOptions(path: ApiConstants.login),
          ),
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: ApiConstants.login),
        ),
      );

      // act
      final call = dataSource.login(email: tEmail, password: tPassword);

      // assert
      expect(() => call, throwsA(isA<UnauthorizedException>()));
    });

    test(
      'should throw SessionExpiredException on 401 with SESSION_EXPIRED',
      () async {
        // arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            response: Response(
              data: {'message': 'Session expired', 'error': 'SESSION_EXPIRED'},
              statusCode: 401,
              requestOptions: RequestOptions(path: ApiConstants.login),
            ),
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ApiConstants.login),
          ),
        );

        // act
        final call = dataSource.login(email: tEmail, password: tPassword);

        // assert
        expect(() => call, throwsA(isA<SessionExpiredException>()));
      },
    );
  });

  group('register', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tName = 'Test User';
    final tResponseData = {'userId': 'user-123'};

    test('should return userId when successful', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tResponseData,
          statusCode: 201,
          requestOptions: RequestOptions(path: ApiConstants.register),
        ),
      );

      // act
      final result = await dataSource.register(
        email: tEmail,
        password: tPassword,
        name: tName,
      );

      // assert
      expect(result, 'user-123');
      verify(
        () => mockDio.post(
          ApiConstants.register,
          data: {'email': tEmail, 'password': tPassword, 'name': tName},
        ),
      ).called(1);
    });
  });

  group('getSessions', () {
    final tSessions = [
      {
        'id': '1',
        'device_id': 'd1',
        'last_activity': '2023-01-01T00:00:00Z',
        'created_at': '2023-01-01T00:00:00Z',
      },
    ];
    final tResponseData = {'sessions': tSessions};

    test('should return list of SessionModel when successful', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.sessions),
        ),
      );

      // act
      final result = await dataSource.getSessions();

      // assert
      expect(result, isA<List<SessionModel>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
    });
  });
}
