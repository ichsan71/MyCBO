part of 'realisasi_visit_bloc.dart';

abstract class RealisasiVisitEvent extends Equatable {
  const RealisasiVisitEvent();

  @override
  List<Object?> get props => [];
}

class GetRealisasiVisitsEvent extends RealisasiVisitEvent {
  final int idAtasan;

  const GetRealisasiVisitsEvent({required this.idAtasan});

  @override
  List<Object?> get props => [idAtasan];
}

class GetRealisasiVisitsGMEvent extends RealisasiVisitEvent {
  final int idAtasan;

  const GetRealisasiVisitsGMEvent({required this.idAtasan});

  @override
  List<Object?> get props => [idAtasan];
}

class GetRealisasiVisitsGMDetailsEvent extends RealisasiVisitEvent {
  final int idBCO;
  final int idAtasan;

  const GetRealisasiVisitsGMDetailsEvent({
    required this.idBCO,
    required this.idAtasan,
  });

  @override
  List<Object?> get props => [idBCO, idAtasan];
}

class ApproveRealisasiVisitEvent extends RealisasiVisitEvent {
  final int idRealisasiVisit;
  final int idUser;

  const ApproveRealisasiVisitEvent({
    required this.idRealisasiVisit,
    required this.idUser,
  });

  @override
  List<Object?> get props => [idRealisasiVisit, idUser];
}

class ApproveRealisasiVisitGMEvent extends RealisasiVisitEvent {
  final int idAtasan;
  final List<String> idSchedule;

  const ApproveRealisasiVisitGMEvent({
    required this.idAtasan,
    required this.idSchedule,
  });

  @override
  List<Object?> get props => [idAtasan, idSchedule];
}

class RejectRealisasiVisitEvent extends RealisasiVisitEvent {
  final int idRealisasiVisit;
  final int idUser;
  final String reason;

  const RejectRealisasiVisitEvent({
    required this.idRealisasiVisit,
    required this.idUser,
    required this.reason,
  });

  @override
  List<Object?> get props => [idRealisasiVisit, idUser, reason];
}
