import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String type; // buy, sell, deposit, withdraw, transfer, redeem
  final String? assetName;
  final String? ticker;
  final double amount;
  final double? quantity;
  final double? priceAtExecution;
  final String status;
  final bool biometricVerified;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    this.assetName,
    this.ticker,
    required this.amount,
    this.quantity,
    this.priceAtExecution,
    required this.status,
    required this.biometricVerified,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    assetName,
    ticker,
    amount,
    quantity,
    priceAtExecution,
    status,
    biometricVerified,
    createdAt,
  ];
}
