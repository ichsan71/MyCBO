import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class AddSchedule implements UseCase<bool, AddScheduleParams> {
  final AddScheduleRepository repository;

  AddSchedule(this.repository);

  @override
  Future<Either<Failure, bool>> call(AddScheduleParams params) {
    return repository.addSchedule(
      typeSchedule: params.typeSchedule,
      tujuan: params.tujuan,
      tglVisit: params.tglVisit,
      product: params.product,
      note: params.note,
      idUser: params.idUser,
      dokter: params.dokter,
      klinik: params.klinik,
      productForIdDivisi: params.productForIdDivisi,
      productForIdSpesialis: params.productForIdSpesialis,
      shift: params.shift,
      jenis: params.jenis,
      productNames: params.productNames,
      divisiNames: params.divisiNames,
      spesialisNames: params.spesialisNames,
    );
  }
}

class AddScheduleParams extends Equatable {
  final int typeSchedule;
  final String tujuan;
  final String tglVisit;
  final List<int> product;
  final String note;
  final int idUser;
  final int dokter;
  final String klinik;
  final List<int> productForIdDivisi;
  final List<int> productForIdSpesialis;
  final String shift;
  final String jenis;
  final List<String> productNames;
  final List<String> divisiNames;
  final List<String> spesialisNames;

  const AddScheduleParams({
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
