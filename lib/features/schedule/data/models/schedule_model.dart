import '../../domain/entities/schedule.dart';
import 'dart:convert';
import '../../../../core/utils/logger.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.id,
    required super.namaUser,
    required super.tipeSchedule,
    super.namaTipeSchedule,
    required super.tujuan,
    required super.idTujuan,
    required super.tglVisit,
    required super.statusCheckin,
    required super.shift,
    required super.note,
    super.product,
    required super.draft,
    super.statusDraft,
    super.alasanReject,
    required super.namaTujuan,
    super.namaSpesialis,
    super.namaProduct,
    super.namaDivisi,
    required super.approved,
    super.namaApprover,
    super.realisasiApprove,
    required super.idUser,
    required super.productForIdDivisi,
    required super.productForIdSpesialis,
    required super.jenis,
    super.approvedBy,
    super.rejectedBy,
    super.realisasiVisitApproved,
    super.createdAt,
  });

  factory ScheduleModel.empty() {
    return const ScheduleModel(
      id: 0,
      namaUser: '',
      tipeSchedule: '',
      namaTipeSchedule: '',
      tujuan: '',
      idTujuan: 0,
      tglVisit: '',
      statusCheckin: '',
      shift: '',
      note: '',
      product: '',
      draft: '',
      statusDraft: '',
      alasanReject: '',
      namaTujuan: '',
      namaSpesialis: '',
      namaProduct: '',
      namaDivisi: '',
      approved: 0,
      namaApprover: null,
      realisasiApprove: null,
      idUser: 0,
      productForIdDivisi: [],
      productForIdSpesialis: [],
      jenis: '',
      approvedBy: null,
      rejectedBy: null,
      realisasiVisitApproved: null,
      createdAt: null,
    );
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse product data
    String? parseProduct(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        // Check if the string is already in JSON array format
        if (value.startsWith('[') && value.endsWith(']')) {
          return value;
        }
        // If it's a single value, convert it to JSON array format
        return '["$value"]';
      }
      if (value is List) {
        // Convert list to JSON string
        return jsonEncode(value);
      }
      return null;
    }

    // Helper function to parse list of strings
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          // Try to parse as JSON first
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          // If JSON parsing fails, try simple string splitting
          return value
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ScheduleModel(
      id: json['id'] ?? 0,
      namaUser: json['nama_user']?.toString() ?? '',
      tipeSchedule: () {
        // Check both possible field names
        final typeSchedule = json['type_schedule']?.toString() ??
            json['tipe_schedule']?.toString() ??
            '';
        Logger.info(
            'ScheduleModel', 'Raw type_schedule: ${json['type_schedule']}');
        Logger.info(
            'ScheduleModel', 'Raw tipe_schedule: ${json['tipe_schedule']}');
        Logger.info('ScheduleModel', 'Final tipeSchedule value: $typeSchedule');
        return typeSchedule;
      }(),
      namaTipeSchedule: () {
        // Try different possible field names
        final typeScheduleName = json['nama_type_schedule']?.toString() ??
            json['nama_tipe_schedule']?.toString() ??
            json['type_schedule']
                ?.toString() ?? // Use type_schedule as fallback
            json['tipe_schedule']?.toString(); // Use tipe_schedule as fallback
        Logger.info('ScheduleModel',
            'Raw nama_type_schedule: ${json['nama_type_schedule']}');
        Logger.info('ScheduleModel',
            'Raw nama_tipe_schedule: ${json['nama_tipe_schedule']}');
        Logger.info(
            'ScheduleModel', 'Final namaTipeSchedule value: $typeScheduleName');
        return typeScheduleName;
      }(),
      tujuan: json['tujuan']?.toString() ?? '',
      idTujuan: json['id_tujuan'] ?? 0,
      tglVisit: json['tgl_visit']?.toString() ?? '',
      statusCheckin: json['status_checkin']?.toString() ?? '',
      shift: json['shift']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      product: parseProduct(json['product']),
      draft: json['draft']?.toString() ?? '',
      statusDraft: json['status_draft']?.toString(),
      alasanReject: json['alasan_reject']?.toString(),
      namaTujuan: json['nama_tujuan']?.toString() ?? '',
      namaSpesialis: json['nama_spesialis']?.toString(),
      namaProduct: json['nama_product']?.toString(),
      namaDivisi: json['nama_divisi']?.toString(),
      approved: json['approved'] ?? 0,
      namaApprover: json['nama_approver']?.toString(),
      realisasiApprove: json['realisasi_approve'],
      idUser: json['id_user'] ?? 0,
      productForIdDivisi: parseStringList(json['product_for_id_divisi']),
      productForIdSpesialis: parseStringList(json['product_for_id_spesialis']),
      jenis: json['jenis']?.toString() ?? 'suddenly',
      approvedBy: json['approved_by'],
      rejectedBy: json['rejected_by'],
      realisasiVisitApproved: json['realisasi_visit_approved'],
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_user': namaUser,
      'type_schedule': tipeSchedule,
      'nama_type_schedule': namaTipeSchedule,
      'tujuan': tujuan,
      'id_tujuan': idTujuan,
      'tgl_visit': tglVisit,
      'status_checkin': statusCheckin,
      'shift': shift,
      'note': note,
      'product': product,
      'draft': draft,
      'status_draft': statusDraft,
      'alasan_reject': alasanReject,
      'nama_tujuan': namaTujuan,
      'nama_spesialis': namaSpesialis,
      'nama_product': namaProduct,
      'nama_divisi': namaDivisi,
      'approved': approved,
      'nama_approver': namaApprover,
      'realisasi_approve': realisasiApprove,
      'id_user': idUser,
      'product_for_id_divisi': productForIdDivisi,
      'product_for_id_spesialis': productForIdSpesialis,
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
      ];
}
