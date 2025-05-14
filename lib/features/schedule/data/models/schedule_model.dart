import '../../domain/entities/schedule.dart';
import 'package:flutter/foundation.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.id,
    required super.namaUser,
    required super.tipeSchedule,
    required super.tujuan,
    required super.namaTujuan,
    required super.tglVisit,
    required super.shift,
    required super.statusCheckin,
    required super.draft,
    required super.note,
    required super.namaProduct,
    required super.namaDivisi,
    required super.namaSpesialis,
    required super.approved,
    required super.namaApprover,
  });

  factory ScheduleModel.empty() {
    return const ScheduleModel(
      id: 0,
      namaUser: '',
      tipeSchedule: '',
      tujuan: '',
      namaTujuan: '',
      tglVisit: '',
      shift: '',
      statusCheckin: '',
      draft: '',
      note: '',
      namaProduct: '',
      namaDivisi: '',
      namaSpesialis: '',
      approved: 0,
      namaApprover: null,
    );
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        print('🔍 Converting JSON to ScheduleModel:');
        print(json);
      }

      // Validasi field-field wajib
      if (!json.containsKey('id')) {
        throw const FormatException('Missing required field: id');
      }

      // Handle nama_product yang bisa null atau string kosong
      String namaProduct = '';
      if (json['nama_product'] != null) {
        namaProduct = json['nama_product'].toString().trim();
      }

      // Handle nama_divisi yang bisa null atau string kosong
      String namaDivisi = '';
      if (json['nama_divisi'] != null) {
        namaDivisi = json['nama_divisi'].toString().trim();
      }

      // Handle nama_spesialis yang bisa null atau string kosong
      String namaSpesialis = '';
      if (json['nama_spesialis'] != null) {
        namaSpesialis = json['nama_spesialis'].toString().trim();
      }

      if (kDebugMode) {
        print('📦 Processed values:');
        print('Nama Product: $namaProduct');
        print('Nama Divisi: $namaDivisi');
        print('Nama Spesialis: $namaSpesialis');
      }

      final schedule = ScheduleModel(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id'].toString()) ?? 0,
        namaUser: json['nama_user']?.toString() ?? '',
        tipeSchedule: json['tipe_schedule']?.toString() ?? '',
        tujuan: json['tujuan']?.toString() ?? '',
        namaTujuan: json['nama_tujuan']?.toString() ?? '',
        tglVisit: json['tgl_visit']?.toString() ?? '',
        shift: json['shift']?.toString() ?? '',
        statusCheckin: json['status_checkin']?.toString() ?? '',
        draft: json['draft']?.toString() ?? '',
        note: json['note']?.toString() ?? '',
        namaProduct: namaProduct,
        namaDivisi: namaDivisi,
        namaSpesialis: namaSpesialis,
        approved: json['approved'] is int
            ? json['approved']
            : int.tryParse(json['approved'].toString()) ?? 0,
        namaApprover: json['nama_approver']?.toString(),
      );

      if (kDebugMode) {
        print('✅ Successfully converted to ScheduleModel:');
        print(schedule.toJson());
      }

      return schedule;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error converting JSON to ScheduleModel: $e');
        print('JSON data: $json');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_user': namaUser,
      'tipe_schedule': tipeSchedule,
      'tujuan': tujuan,
      'nama_tujuan': namaTujuan,
      'tgl_visit': tglVisit,
      'shift': shift,
      'status_checkin': statusCheckin,
      'draft': draft,
      'note': note,
      'nama_product': namaProduct,
      'nama_divisi': namaDivisi,
      'nama_spesialis': namaSpesialis,
      'approved': approved,
      'nama_approver': namaApprover,
    };
  }
}
