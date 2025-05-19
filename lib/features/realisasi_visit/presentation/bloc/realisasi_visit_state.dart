part of 'realisasi_visit_bloc.dart';

abstract class RealisasiVisitState extends Equatable {
  const RealisasiVisitState();

  @override
  List<Object> get props => [];
}

class RealisasiVisitInitial extends RealisasiVisitState {}

class RealisasiVisitLoading extends RealisasiVisitState {}

class RealisasiVisitLoaded extends RealisasiVisitState {
  final List<RealisasiVisit> realisasiVisits;

  const RealisasiVisitLoaded({required this.realisasiVisits});

  @override
  List<Object> get props => [realisasiVisits];
}

class RealisasiVisitError extends RealisasiVisitState {
  final String message;

  const RealisasiVisitError({required this.message});

  @override
  List<Object> get props => [message];
}

class RealisasiVisitProcessing extends RealisasiVisitState {}

class RealisasiVisitApproved extends RealisasiVisitState {
  final RealisasiVisitResponse response;

  const RealisasiVisitApproved({required this.response});

  @override
  List<Object> get props => [response];
}

class RealisasiVisitRejected extends RealisasiVisitState {
  final RealisasiVisitResponse response;

  const RealisasiVisitRejected({required this.response});

  @override
  List<Object> get props => [response];
}
