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
    super.currentPage,
    super.lastPage,
    super.total,
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

  // Helper function to format date consistently
  static String formatDate(dynamic value) {
    if (value == null) return '';
    
    try {
      // If the date is already in MM/dd/yyyy format, return it as is
      if (value is String && RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
        return value;
      }

      // Try to parse the date if it's in a different format
      DateTime date;
      if (value is String) {
        // Try different date formats
        try {
          // Try yyyy-MM-dd format first
          date = DateTime.parse(value);
        } catch (e) {
          // If that fails, try dd/MM/yyyy format
          final parts = value.split('/');
          if (parts.length == 3) {
            date = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          } else {
            throw FormatException('Invalid date format: $value');
          }
        }
      } else {
        throw FormatException('Invalid date value type: ${value.runtimeType}');
      }

      // Format the date as MM/dd/yyyy
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      Logger.error('ScheduleModel', 'Error formatting date: $value - $e');
      return value.toString(); // Return original value if parsing fails
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
      currentPage: null,
      lastPage: null,
      total: null,
    );
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    Logger.info('ScheduleModel', 'Processing schedule with raw data: $json');

    // Log raw type_schedule values
    Logger.info('ScheduleModel', 'Raw type_schedule: ${json['type_schedule']}');
    Logger.info('ScheduleModel', 'Raw tipe_schedule: ${json['tipe_schedule']}');

    // Get tipeSchedule value - try both possible field names
    String tipeScheduleValue = '';
    if (json['type_schedule'] != null && json['type_schedule'].toString().isNotEmpty) {
      tipeScheduleValue = json['type_schedule'].toString();
    } else if (json['tipe_schedule'] != null && json['tipe_schedule'].toString().isNotEmpty) {
      tipeScheduleValue = json['tipe_schedule'].toString();
    }
    Logger.info('ScheduleModel', 'Final tipeSchedule value: $tipeScheduleValue');

    // Get namaTipeSchedule value
    String? namaTipeScheduleValue;
    if (json['nama_type_schedule'] != null && json['nama_type_schedule'].toString().isNotEmpty) {
      namaTipeScheduleValue = json['nama_type_schedule'].toString();
    } else if (json['nama_tipe_schedule'] != null && json['nama_tipe_schedule'].toString().isNotEmpty) {
      namaTipeScheduleValue = json['nama_tipe_schedule'].toString();
    }
    Logger.info('ScheduleModel', 'Final namaTipeSchedule value: $namaTipeScheduleValue');

    // Get shift value
    String shiftValue = processShiftValue(json['shift']);
    Logger.info('ScheduleModel', 'Raw shift value: ${json['shift']}');
    Logger.info('ScheduleModel', 'Processed shift value: $shiftValue');

    // Helper function untuk parse nullable int
    int? parseNullableIntValue(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        // Cek apakah string hanya berisi angka
        if (RegExp(r'^\d+$').hasMatch(value)) {
          return int.tryParse(value);
        }
        Logger.info('ScheduleModel', 'Non-numeric string received for int field: $value');
        return null;
      }
      Logger.info('ScheduleModel', 'Unexpected type for int field: ${value.runtimeType}');
      return null;
    }

    // Helper function untuk parse required int
    int parseIntValue(dynamic value, {int defaultValue = 0}) {
      if (value is int) return value;
      if (value is String) {
        // Cek apakah string hanya berisi angka
        if (RegExp(r'^\d+$').hasMatch(value)) {
          return int.parse(value);
        }
        Logger.info('ScheduleModel', 'Non-numeric string received for required int field: $value');
        return defaultValue;
      }
      Logger.info('ScheduleModel', 'Unexpected type for required int field: ${value.runtimeType}');
      return defaultValue;
    }

    // Helper function to parse and format date
    String formatDate(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) return '';
      
      try {
        // If the date is in YYYY-MM-DD format, convert it to MM/dd/yyyy
        if (value.toString().contains('-')) {
          final parts = value.toString().split('-');
          if (parts.length == 3) {
            return '${parts[1]}/${parts[2]}/${parts[0]}';
          }
        }
        // If the date is already in MM/dd/yyyy format, return as is
        else if (value.toString().contains('/')) {
          final parts = value.toString().split('/');
          if (parts.length == 3) {
            // Validate that it's already in correct format
            if (parts[0].length <= 2 && parts[1].length <= 2 && parts[2].length == 4) {
              return value.toString();
            }
          }
        }
      } catch (e) {
        Logger.error('ScheduleModel', 'Error formatting date: $e');
      }
      
      return value.toString();
    }

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
    Logger.info('ScheduleModel', 'Raw id_tujuan: ${json['id_tujuan']}');
    Logger.info('ScheduleModel', 'Raw approved: ${json['approved']}');
    Logger.info('ScheduleModel', 'Raw id_user: ${json['id_user']}');

    return ScheduleModel(
      id: parseIntValue(json['id']),
      namaUser: json['nama_user'] ?? '',
      tipeSchedule: tipeScheduleValue,
      namaTipeSchedule: namaTipeScheduleValue,
      tujuan: json['tujuan'] ?? '',
      idTujuan: parseIntValue(json['id_tujuan']),
      tglVisit: formatDate(json['tgl_visit']),
      statusCheckin: json['status_checkin'] ?? '',
      shift: shiftValue,
      note: json['note'] ?? '',
      product: parseProduct(json['product']),
      draft: json['draft'] ?? '',
      statusDraft: json['status_draft'],
      alasanReject: json['alasan_reject'],
      namaTujuan: json['nama_tujuan'] ?? '',
      namaSpesialis: json['nama_spesialis'],
      namaProduct: json['nama_product'],
      namaDivisi: json['nama_divisi'],
      approved: parseIntValue(json['approved']),
      namaApprover: json['nama_approver'],
      realisasiApprove: json['realisasi_approve'],
      idUser: parseIntValue(json['id_user']),
      productForIdDivisi: List<String>.from(json['product_for_id_divisi'] ?? []),
      productForIdSpesialis: List<String>.from(json['product_for_id_spesialis'] ?? []),
      jenis: json['jenis'] ?? '',
      approvedBy: json['approved_by'],
      rejectedBy: json['rejected_by'],
      realisasiVisitApproved: json['realisasi_visit_approved'],
      createdAt: json['created_at'],
      currentPage: parseNullableIntValue(json['current_page']),
      lastPage: parseNullableIntValue(json['last_page']),
      total: parseNullableIntValue(json['total']),
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
      'current_page': currentPage,
      'last_page': lastPage,
      'total': total,
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
        currentPage,
        lastPage,
        total,
      ];
}
