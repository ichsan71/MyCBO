import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final int id;
  final String namaUser;
  final String tipeSchedule;
  final String? namaTipeSchedule;
  final String tujuan;
  final int idTujuan;
  final String tglVisit;
  final String statusCheckin;
  final String shift;
  final String note;
  final String? product;
  final String draft;
  final String? statusDraft;
  final String? alasanReject;
  final String namaTujuan;
  final String? namaSpesialis;
  final String? namaProduct;
  final String? namaDivisi;
  final int approved;
  final String? namaApprover;
  final int? realisasiApprove;
  final int idUser;
  final List<String> productForIdDivisi;
  final List<String> productForIdSpesialis;
  final String jenis;
  final dynamic approvedBy;
  final dynamic rejectedBy;
  final dynamic realisasiVisitApproved;
  final String? createdAt;
  final int? currentPage;
  final int? lastPage;
  final int? total;

  const Schedule({
    required this.id,
    required this.namaUser,
    required this.tipeSchedule,
    this.namaTipeSchedule,
    required this.tujuan,
    required this.idTujuan,
    required this.tglVisit,
    required this.statusCheckin,
    required this.shift,
    required this.note,
    this.product,
    required this.draft,
    this.statusDraft,
    this.alasanReject,
    required this.namaTujuan,
    this.namaSpesialis,
    this.namaProduct,
    this.namaDivisi,
    required this.approved,
    this.namaApprover,
    this.realisasiApprove,
    required this.idUser,
    required this.productForIdDivisi,
    required this.productForIdSpesialis,
    required this.jenis,
    this.approvedBy,
    this.rejectedBy,
    this.realisasiVisitApproved,
    this.createdAt,
    this.currentPage,
    this.lastPage,
    this.total,
  });

  @override
  List<Object?> get props => [
        id,
        namaUser,
        tipeSchedule,
        namaTipeSchedule,
        tujuan,
        idTujuan,
        tglVisit,
        statusCheckin,
        shift,
        note,
        product,
        draft,
        statusDraft,
        alasanReject,
        namaTujuan,
        namaSpesialis,
        namaProduct,
        namaDivisi,
        approved,
        namaApprover,
        realisasiApprove,
        idUser,
        productForIdDivisi,
        productForIdSpesialis,
        jenis,
        approvedBy,
        rejectedBy,
        realisasiVisitApproved,
        createdAt,
        currentPage,
        lastPage,
        total,
      ];

  Schedule copyWith({
    int? id,
    String? namaUser,
    String? tipeSchedule,
    String? namaTipeSchedule,
    String? tujuan,
    int? idTujuan,
    String? tglVisit,
    String? statusCheckin,
    String? shift,
    String? note,
    String? product,
    String? draft,
    String? statusDraft,
    String? alasanReject,
    String? namaTujuan,
    String? namaSpesialis,
    String? namaProduct,
    String? namaDivisi,
    int? approved,
    String? namaApprover,
    int? realisasiApprove,
    int? idUser,
    List<String>? productForIdDivisi,
    List<String>? productForIdSpesialis,
    String? jenis,
    dynamic approvedBy,
    dynamic rejectedBy,
    dynamic realisasiVisitApproved,
    String? createdAt,
    int? currentPage,
    int? lastPage,
    int? total,
  }) {
    return Schedule(
      id: id ?? this.id,
      namaUser: namaUser ?? this.namaUser,
      tipeSchedule: tipeSchedule ?? this.tipeSchedule,
      namaTipeSchedule: namaTipeSchedule ?? this.namaTipeSchedule,
      tujuan: tujuan ?? this.tujuan,
      idTujuan: idTujuan ?? this.idTujuan,
      tglVisit: tglVisit ?? this.tglVisit,
      statusCheckin: statusCheckin ?? this.statusCheckin,
      shift: shift ?? this.shift,
      note: note ?? this.note,
      product: product ?? this.product,
      draft: draft ?? this.draft,
      statusDraft: statusDraft ?? this.statusDraft,
      alasanReject: alasanReject ?? this.alasanReject,
      namaTujuan: namaTujuan ?? this.namaTujuan,
      namaSpesialis: namaSpesialis ?? this.namaSpesialis,
      namaProduct: namaProduct ?? this.namaProduct,
      namaDivisi: namaDivisi ?? this.namaDivisi,
      approved: approved ?? this.approved,
      namaApprover: namaApprover ?? this.namaApprover,
      realisasiApprove: realisasiApprove ?? this.realisasiApprove,
      idUser: idUser ?? this.idUser,
      productForIdDivisi: productForIdDivisi ?? this.productForIdDivisi,
      productForIdSpesialis:
          productForIdSpesialis ?? this.productForIdSpesialis,
      jenis: jenis ?? this.jenis,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      realisasiVisitApproved:
          realisasiVisitApproved ?? this.realisasiVisitApproved,
      createdAt: createdAt ?? this.createdAt,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}
