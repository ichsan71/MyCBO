import 'package:equatable/equatable.dart';

abstract class MemberKpiRankingEvent extends Equatable {
  const MemberKpiRankingEvent();
  @override
  List<Object?> get props => [];
}

class FetchMemberKpiRanking extends MemberKpiRankingEvent {
  final int bcoId;
  final String year;
  final String month;
  const FetchMemberKpiRanking(
      {required this.bcoId, required this.year, required this.month});

  @override
  List<Object?> get props => [bcoId, year, month];
}
