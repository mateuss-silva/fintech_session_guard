import 'package:fintech_session_guard/features/home/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.type,
    super.assetName,
    super.ticker,
    required super.amount,
    super.quantity,
    super.priceAtExecution,
    required super.status,
    required super.biometricVerified,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      assetName: json['asset_name'] as String?,
      ticker: json['ticker'] as String?,
      amount: (json['amount'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      priceAtExecution: (json['price_at_execution'] as num?)?.toDouble(),
      status: json['status'] as String,
      biometricVerified:
          json['biometric_verified'] == 1 || json['biometric_verified'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
