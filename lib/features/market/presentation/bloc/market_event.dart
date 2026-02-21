import 'package:equatable/equatable.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

class SearchInstrumentsEvent extends MarketEvent {
  final String? query;
  final String? type;

  const SearchInstrumentsEvent({this.query, this.type});

  @override
  List<Object?> get props => [query, type];
}
