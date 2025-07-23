import 'package:equatable/equatable.dart';

abstract class BcoRankingEvent extends Equatable {
  const BcoRankingEvent();
  @override
  List<Object?> get props => [];
}

class FetchBcoRanking extends BcoRankingEvent {
  final String token;
  final String year;
  final String month;
  const FetchBcoRanking(
      {required this.token, required this.year, required this.month});

  @override
  List<Object?> get props => [token, year, month];
}
