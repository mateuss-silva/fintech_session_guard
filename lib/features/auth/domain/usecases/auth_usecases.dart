import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Logout use case — invalidates current session.
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.logout();
}

/// Check if the user has a PIN configured.
class GetPinStatusUseCase {
  final AuthRepository repository;

  const GetPinStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call() => repository.getPinStatus();
}

/// Set the user's 4-digit PIN.
class SetPinUseCase {
  final AuthRepository repository;

  const SetPinUseCase(this.repository);

  Future<Either<Failure, void>> call(String pin) => repository.setPin(pin);
}
