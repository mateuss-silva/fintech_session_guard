import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/security/session_monitor.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc manages authentication state across the app.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;
  final SessionMonitor _sessionMonitor;
  StreamSubscription<void>? _sessionSubscription;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required AuthRepository authRepository,
    required SecureStorageService secureStorage,
    required SessionMonitor sessionMonitor,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _authRepository = authRepository,
       _secureStorage = secureStorage,
       _sessionMonitor = sessionMonitor,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    _sessionSubscription = _sessionMonitor.onSessionExpired.listen((_) {
      add(const AuthSessionExpired());
    });
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasTokens = await _authRepository.isAuthenticated();
    if (!hasTokens) return emit(const AuthUnauthenticated());

    final email = await _secureStorage.getUserEmail();
    final name = await _secureStorage.getUserName();
    final userId = await _secureStorage.getUserId();

    if (email != null && name != null && userId != null) {
      emit(AuthAuthenticated(UserEntity(id: userId, email: email, name: name)));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
        deviceId: event.deviceId,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (tokens) => emit(AuthAuthenticated(tokens.user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(
        const AuthRegistered('Account created successfully! Please login.'),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _secureStorage.clearAll();
    emit(
      const AuthUnauthenticated(
        message: 'Your session has expired. Please login again.',
      ),
    );
  }
}
