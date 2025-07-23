import 'package:equatable/equatable.dart';
import '../../domain/entities/member_kpi_entity.dart';

abstract class MemberKpiRankingState extends Equatable {
  const MemberKpiRankingState();
  @override
  List<Object?> get props => [];
}

class MemberKpiRankingInitial extends MemberKpiRankingState {}

class MemberKpiRankingLoading extends MemberKpiRankingState {}

class MemberKpiRankingLoaded extends MemberKpiRankingState {
  final List<MemberKpiEntity> members;
  const MemberKpiRankingLoaded(this.members);
  @override
  List<Object?> get props => [members];
}

class MemberKpiRankingError extends MemberKpiRankingState {
  final String message;
  const MemberKpiRankingError(this.message);
  @override
  List<Object?> get props => [message];
}
