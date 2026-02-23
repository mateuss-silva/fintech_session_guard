import 'package:dartz/dartz.dart';
import 'package:fintech_session_guard/core/error/failures.dart';

abstract class TradeRepository {
  /// Executes a buy order for the given [ticker] and [quantity].
  /// Requires user authentication via [pin] or [biometricToken].
  Future<Either<Failure, void>> buyAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  });

  /// Executes a sell order for the given [ticker] and [quantity].
  /// Requires user authentication via [pin] or [biometricToken].
  Future<Either<Failure, void>> sellAsset({
    required String ticker,
    required double quantity,
    String? pin,
    String? biometricToken,
  });
}
