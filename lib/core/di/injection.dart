import 'package:get_it/get_it.dart';

import '../../features/trade/data/datasources/trade_remote_data_source.dart';
import '../../features/trade/data/repositories/trade_repository_impl.dart';
import '../../features/trade/domain/repositories/trade_repository.dart';
import '../../features/trade/presentation/bloc/trade_bloc.dart';

import '../network/api_client.dart';
import '../security/secure_storage_service.dart';
import '../security/session_monitor.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/market/data/datasources/market_remote_data_source.dart';
import '../../features/market/data/repositories/market_repository_impl.dart';
import '../../features/market/domain/repositories/market_repository.dart';
import '../../features/market/domain/usecases/search_instruments_usecase.dart';
import '../../features/market/presentation/bloc/market_bloc.dart';

import '../../features/home/data/datasources/asset_price_service.dart';
import '../../features/home/data/datasources/rx_asset_price_service_factory.dart';
import '../../features/home/data/datasources/portfolio_remote_data_source.dart';
import '../../features/home/data/repositories/portfolio_repository_impl.dart';
import '../../features/home/domain/repositories/portfolio_repository.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/get_portfolio_summary_usecase.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/stream_portfolio_usecase.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/wallet_usecases.dart';
import 'package:fintech_session_guard/features/home/domain/usecases/watchlist_usecases.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintech_session_guard/features/home/data/datasources/watchlist_local_data_source.dart';
import 'package:fintech_session_guard/features/home/data/datasources/portfolio_stream_service.dart';
import 'package:fintech_session_guard/features/home/data/datasources/rx_portfolio_service_factory.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initialize all dependencies following the dependency rule:
/// External → Core → Data → Domain → Presentation
Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // ───────────────────────────────────────────────────────────
  // Core Services (Singletons)
  // ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(secureStorage: sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<SessionMonitor>(() => SessionMonitor());

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // UseCases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetPinStatusUseCase>(
    () => GetPinStatusUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SetPinUseCase>(
    () => SetPinUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      getPinStatusUseCase: sl<GetPinStatusUseCase>(),
      setPinUseCase: sl<SetPinUseCase>(),
      authRepository: sl<AuthRepository>(),
      secureStorage: sl<SecureStorageService>(),
      sessionMonitor: sl<SessionMonitor>(),
    ),
  );

  // ───────────────────────────────────────────────────────────
  // Feature: Portfolio
  // ───────────────────────────────────────────────────────────

  // Data Source
  sl.registerLazySingleton<PortfolioRemoteDataSource>(
    () => PortfolioRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AssetPriceService>(
    () => RxAssetPriceServiceFactory.create(sl<ApiClient>()),
  );

  sl.registerLazySingleton<PortfolioStreamService>(
    () => RxPortfolioServiceFactory.create(
      sl<ApiClient>(),
      sl<SecureStorageService>(),
    ),
  );

  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(
      remoteDataSource: sl<PortfolioRemoteDataSource>(),
      priceService: sl<AssetPriceService>(),
      localDataSource: sl<WatchlistLocalDataSource>(),
      portfolioStreamService: sl<PortfolioStreamService>(),
    ),
  );

  // Use Case
  sl.registerLazySingleton<GetPortfolioSummaryUseCase>(
    () => GetPortfolioSummaryUseCase(sl<PortfolioRepository>()),
  );

  sl.registerLazySingleton<StreamPortfolioUseCase>(
    () => StreamPortfolioUseCase(sl<PortfolioRepository>()),
  );

  sl.registerLazySingleton<DepositUseCase>(
    () => DepositUseCase(sl<PortfolioRepository>()),
  );
  sl.registerLazySingleton<WithdrawUseCase>(
    () => WithdrawUseCase(sl<PortfolioRepository>()),
  );
  sl.registerLazySingleton<PreviewWithdrawUseCase>(
    () => PreviewWithdrawUseCase(sl<PortfolioRepository>()),
  );
  sl.registerLazySingleton<GetTransactionHistoryUseCase>(
    () => GetTransactionHistoryUseCase(sl<PortfolioRepository>()),
  );

  sl.registerLazySingleton<GetWatchlistUseCase>(
    () => GetWatchlistUseCase(sl<PortfolioRepository>()),
  );
  sl.registerLazySingleton<AddTickerUseCase>(
    () => AddTickerUseCase(sl<PortfolioRepository>()),
  );
  sl.registerLazySingleton<RemoveTickerUseCase>(
    () => RemoveTickerUseCase(sl<PortfolioRepository>()),
  );

  // Bloc
  sl.registerFactory<PortfolioBloc>(
    () => PortfolioBloc(
      streamPortfolioUseCase: sl<StreamPortfolioUseCase>(),
      getPortfolioSummaryUseCase: sl<GetPortfolioSummaryUseCase>(),
      depositUseCase: sl<DepositUseCase>(),
      withdrawUseCase: sl<WithdrawUseCase>(),
      previewWithdrawUseCase: sl<PreviewWithdrawUseCase>(),
      getTransactionHistoryUseCase: sl<GetTransactionHistoryUseCase>(),
      getWatchlistUseCase: sl<GetWatchlistUseCase>(),
      addTickerUseCase: sl<AddTickerUseCase>(),
      removeTickerUseCase: sl<RemoveTickerUseCase>(),
    ),
  );

  // ───────────────────────────────────────────────────────────
  // Feature: Market
  // ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<MarketRemoteDataSource>(
    () => MarketRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(remoteDataSource: sl<MarketRemoteDataSource>()),
  );

  sl.registerLazySingleton<SearchInstrumentsUseCase>(
    () => SearchInstrumentsUseCase(sl<MarketRepository>()),
  );

  sl.registerFactory<MarketBloc>(
    () => MarketBloc(searchInstrumentsUseCase: sl<SearchInstrumentsUseCase>()),
  );

  // ───────────────────────────────────────────────────────────
  // Feature: Trade
  // ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<TradeRemoteDataSource>(
    () => TradeRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<TradeRepository>(
    () => TradeRepositoryImpl(remoteDataSource: sl<TradeRemoteDataSource>()),
  );

  sl.registerFactory<TradeBloc>(
    () => TradeBloc(tradeRepository: sl<TradeRepository>()),
  );
}
