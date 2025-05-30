import 'package:equatable/equatable.dart';
import 'dart:convert';
import '../../domain/entities/schedule.dart';
import 'schedule_model.dart';
import 'type_schedule_model.dart';
import 'division_model.dart';
import 'specialist_model.dart';
import 'edit/edit_schedule_product_model.dart';
import 'doctor_clinic_model.dart';
import '../../../../core/utils/logger.dart';
class EditScheduleDataModel extends Equatable {
  final Schedule schedule;
  final List<TypeScheduleModel> typeSchedules;
  final List<EditScheduleProductModel> products;
  final List<DoctorClinicModel> doctors;
  final List<Division> divisions;
  final List<Specialist> specialists;

  const EditScheduleDataModel({
    required this.schedule,
    required this.typeSchedules,
    required this.products,
    required this.doctors,
    required this.divisions,
    required this.specialists,
  });

  factory EditScheduleDataModel.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('schedule', 'Received JSON data: $json');
      final scheduleData = json['data_schedule'] as Map<String, dynamic>;
      Logger.info('schedule', 'Schedule data: $scheduleData');

      // Log type schedules data
      final typeSchedulesData = json['data_type_schedule'] as List<dynamic>?;
      Logger.info('schedule', 'Type schedules data: $typeSchedulesData');

      // Log doctors data from new structure
      final doctorsData = json['data_dokter']?['dokter'] as List<dynamic>?;
      Logger.info('schedule', 'Doctors data from data_dokter: $doctorsData');

      // Helper function to parse list
      List<String> parseList(dynamic value) {
        if (value == null) return [];

        if (value is String) {
          try {
            // Try to parse as JSON array first
            final decoded = jsonDecode(value);
            if (decoded is List) {
              return decoded.map((e) => e.toString()).toList();
            }
            // If not a JSON array, try splitting by comma
            String cleanString = value
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .replaceAll(' ', '');
            return cleanString.split(',').where((e) => e.isNotEmpty).toList();
          } catch (e) {
            Logger.error('schedule', 'Error parsing string to list: $e');
            // If single value, return as single item list
            if (value.trim().isNotEmpty) {
              return [value.trim()];
            }
            return [];
          }
        } else if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
        return [];
      }

      // Create schedule model
      final schedule = ScheduleModel(
        id: scheduleData['id'] ?? 0,
        namaUser: scheduleData['nama_user']?.toString() ?? '',
        tipeSchedule: scheduleData['type_schedule']?.toString() ?? '',
        tujuan: scheduleData['tujuan']?.toString() ?? '',
        idTujuan: scheduleData['id_tujuan'] ?? 0,
        tglVisit: scheduleData['tgl_visit']?.toString() ?? '',
        statusCheckin: scheduleData['status_checkin']?.toString() ?? '',
        shift: scheduleData['shift']?.toString() ?? '',
        note: scheduleData['note']?.toString() ?? '',
        product: scheduleData['product']?.toString(),
        draft: scheduleData['draft']?.toString() ?? '',
        statusDraft: scheduleData['status_draft']?.toString(),
        alasanReject: scheduleData['alasan_reject']?.toString(),
        namaTujuan: scheduleData['nama_tujuan']?.toString() ?? '',
        namaSpesialis: scheduleData['nama_spesialis']?.toString(),
        namaProduct: scheduleData['nama_product']?.toString(),
        namaDivisi: scheduleData['nama_divisi']?.toString(),
        approved: scheduleData['approved'] ?? 0,
        namaApprover: scheduleData['nama_approver']?.toString(),
        realisasiApprove: scheduleData['realisasi_approve'],
        idUser: scheduleData['id_user'] ?? 0,
        productForIdDivisi: parseList(scheduleData['product_for_id_divisi']),
        productForIdSpesialis:
            parseList(scheduleData['product_for_id_spesialis']),
        jenis: scheduleData['jenis']?.toString() ?? '',
        approvedBy: scheduleData['approved_by'],
        rejectedBy: scheduleData['rejected_by'],
        realisasiVisitApproved: scheduleData['realisasi_visit_approved'],
        createdAt: scheduleData['created_at']?.toString(),
      );

      Logger.info('schedule',
          'Created schedule model with type_schedule: ${schedule.tipeSchedule}');

      // Parse type schedules from data_type_schedule
      final typeSchedules = (typeSchedulesData)
              ?.map(
                  (e) => TypeScheduleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      Logger.info('schedule',
          'Parsed ${typeSchedules.length} type schedules');
      typeSchedules.forEach((type) {
        Logger.info('schedule',
            'Type schedule: id=${type.id}, name=${type.name}');
      });

      // Parse doctors from data_dokter.dokter
      final doctors = (doctorsData)
              ?.map((e) => DoctorClinicModel.fromJson({
                    'id': e['id_dokter'],
                    'nama': e['nama_dokter'],
                    'spesialis': e['nama_spesialis'],
                    'kode': e['kode_pelanggan'],
                    // Add any other fields needed by DoctorClinicModel
                  }))
              .toList() ??
          [];
      Logger.info('schedule', 'Parsed ${doctors.length} doctors');
      doctors.forEach((doctor) {
        Logger.info('schedule', 'Doctor: id=${doctor.id}, name=${doctor.nama}');
      });

      return EditScheduleDataModel(
        schedule: schedule,
        typeSchedules: typeSchedules,
        products: (json['data_product'] as List<dynamic>?)
                ?.map((e) => EditScheduleProductModel.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        doctors: doctors,
        divisions: (json['data_division'] as List?)
                ?.map((e) => Division.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        specialists: (json['data_specialist'] as List?)
                ?.map((e) => Specialist.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      Logger.error('schedule', 'Error converting JSON: $e');
      Logger.info('schedule', 'Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data_schedule': schedule is ScheduleModel
          ? (schedule as ScheduleModel).toJson()
          : {
              'id': schedule.id,
              'nama_user': schedule.namaUser,
              'type_schedule': schedule.tipeSchedule,
              'tujuan': schedule.tujuan,
              'id_tujuan': schedule.idTujuan,
              'tgl_visit': schedule.tglVisit,
              'status_checkin': schedule.statusCheckin,
              'shift': schedule.shift,
              'note': schedule.note,
              'product': schedule.product,
              'draft': schedule.draft,
              'status_draft': schedule.statusDraft,
              'alasan_reject': schedule.alasanReject,
              'nama_tujuan': schedule.namaTujuan,
              'nama_spesialis': schedule.namaSpesialis,
              'nama_product': schedule.namaProduct,
              'nama_divisi': schedule.namaDivisi,
              'approved': schedule.approved,
              'nama_approver': schedule.namaApprover,
              'realisasi_approve': schedule.realisasiApprove,
              'id_user': schedule.idUser,
              'product_for_id_divisi': schedule.productForIdDivisi,
              'product_for_id_spesialis': schedule.productForIdSpesialis,
              'jenis': schedule.jenis,
              'approved_by': schedule.approvedBy,
              'rejected_by': schedule.rejectedBy,
              'realisasi_visit_approved': schedule.realisasiVisitApproved,
              'created_at': schedule.createdAt,
            },
      'type_schedules': typeSchedules.map((e) => e.toJson()).toList(),
      'data_product': products.map((e) => e.toJson()).toList(),
      'doctors': doctors.map((e) => e.toJson()).toList(),
      'data_division': divisions.map((e) => e.toJson()).toList(),
      'data_specialist': specialists.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [schedule, typeSchedules, products, doctors, divisions, specialists];
}
