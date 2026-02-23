import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? deviceId;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    this.deviceId,
  });

  @override
  List<Object?> get props => [email, password, deviceId];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

class AuthPinStatusRequested extends AuthEvent {
  const AuthPinStatusRequested();
}

class AuthSetPinRequested extends AuthEvent {
  final String pin;

  const AuthSetPinRequested(this.pin);

  @override
  List<Object?> get props => [pin];
}
