import 'package:equatable/equatable.dart';

class EditScheduleModel extends Equatable {
  final int id;
  final String typeSchedule;
  final String tujuan;
  final int idTujuan;
  final String tglVisit;
  final List<String> product;
  final String note;
  final int idUser;
  final List<String> productForIdDivisi;
  final List<String> productForIdSpesialis;
  final int approved;
  final String draft;
  final String shift;
  final String jenis;
  final int? approvedBy;
  final int? rejectedBy;
  final int? realisasiVisitApproved;
  final String? createdAt;

  const EditScheduleModel({
    required this.id,
    required this.typeSchedule,
    required this.tujuan,
    required this.idTujuan,
    required this.tglVisit,
    required this.product,
    required this.note,
    required this.idUser,
    required this.productForIdDivisi,
    required this.productForIdSpesialis,
    required this.approved,
    required this.draft,
    required this.shift,
    required this.jenis,
    this.approvedBy,
    this.rejectedBy,
    this.realisasiVisitApproved,
    this.createdAt,
  });

  factory EditScheduleModel.fromJson(Map<String, dynamic> json) {
    // Parse product list
    List<String> parseProductList(dynamic value) {
      if (value is String) {
        try {
          // Remove brackets and split by comma
          String cleanString =
              value.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
          return cleanString
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } catch (e) {
          return [];
        }
      } else if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return EditScheduleModel(
      id: json['id'] ?? 0,
      typeSchedule: json['type_schedule']?.toString() ?? '',
      tujuan: json['tujuan']?.toString() ?? '',
      idTujuan: json['id_tujuan'] ?? 0,
      tglVisit: json['tgl_visit']?.toString() ?? '',
      product: parseProductList(json['product']),
      note: json['note']?.toString() ?? '',
      idUser: json['id_user'] ?? 0,
      productForIdDivisi: parseProductList(json['product_for_id_divisi']),
      productForIdSpesialis: parseProductList(json['product_for_id_spesialis']),
      approved: json['approved'] ?? 0,
      draft: json['draft']?.toString() ?? '',
      shift: json['shift']?.toString() ?? '',
      jenis: json['jenis']?.toString() ?? '',
      approvedBy: json['approved_by'],
      rejectedBy: json['rejected_by'],
      realisasiVisitApproved: json['realisasi_visit_approved'],
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_schedule': typeSchedule,
      'tujuan': tujuan,
      'id_tujuan': idTujuan,
      'tgl_visit': tglVisit,
      'product': product,
      'note': note,
      'id_user': idUser,
      'product_for_id_divisi': productForIdDivisi,
      'product_for_id_spesialis': productForIdSpesialis,
      'approved': approved,
      'draft': draft,
      'shift': shift,
      'jenis': jenis,
      'approved_by': approvedBy,
      'rejected_by': rejectedBy,
      'realisasi_visit_approved': realisasiVisitApproved,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        typeSchedule,
        tujuan,
        idTujuan,
        tglVisit,
        product,
        note,
        idUser,
        productForIdDivisi,
        productForIdSpesialis,
        approved,
        draft,
        shift,
        jenis,
        approvedBy,
        rejectedBy,
        realisasiVisitApproved,
        createdAt,
      ];
}
