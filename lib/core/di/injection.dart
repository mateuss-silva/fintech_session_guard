import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../security/secure_storage_service.dart';
import '../security/session_monitor.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/home/data/datasources/asset_price_service.dart';
import '../../features/home/data/datasources/rx_asset_price_service_factory.dart';
import '../../features/home/data/datasources/portfolio_remote_data_source.dart';
import '../../features/home/data/repositories/portfolio_repository_impl.dart';
import '../../features/home/domain/repositories/portfolio_repository.dart';
import '../../features/home/domain/usecases/get_portfolio_summary_usecase.dart';
import '../../features/home/presentation/bloc/portfolio_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initialize all dependencies following the dependency rule:
/// External → Core → Data → Domain → Presentation
Future<void> initDependencies() async {
  // ───────────────────────────────────────────────────────────
  // Core Services (Singletons)
  // ───────────────────────────────────────────────────────────
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

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
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

  // Repository
  sl.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(
      remoteDataSource: sl<PortfolioRemoteDataSource>(),
      priceService: sl<AssetPriceService>(),
    ),
  );

  // Use Case
  sl.registerLazySingleton<GetPortfolioSummaryUseCase>(
    () => GetPortfolioSummaryUseCase(sl<PortfolioRepository>()),
  );

  // Bloc
  sl.registerFactory<PortfolioBloc>(
    () => PortfolioBloc(
      getPortfolioSummaryUseCase: sl<GetPortfolioSummaryUseCase>(),
    ),
  );
}
