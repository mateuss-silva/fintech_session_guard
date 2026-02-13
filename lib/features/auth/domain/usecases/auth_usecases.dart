import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_tokens_entity.dart';
import '../repositories/auth_repository.dart';

/// Login use case — authenticates user with email and password.
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, AuthTokensEntity>> call({
    required String email,
    required String password,
    String? deviceId,
  }) {
    return repository.login(
      email: email,
      password: password,
      deviceId: deviceId,
    );
  }
}

/// Register use case — creates a new user account.
class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.register(email: email, password: password, name: name);
  }
}

/// Logout use case — invalidates current session.
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.logout();
}
