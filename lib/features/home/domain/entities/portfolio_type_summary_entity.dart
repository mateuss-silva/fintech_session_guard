import 'package:equatable/equatable.dart';

class PortfolioTypeSummaryEntity extends Equatable {
  final String type;
  final double invested;
  final double current;
  final int assetCount;

  const PortfolioTypeSummaryEntity({
    required this.type,
    required this.invested,
    required this.current,
    required this.assetCount,
  });

  @override
  List<Object?> get props => [type, invested, current, assetCount];
}
