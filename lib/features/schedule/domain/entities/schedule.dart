import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final int id;
  final String namaUser;
  final String tipeSchedule;
  final String tujuan;
  final String namaTujuan;
  final String tglVisit;
  final String shift;
  final String statusCheckin;
  final String draft;
  final String note;
  final String namaProduct;
  final String namaDivisi;
  final String namaSpesialis;
  final int approved;
  final String? namaApprover;

  const Schedule({
    required this.id,
    required this.namaUser,
    required this.tipeSchedule,
    required this.tujuan,
    required this.namaTujuan,
    required this.tglVisit,
    required this.shift,
    required this.statusCheckin,
    required this.draft,
    required this.note,
    required this.namaProduct,
    required this.namaDivisi,
    required this.namaSpesialis,
    required this.approved,
    this.namaApprover,
  });

  @override
  List<Object?> get props => [
        id,
        namaUser,
        tipeSchedule,
        tujuan,
        namaTujuan,
        tglVisit,
        shift,
        statusCheckin,
        draft,
        note,
        namaProduct,
        namaDivisi,
        namaSpesialis,
        approved,
        namaApprover,
      ];

  Schedule copyWith({
    int? id,
    String? namaUser,
    String? tipeSchedule,
    String? tujuan,
    String? namaTujuan,
    String? tglVisit,
    String? shift,
    String? statusCheckin,
    String? draft,
    String? note,
    String? namaProduct,
    String? namaDivisi,
    String? namaSpesialis,
    int? approved,
    String? namaApprover,
  }) {
    return Schedule(
      id: id ?? this.id,
      namaUser: namaUser ?? this.namaUser,
      tipeSchedule: tipeSchedule ?? this.tipeSchedule,
      tujuan: tujuan ?? this.tujuan,
      namaTujuan: namaTujuan ?? this.namaTujuan,
      tglVisit: tglVisit ?? this.tglVisit,
      shift: shift ?? this.shift,
      statusCheckin: statusCheckin ?? this.statusCheckin,
      draft: draft ?? this.draft,
      note: note ?? this.note,
      namaProduct: namaProduct ?? this.namaProduct,
      namaDivisi: namaDivisi ?? this.namaDivisi,
      namaSpesialis: namaSpesialis ?? this.namaSpesialis,
      approved: approved ?? this.approved,
      namaApprover: namaApprover ?? this.namaApprover,
    );
  }
}
