part of 'realisasi_visit_bloc.dart';

abstract class RealisasiVisitEvent extends Equatable {
  const RealisasiVisitEvent();

  @override
  List<Object> get props => [];
}

class GetRealisasiVisitsEvent extends RealisasiVisitEvent {
  final int idAtasan;

  const GetRealisasiVisitsEvent({required this.idAtasan});

  @override
  List<Object> get props => [idAtasan];
}

class GetRealisasiVisitsGMEvent extends RealisasiVisitEvent {
  final int idAtasan;

  const GetRealisasiVisitsGMEvent({required this.idAtasan});

  @override
  List<Object> get props => [idAtasan];
}

class ApproveRealisasiVisitEvent extends RealisasiVisitEvent {
  final int idAtasan;
  final List<String> idSchedule;

  const ApproveRealisasiVisitEvent({
    required this.idAtasan,
    required this.idSchedule,
  });

  @override
  List<Object> get props => [idAtasan, idSchedule];
}

class ApproveRealisasiVisitGMEvent extends RealisasiVisitEvent {
  final int idAtasan;
  final List<String> idSchedule;

  const ApproveRealisasiVisitGMEvent({
    required this.idAtasan,
    required this.idSchedule,
  });

  @override
  List<Object> get props => [idAtasan, idSchedule];
}

class RejectRealisasiVisitEvent extends RealisasiVisitEvent {
  final int idAtasan;
  final List<String> idSchedule;

  const RejectRealisasiVisitEvent({
    required this.idAtasan,
    required this.idSchedule,
  });

  @override
  List<Object> get props => [idAtasan, idSchedule];
}
