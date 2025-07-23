import 'package:equatable/equatable.dart';
import '../../domain/entities/bco_ranking_entity.dart';

abstract class BcoRankingState extends Equatable {
  const BcoRankingState();
  @override
  List<Object?> get props => [];
}

class BcoRankingInitial extends BcoRankingState {}

class BcoRankingLoading extends BcoRankingState {}

class BcoRankingLoaded extends BcoRankingState {
  final List<BcoRankingEntity> rankings;
  const BcoRankingLoaded(this.rankings);
  @override
  List<Object?> get props => [rankings];
}

class BcoRankingError extends BcoRankingState {
  final String message;
  const BcoRankingError(this.message);
  @override
  List<Object?> get props => [message];
}
