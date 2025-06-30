part of 'realisasi_visit_bloc.dart';

abstract class RealisasiVisitState extends Equatable {
  const RealisasiVisitState();

  @override
  List<Object?> get props => [];
}

class RealisasiVisitInitial extends RealisasiVisitState {}

class RealisasiVisitLoading extends RealisasiVisitState {}

class RealisasiVisitProcessing extends RealisasiVisitState {}

class RealisasiVisitLoaded extends RealisasiVisitState {
  final List<RealisasiVisit> realisasiVisits;

  const RealisasiVisitLoaded({required this.realisasiVisits});

  @override
  List<Object?> get props => [realisasiVisits];
}

class RealisasiVisitGMLoaded extends RealisasiVisitState {
  final List<RealisasiVisitGM> realisasiVisitsGM;

  const RealisasiVisitGMLoaded({required this.realisasiVisitsGM});

  @override
  List<Object?> get props => [realisasiVisitsGM];
}

class RealisasiVisitGMDetailsLoaded extends RealisasiVisitState {
  final List<RealisasiVisitGM> realisasiVisitsGM;

  const RealisasiVisitGMDetailsLoaded({required this.realisasiVisitsGM});

  @override
  List<Object?> get props => [realisasiVisitsGM];
}

class RealisasiVisitSuccess extends RealisasiVisitState {
  final String message;

  const RealisasiVisitSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class RealisasiVisitError extends RealisasiVisitState {
  final String message;

  const RealisasiVisitError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RealisasiVisitApproved extends RealisasiVisitState {
  final String message;

  const RealisasiVisitApproved({required this.message});

  @override
  List<Object?> get props => [message];
}

class RealisasiVisitRejected extends RealisasiVisitState {
  final String message;

  const RealisasiVisitRejected({required this.message});

  @override
  List<Object?> get props => [message];
}
