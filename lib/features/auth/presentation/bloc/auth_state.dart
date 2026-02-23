import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthRegistered extends AuthState {
  final String message;

  const AuthRegistered(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPinStatusLoaded extends AuthState {
  final bool hasPinConfigured;

  const AuthPinStatusLoaded(this.hasPinConfigured);

  @override
  List<Object?> get props => [hasPinConfigured];
}

class AuthPinSetSuccess extends AuthState {
  const AuthPinSetSuccess();
}

class AuthPinSetFailure extends AuthState {
  final String message;

  const AuthPinSetFailure(this.message);

  @override
  List<Object?> get props => [message];
}
