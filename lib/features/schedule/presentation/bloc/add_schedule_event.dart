import 'package:equatable/equatable.dart';

abstract class AddScheduleEvent extends Equatable {
  const AddScheduleEvent();

  @override
  List<Object?> get props => [];
}

class GetDoctorsAndClinicsEvent extends AddScheduleEvent {
  final String userId;

  const GetDoctorsAndClinicsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetScheduleTypesEvent extends AddScheduleEvent {}

class GetProductsEvent extends AddScheduleEvent {
  final String userId;

  const GetProductsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SubmitScheduleEvent extends AddScheduleEvent {
  final String typeSchedule;
  final String tujuan;
  final String tglVisit;
  final List<String> product;
  final String note;
  final String idUser;
  final String dokter;
  final String klinik;
  final List<String> productForIdDivisi;
  final List<String> productForIdSpesialis;
  final String shift;
  final String jenis;
  final List<String> productNames;
  final List<String> divisiNames;
  final List<String> spesialisNames;

  const SubmitScheduleEvent({
    required this.typeSchedule,
    required this.tujuan,
    required this.tglVisit,
    required this.product,
    required this.note,
    required this.idUser,
    required this.dokter,
    required this.klinik,
    required this.productForIdDivisi,
    required this.productForIdSpesialis,
    required this.shift,
    required this.jenis,
    required this.productNames,
    required this.divisiNames,
    required this.spesialisNames,
  });

  @override
  List<Object?> get props => [
        typeSchedule,
        tujuan,
        tglVisit,
        product,
        note,
        idUser,
        dokter,
        klinik,
        productForIdDivisi,
        productForIdSpesialis,
        shift,
        jenis,
        productNames,
        divisiNames,
        spesialisNames,
      ];
}
