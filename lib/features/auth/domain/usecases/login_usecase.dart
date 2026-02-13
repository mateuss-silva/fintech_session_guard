import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_tokens_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AuthTokensEntity>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
      deviceId: params.deviceId,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  final String? deviceId;

  const LoginParams({
    required this.email,
    required this.password,
    this.deviceId,
  });

  @override
  List<Object?> get props => [email, password, deviceId];
}
