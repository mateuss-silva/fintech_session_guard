import 'package:equatable/equatable.dart';

import 'user_entity.dart';

/// Authentication tokens and user data returned from login/register.
class AuthTokensEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
