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

  // Helper function to process shift value
  static String processShiftValue(dynamic value) {
    if (value == null) return '';

    String shiftStr = value.toString().toLowerCase().trim();

    // Validate and normalize shift value
    switch (shiftStr) {
      case 'pagi':
      case 'sore':
        // Capitalize first letter
        return shiftStr[0].toUpperCase() + shiftStr.substring(1);
      default:
        // Instead of returning empty string, return the original value
        Logger.warning('ScheduleModel',
            'Non-standard shift value: $value, preserving original value');
        return value.toString();
    }
  }

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
    Logger.info('ScheduleModel', 'Processing schedule with raw data: $json');

    // Helper function to parse integer values that might come as strings
    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          Logger.error('ScheduleModel', 'Error parsing int value: $value');
          return 0;
        }
      }
      return 0;
    }

    // Helper function to parse nullable integer values
    int? parseNullableIntValue(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        if (value.toLowerCase() == 'null' || value.isEmpty) return null;
        try {
          return int.parse(value);
        } catch (e) {
          Logger.error(
              'ScheduleModel', 'Error parsing nullable int value: $value');
          return null;
        }
      }
      return null;
    }

    final shiftValue = processShiftValue(json['shift']);
    Logger.info('ScheduleModel', 'Raw shift value: ${json['shift']}');
    Logger.info('ScheduleModel', 'Processed shift value: $shiftValue');

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

    // Helper function to parse dynamic values that might be null
    dynamic parseDynamicValue(dynamic value) {
      if (value == null) return null;
      if (value is String && value.toLowerCase() == 'null') return null;
      return value;
    }

    // Log raw values for debugging
    Logger.info('ScheduleModel', 'Raw type_schedule: ${json['type_schedule']}');
    Logger.info('ScheduleModel', 'Raw tipe_schedule: ${json['tipe_schedule']}');
    Logger.info('ScheduleModel', 'Raw id_tujuan: ${json['id_tujuan']}');
    Logger.info('ScheduleModel', 'Raw approved: ${json['approved']}');
    Logger.info('ScheduleModel', 'Raw id_user: ${json['id_user']}');

    final String tipeScheduleValue = json['type_schedule']?.toString() ??
        json['tipe_schedule']?.toString() ??
        '';

    Logger.info(
        'ScheduleModel', 'Final tipeSchedule value: $tipeScheduleValue');

    final String? namaTipeScheduleValue =
        json['nama_type_schedule']?.toString() ??
            json['nama_tipe_schedule']?.toString() ??
            tipeScheduleValue;

    Logger.info('ScheduleModel',
        'Final namaTipeSchedule value: $namaTipeScheduleValue');

    return ScheduleModel(
      id: parseIntValue(json['id']),
      namaUser: json['nama_user']?.toString() ?? '',
      tipeSchedule: tipeScheduleValue,
      namaTipeSchedule: namaTipeScheduleValue,
      tujuan: json['tujuan']?.toString() ?? '',
      idTujuan: parseIntValue(json['id_tujuan']),
      tglVisit: json['tgl_visit']?.toString() ?? '',
      statusCheckin: json['status_checkin']?.toString() ?? '',
      shift: shiftValue,
      note: json['note']?.toString() ?? '',
      product: parseProduct(json['product']),
      draft: json['draft']?.toString() ?? '',
      statusDraft: json['status_draft']?.toString(),
      alasanReject: json['alasan_reject']?.toString(),
      namaTujuan: json['nama_tujuan']?.toString() ?? '',
      namaSpesialis: json['nama_spesialis']?.toString(),
      namaProduct: json['nama_product']?.toString(),
      namaDivisi: json['nama_divisi']?.toString(),
      approved: parseIntValue(json['approved']),
      namaApprover: json['nama_approver']?.toString(),
      realisasiApprove: parseNullableIntValue(json['realisasi_approve']),
      idUser: parseIntValue(json['id_user']),
      productForIdDivisi: parseStringList(json['product_for_id_divisi']),
      productForIdSpesialis: parseStringList(json['product_for_id_spesialis']),
      jenis: json['jenis']?.toString() ?? '',
      approvedBy: parseDynamicValue(json['approved_by']),
      rejectedBy: parseDynamicValue(json['rejected_by']),
      realisasiVisitApproved:
          parseDynamicValue(json['realisasi_visit_approved']),
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
