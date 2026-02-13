/// Data-layer exceptions that get mapped to [Failure]s in repositories.
class ServerException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const ServerException({required this.message, this.code, this.statusCode});

  @override
  String toString() => 'ServerException($code: $message)';
}

class UnauthorizedException implements Exception {
  final String message;
  final String? code;

  const UnauthorizedException({this.message = 'Unauthorized', this.code});
}

class SessionExpiredException implements Exception {
  final String message;

  const SessionExpiredException({this.message = 'Session expired'});
}

class TokenReuseException implements Exception {
  final String message;

  const TokenReuseException({this.message = 'Token reuse detected'});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Network error'});
}
